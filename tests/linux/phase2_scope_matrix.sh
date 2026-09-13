#!/usr/bin/env bash
set -euo pipefail

# Read-only live scope/capability matrix. It deliberately does not create a
# delegated cgroup or change swap/sysctl state; unavailable delegated cases
# are recorded explicitly for a later disposable privileged lab.
output_path="${1:?Usage: phase2_scope_matrix.sh OUTPUT_PATH}"
script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "${script_directory}/../.." && pwd)"
mkdir -p -- "$(dirname -- "${output_path}")"

value_or_unknown() {
  local path="$1"
  if [[ -r "${path}" ]]; then
    tr '\n' ' ' <"${path}" | sed 's/[[:space:]]\+$//'
  else
    printf 'unknown'
  fi
}

cgroup_mount="$(awk '$0 ~ / - cgroup2 / { print $5; exit }' /proc/self/mountinfo 2>/dev/null || true)"
current_cgroup="$(awk -F: '$1 == "0" { print $3; exit }' /proc/self/cgroup 2>/dev/null || true)"
scope_root="${cgroup_mount}${current_cgroup}"
reclaim_file="${scope_root%/}/memory.reclaim"
swap_total="$(awk '/^SwapTotal:/ { print $2; exit }' /proc/meminfo 2>/dev/null || true)"

{
  printf 'schema=phase2-scope-matrix-v1\n'
  printf 'source_commit=%s\n' "$(git -C "${repository_root}" rev-parse HEAD)"
  printf 'effective_uid=%s\n' "${EUID}"
  printf 'architecture=%s\n' "$(uname -m)"
  printf 'cgroup_v2=%s\n' "$(if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then printf true; else printf false; fi)"
  printf 'cgroup_mount=%s\n' "${cgroup_mount:-unknown}"
  printf 'current_cgroup=%s\n' "${current_cgroup:-unknown}"
  printf 'scope_root=%s\n' "${scope_root:-unknown}"
  printf 'memory_current=%s\n' "$(value_or_unknown "${scope_root%/}/memory.current")"
  printf 'memory_max=%s\n' "$(value_or_unknown "${scope_root%/}/memory.max")"
  printf 'memory_swap_max=%s\n' "$(value_or_unknown "${scope_root%/}/memory.swap.max")"
  printf 'memory_reclaim_present=%s\n' "$(if [[ -e "${reclaim_file}" ]]; then printf true; else printf false; fi)"
  printf 'memory_reclaim_writable=%s\n' "$(if [[ -w "${reclaim_file}" ]]; then printf true; else printf false; fi)"
  printf 'swap_total_kib=%s\n' "${swap_total:-unknown}"
  printf 'delegated_child_cgroup=status_not_exercised_read_only\n'
  printf 'namespace_mount_swap_race=status_not_exercised_read_only\n'
  printf 'scope_overlap_kernel=status_not_exercised_read_only\n'
  printf 'global_mutation_performed=false\n'
} >"${output_path}"
cat "${output_path}"
