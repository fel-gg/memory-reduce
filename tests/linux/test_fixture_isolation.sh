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

set +e
output="$(
  REDUCE_MEMORY_TEST_MODE=1 \
  REDUCE_MEMORY_TEST_ROOT="${temporary_root}" \
  REDUCE_MEMORY_MEMINFO_FILE="${temporary_root}/meminfo" \
  "${repository_root}/linux/ReduceMemory_Linux.sh" check 2>&1
)"
exit_code=$?
set -e

if [[ "${exit_code}" -ne 2 ]]; then
  printf 'Expected isolated test mode to fail with exit 2, got %s\n%s\n' "${exit_code}" "${output}" >&2
  exit 1
fi
grep -F 'wajib menunjuk fixture disposable' <<< "${output}" >/dev/null

set +e
outside_output="$(
  REDUCE_MEMORY_TEST_MODE=1 \
  REDUCE_MEMORY_TEST_ROOT="${temporary_root}" \
  REDUCE_MEMORY_MEMINFO_FILE="${temporary_root}/meminfo" \
  REDUCE_MEMORY_VM_ROOT="${temporary_root}/vm" \
  REDUCE_MEMORY_TARGET_CGROUP="${temporary_root}/cgroup" \
  REDUCE_MEMORY_NATIVE_HELPER=/bin/true \
  REDUCE_MEMORY_SYNC_COMMAND="${temporary_root}/fake-sync" \
  REDUCE_MEMORY_TEST_EFFECTIVE_UID=0 \
  "${repository_root}/linux/ReduceMemory_Linux.sh" check 2>&1
)"
outside_exit_code=$?
set -e
if [[ "${outside_exit_code}" -ne 2 ]]; then
  printf 'Expected out-of-root adapter to fail with exit 2, got %s\n%s\n' "${outside_exit_code}" "${outside_output}" >&2
  exit 1
fi
grep -F 'berada di luar REDUCE_MEMORY_TEST_ROOT' <<< "${outside_output}" >/dev/null
printf 'Linux fixture-isolation guard passed.\n'
