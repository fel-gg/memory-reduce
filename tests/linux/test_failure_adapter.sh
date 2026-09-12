#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "${script_directory}/../.." && pwd)"
temporary_root="$(mktemp -d)"
cleanup() {
  case "${temporary_root}" in
    /tmp/*|/var/tmp/*) rm -rf -- "${temporary_root}" ;;
    *) printf 'Refusing to remove unexpected test directory: %s\n' "${temporary_root}" >&2 ;;
  esac
}
trap cleanup EXIT

mkdir -p "${temporary_root}/vm" "${temporary_root}/cgroup"
cat > "${temporary_root}/meminfo" <<'EOF'
MemTotal:       16777216 kB
MemAvailable:   10485760 kB
Cached:          2097152 kB
SReclaimable:     262144 kB
Shmem:             65536 kB
AnonPages:       4194304 kB
SwapTotal:       4194304 kB
SwapFree:        3145728 kB
EOF
: > "${temporary_root}/vm/drop_caches"
: > "${temporary_root}/cgroup/memory.reclaim"

cat > "${temporary_root}/reduce-memory-native" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "check" ]]; then
  printf 'native_status=supported\n'
  exit 0
fi
session=""
previous=""
for argument in "$@"; do
  [[ "${previous}" == "--session" ]] && session="${argument}"
  previous="${argument}"
done
printf 'protocol=2\nsession=%s\n' "${session}" >&2
printf 'native_status=permission_denied\n' >&2
exit 5
EOF
chmod +x "${temporary_root}/reduce-memory-native"

cat > "${temporary_root}/fake-sync" <<'EOF'
#!/usr/bin/env bash
printf 'sync\n' >> "${REDUCE_MEMORY_TEST_SYNC_LOG:?}"
EOF
chmod +x "${temporary_root}/fake-sync"

# Shadow the system interpreter with a deterministic failing shim. Ubuntu CI
# has python3 installed, so PATH filtering alone cannot represent a missing
# dependency without this isolated adapter.
mkdir -p "${temporary_root}/bin"
mkdir -p "${temporary_root}/bin-success"
cat > "${temporary_root}/bin-success/python3" <<'EOF'
#!/usr/bin/env bash
printf 'Python 3 test shim\n'
exit 0
EOF
chmod +x "${temporary_root}/bin-success/python3"
cat > "${temporary_root}/bin/python3" <<'EOF'
#!/usr/bin/env bash
exit 127
EOF
chmod +x "${temporary_root}/bin/python3"

output="$(
  env \
    REDUCE_MEMORY_TEST_MODE=1 \
    REDUCE_MEMORY_TEST_ROOT="${temporary_root}" \
    REDUCE_MEMORY_MEMINFO_FILE="${temporary_root}/meminfo" \
    REDUCE_MEMORY_VM_ROOT="${temporary_root}/vm" \
    REDUCE_MEMORY_TARGET_CGROUP="${temporary_root}/cgroup" \
    REDUCE_MEMORY_NATIVE_HELPER="${temporary_root}/reduce-memory-native" \
    REDUCE_MEMORY_SYNC_COMMAND="${temporary_root}/fake-sync" \
    REDUCE_MEMORY_TEST_EFFECTIVE_UID=0 \
    REDUCE_MEMORY_KERNEL_NAME=Linux \
    REDUCE_MEMORY_TEST_SYNC_LOG="${temporary_root}/sync.log" \
    REDUCE_MEMORY_TARGET_UID=1000 \
    REDUCE_MEMORY_SETTLE_SECONDS=0 \
    PATH="${temporary_root}/bin-success:/usr/bin:/bin" \
    "${repository_root}/linux/ReduceMemory_Linux.sh" normal
)"

grep -F 'Native process page-out : pass1=permission_denied' <<< "${output}" >/dev/null
test "$(wc -l < "${temporary_root}/sync.log")" -eq 1
test ! -s "${temporary_root}/vm/drop_caches"
test ! -s "${temporary_root}/cgroup/memory.reclaim"

# Dependency-missing contract: hiding python3 must produce an explicit stage
# status and must not invoke the native helper or mutate any fixture file.
dependency_output="$(
  env \
    PATH="${temporary_root}/bin:/usr/bin:/bin" \
    REDUCE_MEMORY_TEST_MODE=1 \
    REDUCE_MEMORY_TEST_ROOT="${temporary_root}" \
    REDUCE_MEMORY_MEMINFO_FILE="${temporary_root}/meminfo" \
    REDUCE_MEMORY_VM_ROOT="${temporary_root}/vm" \
    REDUCE_MEMORY_TARGET_CGROUP="${temporary_root}/cgroup" \
    REDUCE_MEMORY_NATIVE_HELPER="${temporary_root}/reduce-memory-native" \
    REDUCE_MEMORY_SYNC_COMMAND="${temporary_root}/fake-sync" \
    REDUCE_MEMORY_TEST_EFFECTIVE_UID=0 \
    REDUCE_MEMORY_KERNEL_NAME=Linux \
    REDUCE_MEMORY_TEST_SYNC_LOG="${temporary_root}/sync.log" \
    REDUCE_MEMORY_SETTLE_SECONDS=0 \
    "${repository_root}/linux/ReduceMemory_Linux.sh" normal
)"
grep -F 'python3 not installed' <<< "${dependency_output}" >/dev/null
test "$(wc -l < "${temporary_root}/sync.log")" -eq 2
test ! -s "${temporary_root}/vm/drop_caches"
test ! -s "${temporary_root}/cgroup/memory.reclaim"

cat > "${temporary_root}/failing-sync" <<'EOF'
#!/usr/bin/env bash
exit 73
EOF
chmod +x "${temporary_root}/failing-sync"
sync_failure_output="$(
  env \
    REDUCE_MEMORY_TEST_MODE=1 \
    REDUCE_MEMORY_TEST_ROOT="${temporary_root}" \
    REDUCE_MEMORY_MEMINFO_FILE="${temporary_root}/meminfo" \
    REDUCE_MEMORY_VM_ROOT="${temporary_root}/vm" \
    REDUCE_MEMORY_TARGET_CGROUP="${temporary_root}/cgroup" \
    REDUCE_MEMORY_NATIVE_HELPER="${temporary_root}/reduce-memory-native" \
    REDUCE_MEMORY_SYNC_COMMAND="${temporary_root}/failing-sync" \
    REDUCE_MEMORY_TEST_EFFECTIVE_UID=0 \
    REDUCE_MEMORY_KERNEL_NAME=Linux \
    REDUCE_MEMORY_TARGET_UID=1000 \
    REDUCE_MEMORY_SETTLE_SECONDS=0 \
    PATH="${temporary_root}/bin-success:/usr/bin:/bin" \
    "${repository_root}/linux/ReduceMemory_Linux.sh" normal
)"
grep -F 'Kernel sync             : failed' <<< "${sync_failure_output}" >/dev/null
grep -F 'Native process page-out : pass1=permission_denied' <<< "${sync_failure_output}" >/dev/null
printf 'Linux fake-syscall failure adapter passed without real reclaim writes.\n'
