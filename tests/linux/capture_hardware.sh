#!/usr/bin/env bash
set -euo pipefail

# Read-only topology/provenance capture for the Phase 2 hardware gate.  This
# deliberately records unknown values instead of manufacturing a platform
# capability claim.  The file is key/value text so it can be inspected on a
# runner without jq or another dependency.

output_path="${1:?output path is required}"
output_dir="${output_path%/*}"
if [[ "${output_dir}" == "${output_path}" ]]; then
  output_dir="."
fi
mkdir -p "${output_dir}"
temporary_path="${output_path}.tmp-$$"

meminfo_value() {
  local key="$1"
  awk -v wanted="${key}:" '$1 == wanted { print $2; exit }' /proc/meminfo 2>/dev/null || true
}

read_one_line() {
  local path="$1"
  if [[ -r "${path}" ]]; then
    tr '\n' ' ' <"${path}" | sed 's/[[:space:]]\+/ /g; s/[[:space:]]*$//'
  else
    printf 'unknown'
  fi
}

page_size="unknown"
if page_size_value="$(getconf PAGESIZE 2>/dev/null)" && [[ "${page_size_value}" =~ ^[0-9]+$ ]]; then
  page_size="${page_size_value}"
fi
pointer_bits="unknown"
if pointer_bits_value="$(getconf LONG_BIT 2>/dev/null)" && [[ "${pointer_bits_value}" =~ ^[0-9]+$ ]]; then
  pointer_bits="${pointer_bits_value}"
fi
cpu_count="unknown"
if cpu_count_value="$(nproc 2>/dev/null)" && [[ "${cpu_count_value}" =~ ^[0-9]+$ ]]; then
  cpu_count="${cpu_count_value}"
fi
numa_nodes="0"
if [[ -d /sys/devices/system/node ]]; then
  numa_nodes="$(find /sys/devices/system/node -mindepth 1 -maxdepth 1 -type d -name 'node[0-9]*' 2>/dev/null | wc -l | tr -d ' ')"
fi

total_kib="$(meminfo_value MemTotal)"
available_kib="$(meminfo_value MemAvailable)"
swap_total_kib="$(meminfo_value SwapTotal)"
swap_free_kib="$(meminfo_value SwapFree)"
for value_name in total_kib available_kib swap_total_kib swap_free_kib; do
  if [[ ! "${!value_name}" =~ ^[0-9]+$ ]]; then
    printf -v "${value_name}" '%s' unknown
  fi
done

{
  printf 'schema=phase2-hardware-v1\n'
  printf 'captured_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'kernel=%s\n' "$(uname -srvm)"
  printf 'architecture=%s\n' "$(uname -m)"
  printf 'pointer_bits=%s\n' "${pointer_bits}"
  printf 'page_size_bytes=%s\n' "${page_size}"
  printf 'cpu_count=%s\n' "${cpu_count}"
  printf 'cpu_model=%s\n' "$(awk -F': ' '/^model name/ { print $2; exit }' /proc/cpuinfo 2>/dev/null | cut -c1-160)"
  printf 'numa_nodes=%s\n' "${numa_nodes}"
  printf 'mem_total_kib=%s\n' "${total_kib}"
  printf 'mem_available_kib=%s\n' "${available_kib}"
  printf 'swap_total_kib=%s\n' "${swap_total_kib}"
  printf 'swap_free_kib=%s\n' "${swap_free_kib}"
  printf 'cgroup_v2=%s\n' "$(if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then printf true; else printf false; fi)"
  printf 'cgroup_mount=%s\n' "$(awk '$0 ~ / - cgroup2 / { print $5; exit }' /proc/self/mountinfo 2>/dev/null || true)"
  printf 'process_madvise_probe=%s\n' "$(linux/native/reduce-memory-native check | awk -F= '$1 == "native_status" { print $2; exit }')"
} >"${temporary_path}"

required_keys=(schema architecture pointer_bits page_size_bytes cpu_count numa_nodes mem_total_kib mem_available_kib swap_total_kib swap_free_kib cgroup_v2 process_madvise_probe)
for key in "${required_keys[@]}"; do
  grep -q "^${key}=" "${temporary_path}"
done

mv -f "${temporary_path}" "${output_path}"
cat "${output_path}"
