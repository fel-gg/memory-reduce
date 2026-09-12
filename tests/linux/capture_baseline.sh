#!/usr/bin/env bash
set -euo pipefail

output_path="${1:?Usage: capture_baseline.sh OUTPUT_PATH}"
if [[ -e "${output_path}" ]]; then
  printf 'Refusing to overwrite an existing baseline: %s\n' "${output_path}" >&2
  exit 2
fi
script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "${script_directory}/../.." && pwd)"

source_commit="$(git -C "${repository_root}" rev-parse HEAD)"
source_dirty=0
if [[ -n "$(git -C "${repository_root}" status --porcelain)" ]]; then
  source_dirty=1
fi

meminfo_value() {
  local key="$1"
  awk -v wanted="${key}:" '$1 == wanted { print $2; exit }' /proc/meminfo
}

cgroup2_mount="$(awk '$3 == "cgroup2" { print $2; exit }' /proc/mounts 2>/dev/null || true)"
current_cgroup="$(awk -F: '$1 == "0" { print $3; exit }' /proc/self/cgroup 2>/dev/null || true)"
distribution="Linux"
if [[ -r /etc/os-release ]]; then
  distribution="$(awk -F= '$1 == "PRETTY_NAME" { value=substr($0, index($0, "=") + 1); gsub(/^"|"$/, "", value); print value; exit }' /etc/os-release)"
fi

temporary_output="${output_path}.tmp.$$"
mkdir -p -- "$(dirname -- "${output_path}")"
{
  printf 'schema_version=1\n'
  printf 'captured_at_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'source_commit=%s\n' "${source_commit}"
  printf 'source_dirty=%s\n' "${source_dirty}"
  printf 'distribution=%s\n' "${distribution}"
  printf 'kernel=%s\n' "$(uname -sr)"
  printf 'architecture=%s\n' "$(uname -m)"
  printf 'effective_uid=%s\n' "${EUID}"
  printf 'python=%s\n' "$(python3 --version 2>&1)"
  printf 'mem_total_kib=%s\n' "$(meminfo_value MemTotal)"
  printf 'mem_available_kib=%s\n' "$(meminfo_value MemAvailable)"
  printf 'swap_total_kib=%s\n' "$(meminfo_value SwapTotal)"
  printf 'swap_free_kib=%s\n' "$(meminfo_value SwapFree)"
  printf 'cgroup2_mount=%s\n' "${cgroup2_mount:-unavailable}"
  printf 'current_cgroup=%s\n' "${current_cgroup:-unavailable}"
  printf 'launcher_sha256=%s\n' "$(sha256sum "${repository_root}/linux/ReduceMemory_Linux.sh" | awk '{ print $1 }')"
  printf 'native_helper_sha256=%s\n' "$(sha256sum "${repository_root}/linux/native/reduce-memory-native" | awk '{ print $1 }')"
  printf 'global_memory_mutation_allowed=false\n'
} > "${temporary_output}"
mv -- "${temporary_output}" "${output_path}"
printf 'Linux M0 baseline recorded at %s\n' "${output_path}"
