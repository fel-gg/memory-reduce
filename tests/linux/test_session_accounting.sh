#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  printf '%s\n' 'SKIPPED: Linux session-accounting runtime requires a Linux/WSL2 host.'
  exit 0
fi

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

write_meminfo() {
  local available_kib="$1"
  cat > "${temporary_root}/meminfo" <<EOF
MemTotal:       16777216 kB
MemAvailable:   ${available_kib} kB
Cached:          2097152 kB
SReclaimable:     262144 kB
Shmem:             65536 kB
AnonPages:       4194304 kB
SwapTotal:       4194304 kB
SwapFree:        3145728 kB
EOF
}

assert_output_contains() {
  local output="$1"
  local expected="$2"
  if ! grep -F "${expected}" <<< "${output}" >/dev/null; then
    printf 'Session-accounting assertion failed; expected: %s\n' "${expected}" >&2
    printf '%s\n' 'Captured launcher output:' >&2
    printf '%s\n' "${output}" >&2
    return 1
  fi
}

mkdir -p "${temporary_root}/vm" "${temporary_root}/cgroup"
: > "${temporary_root}/vm/drop_caches"
: > "${temporary_root}/cgroup/memory.reclaim"
write_meminfo 10485760

# The fake helper is shell-only, but the launcher still performs its explicit
# python3 dependency probe. Provide a bounded test shim so this contract can
# run under Git Bash on Windows without treating the host's missing Linux
# interpreter name as a product failure.
mkdir -p "${temporary_root}/bin"
cat > "${temporary_root}/bin/python3" <<'EOF'
#!/usr/bin/env bash
printf 'Python 3 test shim\n'
exit 0
EOF
chmod +x "${temporary_root}/bin/python3"

cat > "${temporary_root}/fake-sync" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${temporary_root}/fake-sync"

cat > "${temporary_root}/reduce-memory-native" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "reclaim" ]]; then
  session=""; path=""; bytes=""; previous=""
  for argument in "$@"; do
    [[ "${previous}" == "--session" ]] && session="${argument}"
    [[ "${previous}" == "--path" ]] && path="${argument}"
    [[ "${previous}" == "--bytes" ]] && bytes="${argument}"
    previous="${argument}"
  done
  printf '%s' "${bytes}" > "${path}"
  printf 'protocol=2\nsession=%s\nnative_status=done\n' "${session}"
  exit 0
fi
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
printf 'protocol=2\nsession=%s\n' "${session}"
cat <<'RESULT'
native_status=done
processes_seen=1
processes_eligible=1
processes_advised=1
processes_failed=0
processes_active_skipped=0
processes_protected=0
workloads_protected=0
mappings_advised=1
mappings_failed=0
bytes_advised=134217728
rss_before_kb=262144
rss_after_kb=131072
rss_delta_kb=131072
rss_reduced_kb=131072
rss_measured_targets=1
rss_unmeasured_targets=0
rss_exited_targets=0
rss_identity_mismatch_targets=0
rss_target=4242|262144|131072|measured
batch_calls=1
fallback_calls=0
RESULT
EOF
chmod +x "${temporary_root}/reduce-memory-native"

common_env=(
  "REDUCE_MEMORY_TEST_MODE=1"
  "REDUCE_MEMORY_TEST_ROOT=${temporary_root}"
  "REDUCE_MEMORY_TEST_EFFECTIVE_UID=0"
  "REDUCE_MEMORY_KERNEL_NAME=Linux"
  "REDUCE_MEMORY_MEMINFO_FILE=${temporary_root}/meminfo"
  "REDUCE_MEMORY_VM_ROOT=${temporary_root}/vm"
  "REDUCE_MEMORY_TARGET_CGROUP=${temporary_root}/cgroup"
  "REDUCE_MEMORY_NATIVE_HELPER=${temporary_root}/reduce-memory-native"
  "REDUCE_MEMORY_SYNC_COMMAND=${temporary_root}/fake-sync"
  "REDUCE_MEMORY_TARGET_UID=1000"
  "REDUCE_MEMORY_SETTLE_SECONDS=0"
  "REDUCE_MEMORY_AGGRESSIVE_STABILIZE_SECONDS=1"
  "PATH=${temporary_root}/bin:/usr/bin:/bin"
)

aggressive_output="$(env "${common_env[@]}" REDUCE_MEMORY_RECLAIM_MB=1024 "${repository_root}/linux/ReduceMemory_Linux.sh" aggressive)"
assert_output_contains "${aggressive_output}" 'Process RSS change      : +128 MB'
assert_output_contains "${aggressive_output}" 'Measured RSS targets    : 1'

# Oversized kernel metadata must be ignored before Bash arithmetic. The
# bounded request remains the explicit 1024 MiB fixture value, not an overflow
# or negative number derived from memory.current.
printf '%s\n' '99999999999999999999' > "${temporary_root}/cgroup/memory.current"
bounded_output="$(env "${common_env[@]}" REDUCE_MEMORY_RECLAIM_MB=1024 "${repository_root}/linux/ReduceMemory_Linux.sh" aggressive)"
assert_output_contains "${bounded_output}" 'cgroup memory.reclaim   : done (1024 MB requested;'

cat > "${temporary_root}/reduce-memory-native" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "reclaim" ]]; then
  session=""; path=""; bytes=""; previous=""
  for argument in "$@"; do
    [[ "${previous}" == "--session" ]] && session="${argument}"
    [[ "${previous}" == "--path" ]] && path="${argument}"
    [[ "${previous}" == "--bytes" ]] && bytes="${argument}"
    previous="${argument}"
  done
  printf '%s' "${bytes}" > "${path}"
  printf 'protocol=2\nsession=%s\nnative_status=done\n' "${session}"
  exit 0
fi
session=""
previous=""
for argument in "$@"; do
  [[ "${previous}" == "--session" ]] && session="${argument}"
  previous="${argument}"
done
printf 'protocol=2\nsession=%s\n' "${session}"
cat <<'RESULT'
native_status=done
processes_seen=1
processes_eligible=1
processes_advised=1
processes_failed=0
processes_active_skipped=0
processes_protected=0
workloads_protected=0
mappings_advised=1
mappings_failed=0
bytes_advised=33554432
rss_before_kb=131072
rss_after_kb=163840
rss_delta_kb=-32768
rss_reduced_kb=0
rss_measured_targets=1
rss_unmeasured_targets=0
rss_exited_targets=0
rss_identity_mismatch_targets=0
rss_target=4343|131072|163840|measured
batch_calls=1
fallback_calls=0
RESULT
EOF
chmod +x "${temporary_root}/reduce-memory-native"
normal_output="$(env "${common_env[@]}" "${repository_root}/linux/ReduceMemory_Linux.sh" normal)"
assert_output_contains "${normal_output}" 'Process RSS change      : -32 MB'

cat > "${temporary_root}/invalidate-available" <<'EOF'
#!/usr/bin/env bash
sed -i 's/^MemAvailable:.*/MemAvailable:   unavailable kB/' "${REDUCE_MEMORY_MEMINFO_FILE:?}"
EOF
chmod +x "${temporary_root}/invalidate-available"
write_meminfo 10485760
unknown_env=("${common_env[@]}")
for index in "${!unknown_env[@]}"; do
  if [[ "${unknown_env[${index}]}" == REDUCE_MEMORY_SYNC_COMMAND=* ]]; then
    unknown_env[${index}]="REDUCE_MEMORY_SYNC_COMMAND=${temporary_root}/invalidate-available"
  fi
done
unknown_output="$(env "${unknown_env[@]}" "${repository_root}/linux/ReduceMemory_Linux.sh" normal)"
assert_output_contains "${unknown_output}" 'Available change        : unknown'

cat > "${temporary_root}/reduce-memory-native" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "reclaim" ]]; then
  session=""; path=""; bytes=""; previous=""
  for argument in "$@"; do
    [[ "${previous}" == "--session" ]] && session="${argument}"
    [[ "${previous}" == "--path" ]] && path="${argument}"
    [[ "${previous}" == "--bytes" ]] && bytes="${argument}"
    previous="${argument}"
  done
  printf '%s' "${bytes}" > "${path}"
  printf 'protocol=2\nsession=%s\nnative_status=done\n' "${session}"
  exit 0
fi
session=""
previous=""
for argument in "$@"; do
  [[ "${previous}" == "--session" ]] && session="${argument}"
  previous="${argument}"
done
printf 'protocol=2\nsession=%s\n' "${session}"
state_file="${REDUCE_MEMORY_TEST_ROOT:?}/native-pass-count"
pass=0
[[ -r "${state_file}" ]] && pass="$(<"${state_file}")"
pass=$((pass + 1))
printf '%s\n' "${pass}" > "${state_file}"
cat <<'RESULT'
native_status=done
processes_seen=1
processes_eligible=1
processes_advised=1
processes_failed=0
processes_active_skipped=0
processes_protected=0
workloads_protected=0
mappings_advised=1
mappings_failed=0
bytes_advised=268435456
batch_calls=1
fallback_calls=0
RESULT
if (( pass == 1 )); then
  cat <<'RESULT'
rss_before_kb=262144
rss_after_kb=0
rss_delta_kb=0
rss_reduced_kb=0
rss_measured_targets=0
rss_unmeasured_targets=1
rss_exited_targets=1
rss_identity_mismatch_targets=0
rss_target=4444|262144|unknown|exited
RESULT
else
  cat <<'RESULT'
rss_before_kb=262144
rss_after_kb=131072
rss_delta_kb=131072
rss_reduced_kb=131072
rss_measured_targets=1
rss_unmeasured_targets=0
rss_exited_targets=0
rss_identity_mismatch_targets=0
rss_target=4444|262144|131072|measured
RESULT
fi
EOF
chmod +x "${temporary_root}/reduce-memory-native"
rm -f "${temporary_root}/native-pass-count"
write_meminfo 10485760
sticky_unknown_output="$(env "${common_env[@]}" REDUCE_MEMORY_RECLAIM_MB=1024 "${repository_root}/linux/ReduceMemory_Linux.sh" aggressive)"
assert_output_contains "${sticky_unknown_output}" 'Process RSS change      : unknown'
assert_output_contains "${sticky_unknown_output}" 'Measured RSS targets    : 0'
assert_output_contains "${sticky_unknown_output}" 'Unmeasured advised      : 1'
if grep -F 'Process RSS change      : +0 MB' <<< "${sticky_unknown_output}" >/dev/null; then
  printf 'An unknown after-read must not be reported as a measured zero change.\n' >&2
  exit 1
fi

printf 'Linux session measurement accounting passed.\n'
