#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"
script_directory="$(cd -- "$(dirname -- "${script_path}")" && pwd)"
program_title="Reduce Memory 2.8 - Linux"
server_mode=0
if [[ "${script_path##*/}" == "reduce-memory-server" ]]; then
  program_title="Reduce Memory 2.8 - Linux Server"
  server_mode=1
fi

# Alternate roots let CI execute the real reclaim paths against disposable
# files instead of changing the runner host.
proc_root="${REDUCE_MEMORY_PROC_ROOT:-/proc}"
meminfo_file="${REDUCE_MEMORY_MEMINFO_FILE:-${proc_root}/meminfo}"
vm_root="${REDUCE_MEMORY_VM_ROOT:-${proc_root}/sys/vm}"
settle_seconds="${REDUCE_MEMORY_SETTLE_SECONDS:-1}"
protected_pid="${REDUCE_MEMORY_PROTECT_PID:-}"
default_ai_patterns="ollama|vllm|llama-server|llama.cpp|text-generation|tritonserver|torchrun|stable-diffusion|comfyui|automatic1111|invokeai|localai|koboldcpp|open-webui"
ai_patterns="${REDUCE_MEMORY_AI_PATTERNS:-${default_ai_patterns}}"

kernel_name="${REDUCE_MEMORY_KERNEL_NAME:-$(uname -s)}"
if [[ "${kernel_name}" != "Linux" ]]; then
  echo "Script ini membutuhkan kernel Linux asli atau WSL2, bukan Git Bash/MSYS." >&2
  exit 3
fi

if [[ ! -r "${meminfo_file}" ]]; then
  echo "Linux meminfo tidak tersedia: ${meminfo_file}" >&2
  exit 3
fi

for required_command in awk sync; do
  if ! command -v "${required_command}" >/dev/null 2>&1; then
    echo "Perintah '${required_command}' tidak tersedia di sistem ini." >&2
    exit 7
  fi
done

if [[ ! "${settle_seconds}" =~ ^[0-9]+$ ]]; then
  echo "REDUCE_MEMORY_SETTLE_SECONDS harus berupa angka bulat positif atau nol." >&2
  exit 2
fi

meminfo_kb() {
  local key="$1"
  awk -v wanted="${key}:" '$1 == wanted { print $2; exit }' "${meminfo_file}"
}

require_numeric_meminfo() {
  local key="$1"
  local value
  value="$(meminfo_kb "${key}")"
  if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
    echo "${key} tidak dapat dibaca dari ${meminfo_file}." >&2
    return 4
  fi
  printf '%s\n' "${value}"
}

cache_kb() {
  local cached_kb
  local reclaimable_kb
  local shared_kb
  local result_kb
  cached_kb="$(require_numeric_meminfo Cached)"
  reclaimable_kb="$(require_numeric_meminfo SReclaimable)"
  shared_kb="$(require_numeric_meminfo Shmem)"
  result_kb=$((cached_kb + reclaimable_kb - shared_kb))
  if (( result_kb < 0 )); then
    result_kb=0
  fi
  printf '%s\n' "${result_kb}"
}

distribution_name() {
  local os_release_file="${REDUCE_MEMORY_OS_RELEASE_FILE:-/etc/os-release}"
  local pretty_name="Linux"
  if [[ -r "${os_release_file}" ]]; then
    pretty_name="$(awk -F= '$1 == "PRETTY_NAME" { value=substr($0, index($0, "=") + 1); gsub(/^\"|\"$/, "", value); print value; exit }' "${os_release_file}")"
  fi
  printf '%s\n' "${pretty_name:-Linux}"
}

require_root() {
  local selected_mode="$1"
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Mode '${selected_mode}' membutuhkan administrator/root." >&2
    echo "Jalankan: sudo ${script_path} ${selected_mode}" >&2
    return 5
  fi
}

drop_caches_file() {
  printf '%s/drop_caches\n' "${vm_root}"
}

require_drop_caches() {
  local target_file
  target_file="$(drop_caches_file)"
  if [[ ! -w "${target_file}" ]]; then
    echo "${target_file} tidak dapat ditulis pada sistem ini." >&2
    return 6
  fi
}

detect_cgroup2_root() {
  local detected_root=""
  if [[ -n "${REDUCE_MEMORY_CGROUP_ROOT:-}" ]]; then
    printf '%s\n' "${REDUCE_MEMORY_CGROUP_ROOT%/}"
    return 0
  fi

  if [[ -r "${proc_root}/self/mountinfo" ]]; then
    detected_root="$(awk '$0 ~ / - cgroup2 / { print $5; exit }' "${proc_root}/self/mountinfo")"
  fi

  if [[ -z "${detected_root}" && -d /sys/fs/cgroup ]]; then
    detected_root="/sys/fs/cgroup"
  fi

  [[ -n "${detected_root}" ]] || return 1
  printf '%s\n' "${detected_root%/}"
}

current_cgroup_path() {
  if [[ -r "${proc_root}/self/cgroup" ]]; then
    awk -F: '$1 == "0" { print $3; exit }' "${proc_root}/self/cgroup"
  fi
}

find_reclaim_file() {
  local cgroup_root
  local current_path
  local candidate
  local original_uid="${REDUCE_MEMORY_TARGET_UID:-${SUDO_UID:-}}"

  if [[ -n "${REDUCE_MEMORY_TARGET_CGROUP:-}" ]]; then
    candidate="${REDUCE_MEMORY_TARGET_CGROUP%/}/memory.reclaim"
    [[ -e "${candidate}" ]] || return 1
    printf '%s\n' "${candidate}"
    return 0
  fi

  cgroup_root="$(detect_cgroup2_root)" || return 1

  # Prefer the user slice so an aggressive desktop/server pass reclaims user
  # applications without applying the request to kernel/system services.
  candidate="${cgroup_root}/user.slice/memory.reclaim"
  if [[ -e "${candidate}" ]]; then
    printf '%s\n' "${candidate}"
    return 0
  fi

  # Some systemd/kernel combinations only expose reclaim below the root.
  if [[ "${original_uid}" =~ ^[0-9]+$ ]] && [[ "${original_uid}" != "0" ]]; then
    candidate="${cgroup_root}/user.slice/user-${original_uid}.slice/memory.reclaim"
    if [[ -e "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  fi

  current_path="$(current_cgroup_path)"
  if [[ -n "${current_path}" && "${current_path}" != "/" ]]; then
    candidate="${cgroup_root}${current_path}/memory.reclaim"
    if [[ -e "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  fi

  # Last-resort cgroup v2 fallback. The kernel still decides which reclaimable
  # pages can be released and the write never terminates a process.
  candidate="${cgroup_root}/memory.reclaim"
  if [[ -e "${candidate}" ]]; then
    printf '%s\n' "${candidate}"
    return 0
  fi

  return 1
}

find_native_helper() {
  local candidate
  if [[ -n "${REDUCE_MEMORY_NATIVE_HELPER:-}" ]]; then
    candidate="${REDUCE_MEMORY_NATIVE_HELPER}"
    [[ -x "${candidate}" ]] || return 1
    printf '%s\n' "${candidate}"
    return 0
  fi

  for candidate in \
    "${script_directory}/reduce-memory-native" \
    "${script_directory}/native/reduce-memory-native"; do
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done
  return 1
}

native_value() {
  local output="$1"
  local key="$2"
  awk -F= -v wanted="${key}" '$1 == wanted { print substr($0, index($0, "=") + 1); exit }' <<< "${output}"
}

numeric_or_zero() {
  local value="${1:-}"
  if [[ "${value}" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "${value}"
  else
    printf '0\n'
  fi
}

detect_active_application_pid() {
  local detected_pid=""
  local active_window=""

  if command -v xdotool >/dev/null 2>&1; then
    detected_pid="$(xdotool getactivewindow getwindowpid 2>/dev/null || true)"
  fi

  if [[ ! "${detected_pid}" =~ ^[0-9]+$ ]] && command -v xprop >/dev/null 2>&1; then
    active_window="$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk -F' ' '{ print $NF }')"
    if [[ "${active_window}" =~ ^0x[0-9a-fA-F]+$ && "${active_window}" != "0x0" ]]; then
      detected_pid="$(xprop -id "${active_window}" _NET_WM_PID 2>/dev/null | awk -F' = ' 'NF == 2 { print $2 }')"
    fi
  fi

  if [[ "${detected_pid}" =~ ^[0-9]+$ ]] && (( detected_pid > 1 )); then
    printf '%s\n' "${detected_pid}"
  fi
}

default_reclaim_mb() {
  local total_mb
  local target_mb
  total_mb=$(( $(require_numeric_meminfo MemTotal) / 1024 ))

  # Aggressive asks cgroup v2 for roughly 1/8 of physical RAM. This is a reclaim
  # request, not a reservation: the kernel may safely reclaim less than asked.
  target_mb=$((total_mb / 8))
  (( target_mb < 512 )) && target_mb=512
  (( target_mb > 4096 )) && target_mb=4096
  printf '%s\n' "${target_mb}"
}

reclaim_target_mb() {
  local requested_mb="${REDUCE_MEMORY_RECLAIM_MB:-}"
  local total_mb
  local maximum_mb

  if [[ -z "${requested_mb}" ]]; then
    default_reclaim_mb
    return
  fi

  if [[ ! "${requested_mb}" =~ ^[0-9]+$ ]] || (( requested_mb < 64 )); then
    echo "REDUCE_MEMORY_RECLAIM_MB harus berupa angka bulat minimal 64." >&2
    return 2
  fi

  total_mb=$(( $(require_numeric_meminfo MemTotal) / 1024 ))
  maximum_mb=$((total_mb / 2))
  (( maximum_mb < 64 )) && maximum_mb=64
  (( maximum_mb > 8192 )) && maximum_mb=8192
  if (( requested_mb > maximum_mb )); then
    requested_mb="${maximum_mb}"
  fi
  printf '%s\n' "${requested_mb}"
}

reset_stage_state() {
  stage_sync="not requested"
  stage_drop_caches="not requested"
  stage_cgroup_reclaim="not requested"
  stage_native_pageout="not requested"
  reclaim_scope="-"
  reclaim_request_mb=0
  native_processes_seen=0
  native_processes_advised=0
  native_processes_active_skipped=0
  native_processes_protected=0
  native_workloads_protected=0
  native_mappings_advised=0
  native_bytes_advised=0
  native_rss_reduced_kb=0
  native_pageout_passes=0
  native_batch_calls=0
  native_fallback_calls=0
}

reset_stage_state

run_sync() {
  sync
  stage_sync="done"
}

run_drop_caches() {
  local level="$1"
  local target_file
  target_file="$(drop_caches_file)"
  printf '%s\n' "${level}" > "${target_file}"
  stage_drop_caches="done (level ${level})"
}

run_native_pageout() {
  local profile="${1:-default}"
  local native_helper
  local target_uid="${REDUCE_MEMORY_TARGET_UID:-${SUDO_UID:-}}"
  local native_output=""
  local native_exit=0
  local arguments=(pageout)
  local minimum_rss_mb
  local minimum_mapping_kb
  local activity_ms
  local active_ticks
  local native_settle_ms
  local pass_status
  local pass_processes_seen
  local pass_processes_advised
  local pass_processes_active_skipped
  local pass_processes_protected
  local pass_workloads_protected
  local pass_mappings_advised
  local pass_bytes_advised
  local pass_rss_reduced_kb
  local pass_batch_calls
  local pass_fallback_calls

  if ! command -v python3 >/dev/null 2>&1; then
    stage_native_pageout="unavailable; python3 not installed"
    return 0
  fi
  if ! native_helper="$(find_native_helper)"; then
    stage_native_pageout="unavailable; helper not installed"
    return 0
  fi

  # Aggressive is system-wide for normal user accounts. The dedicated Server
  # build additionally scans non-root service UIDs below 1000; Desktop
  # Normal/Smooth/AI stay on the invoking account unless explicitly expanded.
  if [[ "${REDUCE_MEMORY_ALL_USERS:-0}" == "1" || "${REDUCE_MEMORY_INCLUDE_SERVICE_USERS:-0}" == "1" || "${profile}" == "aggressive" || "${server_mode}" == "1" ]]; then
    arguments+=(--all-users)
  elif [[ "${target_uid}" =~ ^[0-9]+$ ]] && (( target_uid > 0 )); then
    arguments+=(--uid "${target_uid}")
  else
    stage_native_pageout="skipped; target UID unavailable"
    return 0
  fi
  if [[ "${server_mode}" == "1" || "${REDUCE_MEMORY_INCLUDE_SERVICE_USERS:-0}" == "1" ]]; then
    arguments+=(--include-service-users)
  fi

  case "${profile}" in
    normal)
      minimum_rss_mb="${REDUCE_MEMORY_NORMAL_MIN_RSS_MB:-256}"
      minimum_mapping_kb="${REDUCE_MEMORY_NORMAL_MIN_MAPPING_KB:-4096}"
      activity_ms="${REDUCE_MEMORY_NORMAL_ACTIVITY_MS:-700}"
      active_ticks="${REDUCE_MEMORY_NORMAL_ACTIVE_TICKS:-0}"
      native_settle_ms="${REDUCE_MEMORY_NORMAL_SETTLE_MS:-350}"
      ;;
    smooth)
      minimum_rss_mb="${REDUCE_MEMORY_SMOOTH_MIN_RSS_MB:-128}"
      minimum_mapping_kb="${REDUCE_MEMORY_SMOOTH_MIN_MAPPING_KB:-2048}"
      activity_ms="${REDUCE_MEMORY_SMOOTH_ACTIVITY_MS:-500}"
      active_ticks="${REDUCE_MEMORY_SMOOTH_ACTIVE_TICKS:-0}"
      native_settle_ms="${REDUCE_MEMORY_SMOOTH_SETTLE_MS:-500}"
      ;;
    aggressive)
      minimum_rss_mb="${REDUCE_MEMORY_AGGRESSIVE_MIN_RSS_MB:-32}"
      minimum_mapping_kb="${REDUCE_MEMORY_AGGRESSIVE_MIN_MAPPING_KB:-256}"
      activity_ms="${REDUCE_MEMORY_AGGRESSIVE_ACTIVITY_MS:-150}"
      active_ticks="${REDUCE_MEMORY_AGGRESSIVE_ACTIVE_TICKS:-1}"
      native_settle_ms="${REDUCE_MEMORY_AGGRESSIVE_SETTLE_MS:-750}"
      ;;
    ai-shield|*)
      minimum_rss_mb="${REDUCE_MEMORY_MIN_RSS_MB:-64}"
      minimum_mapping_kb="${REDUCE_MEMORY_MIN_MAPPING_KB:-1024}"
      activity_ms="${REDUCE_MEMORY_ACTIVITY_MS:-300}"
      active_ticks="${REDUCE_MEMORY_ACTIVE_TICKS:-0}"
      native_settle_ms="${REDUCE_MEMORY_NATIVE_SETTLE_MS:-500}"
      ;;
  esac

  arguments+=(
    --min-rss-mb "${minimum_rss_mb}"
    --min-mapping-kb "${minimum_mapping_kb}"
    --activity-ms "${activity_ms}"
    --active-ticks "${active_ticks}"
    --settle-ms "${native_settle_ms}"
  )

  # AI/GPU recognition belongs only to AI Shield. Normal, Smooth and
  # Aggressive remain application-agnostic so present and future software is
  # handled from kernel/process state instead of a hard-coded name list.
  if [[ "${profile}" == "ai-shield" ]]; then
    if [[ "${REDUCE_MEMORY_PROTECT_GPU:-1}" == "1" ]]; then
      arguments+=(--protect-gpu)
    fi
    local ai_pattern
    local ai_pattern_list=()
    IFS='|' read -r -a ai_pattern_list <<< "${ai_patterns}"
    for ai_pattern in "${ai_pattern_list[@]}"; do
      [[ -n "${ai_pattern}" ]] && arguments+=(--protect-pattern "${ai_pattern}")
    done
  fi
  if [[ "${protected_pid}" =~ ^[0-9]+$ ]] && (( protected_pid > 1 )); then
    arguments+=(--exclude-pid "${protected_pid}")
  fi

  native_output="$("${native_helper}" "${arguments[@]}" 2>&1)" || native_exit=$?
  pass_status="$(native_value "${native_output}" native_status)"
  [[ -n "${pass_status}" ]] || pass_status="failed (exit ${native_exit})"
  native_pageout_passes=$((native_pageout_passes + 1))
  if [[ "${stage_native_pageout}" == "not requested" ]]; then
    stage_native_pageout="pass${native_pageout_passes}=${pass_status}"
  else
    stage_native_pageout+="; pass${native_pageout_passes}=${pass_status}"
  fi

  pass_processes_seen="$(native_value "${native_output}" processes_seen)"
  pass_processes_advised="$(native_value "${native_output}" processes_advised)"
  pass_processes_active_skipped="$(native_value "${native_output}" processes_active_skipped)"
  pass_processes_protected="$(native_value "${native_output}" processes_protected)"
  pass_workloads_protected="$(native_value "${native_output}" workloads_protected)"
  pass_mappings_advised="$(native_value "${native_output}" mappings_advised)"
  pass_bytes_advised="$(native_value "${native_output}" bytes_advised)"
  pass_rss_reduced_kb="$(native_value "${native_output}" rss_reduced_kb)"
  pass_batch_calls="$(native_value "${native_output}" batch_calls)"
  pass_fallback_calls="$(native_value "${native_output}" fallback_calls)"

  pass_processes_seen="$(numeric_or_zero "${pass_processes_seen}")"
  pass_processes_advised="$(numeric_or_zero "${pass_processes_advised}")"
  pass_processes_active_skipped="$(numeric_or_zero "${pass_processes_active_skipped}")"
  pass_processes_protected="$(numeric_or_zero "${pass_processes_protected}")"
  pass_workloads_protected="$(numeric_or_zero "${pass_workloads_protected}")"
  pass_mappings_advised="$(numeric_or_zero "${pass_mappings_advised}")"
  pass_bytes_advised="$(numeric_or_zero "${pass_bytes_advised}")"
  pass_rss_reduced_kb="$(numeric_or_zero "${pass_rss_reduced_kb}")"
  pass_batch_calls="$(numeric_or_zero "${pass_batch_calls}")"
  pass_fallback_calls="$(numeric_or_zero "${pass_fallback_calls}")"

  native_processes_seen=$((native_processes_seen + pass_processes_seen))
  native_processes_advised=$((native_processes_advised + pass_processes_advised))
  native_processes_active_skipped=$((native_processes_active_skipped + pass_processes_active_skipped))
  native_processes_protected=$((native_processes_protected + pass_processes_protected))
  native_workloads_protected=$((native_workloads_protected + pass_workloads_protected))
  native_mappings_advised=$((native_mappings_advised + pass_mappings_advised))
  native_bytes_advised=$((native_bytes_advised + pass_bytes_advised))
  native_rss_reduced_kb=$((native_rss_reduced_kb + pass_rss_reduced_kb))
  native_batch_calls=$((native_batch_calls + pass_batch_calls))
  native_fallback_calls=$((native_fallback_calls + pass_fallback_calls))
}

run_cgroup_reclaim() {
  local reclaim_file
  local swap_total_kb
  local requested_swappiness
  local reclaim_payload
  reclaim_request_mb="$(reclaim_target_mb)"

  if ! reclaim_file="$(find_reclaim_file)"; then
    stage_cgroup_reclaim="unsupported; cache-only fallback"
    return 0
  fi

  reclaim_scope="${reclaim_file%/memory.reclaim}"
  if [[ ! -w "${reclaim_file}" ]]; then
    stage_cgroup_reclaim="available but not writable"
    return 0
  fi

  swap_total_kb="$(require_numeric_meminfo SwapTotal)"
  requested_swappiness="${REDUCE_MEMORY_RECLAIM_SWAPPINESS:-}"
  if [[ -z "${requested_swappiness}" ]]; then
    if (( swap_total_kb > 0 )); then
      requested_swappiness="max"
    else
      requested_swappiness="default"
    fi
  fi
  if [[ "${requested_swappiness}" != "default" && "${requested_swappiness}" != "max" && ! "${requested_swappiness}" =~ ^([0-9]|[1-9][0-9]|1[0-9][0-9]|200)$ ]]; then
    echo "REDUCE_MEMORY_RECLAIM_SWAPPINESS harus default, max, atau angka 0-200." >&2
    return 2
  fi

  reclaim_payload="${reclaim_request_mb}M"
  if [[ "${requested_swappiness}" != "default" && ${swap_total_kb} -gt 0 ]]; then
    reclaim_payload+=" swappiness=${requested_swappiness}"
  fi

  # Newer cgroup v2 kernels accept a nested swappiness key. Aggressive uses it
  # when swap exists so anonymous pages can participate instead of reclaiming
  # file cache only. Older kernels transparently fall back to the plain syntax.
  if { printf '%s\n' "${reclaim_payload}" > "${reclaim_file}"; } 2>/dev/null; then
    stage_cgroup_reclaim="done (${reclaim_request_mb} MB requested) | swappiness=${requested_swappiness}"
  elif [[ "${reclaim_payload}" != "${reclaim_request_mb}M" ]] && { printf '%sM\n' "${reclaim_request_mb}" > "${reclaim_file}"; } 2>/dev/null; then
    stage_cgroup_reclaim="done (${reclaim_request_mb} MB requested) | plain compatibility fallback"
  else
    stage_cgroup_reclaim="partial or refused (${reclaim_request_mb} MB requested)"
  fi
}

signed_mb() {
  local value_kb="$1"
  printf '%+d MB' "$((value_kb / 1024))"
}

print_result() {
  local selected_mode="$1"
  local before_available_kb="$2"
  local before_cache_kb="$3"
  local before_anon_kb="$4"
  local before_swap_used_kb="$5"
  local after_available_kb="$6"
  local after_cache_kb="$7"
  local after_anon_kb="$8"
  local after_swap_used_kb="$9"
  local available_delta_kb=$((after_available_kb - before_available_kb))
  local cache_released_kb=$((before_cache_kb - after_cache_kb))
  local anon_released_kb=$((before_anon_kb - after_anon_kb))
  local swap_delta_kb=$((after_swap_used_kb - before_swap_used_kb))
  local current_swap_total_kb
  current_swap_total_kb="$(require_numeric_meminfo SwapTotal)"

  printf '\nSystem                  : %s\n' "$(distribution_name)"
  printf 'Kernel                  : %s\n' "$(uname -r)"
  printf 'Mode                    : %s\n' "${selected_mode}"
  printf 'Available before        : %d MB\n' "$((before_available_kb / 1024))"
  printf 'Available after         : %d MB\n' "$((after_available_kb / 1024))"
  printf 'Available change        : %s\n' "$(signed_mb "${available_delta_kb}")"
  printf 'File cache released     : %s\n' "$(signed_mb "${cache_released_kb}")"
  printf 'Anonymous RAM change    : %s\n' "$(signed_mb "${anon_released_kb}")"
  printf 'Swap usage change       : %s\n' "$(signed_mb "${swap_delta_kb}")"
  printf 'Swap current            : %d / %d MB used\n' \
    "$((after_swap_used_kb / 1024))" "$((current_swap_total_kb / 1024))"
  if [[ "${selected_mode}" == "check" || "${selected_mode}" == "status" ]]; then
  printf 'Default Aggressive ask  : %d MB\n' "$(default_reclaim_mb)"
  fi
  printf 'Kernel sync             : %s\n' "${stage_sync}"
  printf 'Native process page-out : %s\n' "${stage_native_pageout}"
  if [[ "${stage_native_pageout}" != "not requested" ]]; then
    printf 'Native page-out passes  : %s\n' "${native_pageout_passes}"
    printf 'Processes scanned       : %s\n' "${native_processes_seen}"
    printf 'Processes paged out     : %s\n' "${native_processes_advised}"
    printf 'Active processes skipped: %s\n' "${native_processes_active_skipped}"
    printf 'Protected processes     : %s\n' "${native_processes_protected}"
    printf 'AI/GPU workloads safe   : %s\n' "${native_workloads_protected}"
    printf 'Mappings advised        : %s\n' "${native_mappings_advised}"
    printf 'Bytes advised           : %d MB\n' "$((native_bytes_advised / 1024 / 1024))"
    printf 'Process RSS reduced     : %d MB\n' "$((native_rss_reduced_kb / 1024))"
    printf 'Batched native calls    : %s\n' "${native_batch_calls}"
    printf 'Scalar fallback calls   : %s\n' "${native_fallback_calls}"
  fi
  printf 'drop_caches             : %s\n' "${stage_drop_caches}"
  printf 'cgroup memory.reclaim   : %s\n' "${stage_cgroup_reclaim}"
  if [[ "${reclaim_scope}" != "-" ]]; then
    printf 'Reclaim scope           : %s\n' "${reclaim_scope}"
  fi

  if [[ "${selected_mode}" == "aggressive" ]] && (( $(require_numeric_meminfo SwapTotal) == 0 )); then
    printf 'Note                    : swap tidak aktif; private application RAM tidak bisa dipindahkan ke swap.\n'
  fi
}

perform_mode() {
  local selected_mode="$1"
  local before_available_kb
  local before_cache_kb
  local before_anon_kb
  local before_swap_used_kb
  local after_available_kb
  local after_cache_kb
  local after_anon_kb
  local after_swap_used_kb
  local swap_total_kb
  local reclaim_file
  local native_helper
  local native_check_output

  reset_stage_state

  before_available_kb="$(require_numeric_meminfo MemAvailable)"
  before_cache_kb="$(cache_kb)"
  before_anon_kb="$(require_numeric_meminfo AnonPages)"
  swap_total_kb="$(require_numeric_meminfo SwapTotal)"
  before_swap_used_kb=$((swap_total_kb - $(require_numeric_meminfo SwapFree)))

  case "${selected_mode}" in
    check|status)
      # Read-only capability and memory report.
      if native_helper="$(find_native_helper 2>/dev/null)" && command -v python3 >/dev/null 2>&1; then
        native_check_output="$("${native_helper}" check 2>/dev/null || true)"
        stage_native_pageout="$(native_value "${native_check_output}" native_status)"
        [[ -n "${stage_native_pageout}" ]] || stage_native_pageout="probe failed"
      elif ! command -v python3 >/dev/null 2>&1; then
        stage_native_pageout="unavailable; python3 not installed"
      else
        stage_native_pageout="unavailable; helper not installed"
      fi
      if reclaim_file="$(find_reclaim_file 2>/dev/null)"; then
        stage_cgroup_reclaim="available via ${reclaim_file}"
      else
        stage_cgroup_reclaim="unavailable; Aggressive uses cache-only fallback"
      fi
      ;;
    normal)
      # Normal remains safe for scripts without root (sync only), but when the
      # launcher has elevated it the native engine also pages out only large,
      # clearly idle applications using its conservative Linux profile.
      run_sync
      if [[ "${EUID}" -eq 0 ]]; then
        run_native_pageout normal
      else
        stage_native_pageout="root not granted; sync-only fallback"
      fi
      ;;
    smooth)
      require_root "${selected_mode}"
      require_drop_caches
      run_sync
      run_native_pageout smooth
      run_sync
      run_drop_caches 1
      ;;
    ai-shield)
      require_root "${selected_mode}"
      run_sync
      run_native_pageout ai-shield
      ;;
    aggressive)
      require_root "${selected_mode}"
      require_drop_caches
      run_sync
      run_native_pageout aggressive
      run_sync
      run_drop_caches 3
      run_cgroup_reclaim
      run_native_pageout aggressive
      ;;
    *)
      echo "Mode tidak dikenal: ${selected_mode}" >&2
      return 2
      ;;
  esac

  if (( settle_seconds > 0 )) && [[ "${selected_mode}" != "check" && "${selected_mode}" != "status" ]]; then
    sleep "${settle_seconds}"
  fi

  after_available_kb="$(require_numeric_meminfo MemAvailable)"
  after_cache_kb="$(cache_kb)"
  after_anon_kb="$(require_numeric_meminfo AnonPages)"
  swap_total_kb="$(require_numeric_meminfo SwapTotal)"
  after_swap_used_kb=$((swap_total_kb - $(require_numeric_meminfo SwapFree)))

  print_result \
    "${selected_mode}" \
    "${before_available_kb}" "${before_cache_kb}" "${before_anon_kb}" "${before_swap_used_kb}" \
    "${after_available_kb}" "${after_cache_kb}" "${after_anon_kb}" "${after_swap_used_kb}"
}

run_privileged_mode() {
  local selected_mode="$1"
  local detected_active_pid=""
  local extra_arguments=()

  if [[ "${selected_mode}" == "normal" || "${selected_mode}" == "smooth" || "${selected_mode}" == "aggressive" || "${selected_mode}" == "ai-shield" ]]; then
    detected_active_pid="$(detect_active_application_pid)"
    if [[ "${detected_active_pid}" =~ ^[0-9]+$ ]]; then
      extra_arguments+=(--protect-pid "${detected_active_pid}")
      protected_pid="${detected_active_pid}"
    fi
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    perform_mode "${selected_mode}"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo -- "${script_path}" "${selected_mode}" "${extra_arguments[@]}"
    return
  fi

  echo "Mode ${selected_mode} membutuhkan root, tetapi perintah sudo tidak tersedia." >&2
  echo "Buka terminal root lalu jalankan: ${script_path} ${selected_mode}" >&2
  return 5
}

pause_menu() {
  if [[ -t 0 ]]; then
    printf '\nTekan Enter untuk kembali ke menu...'
    read -r _ || true
  fi
}

show_menu() {
  local selection
  local confirmation
  while true; do
    if [[ -t 1 ]]; then
      printf '\033[2J\033[H'
    fi
    printf '%s\n' "${program_title}"
    printf '%s\n' '========================='
    printf 'System: %s | Kernel: %s\n' "$(distribution_name)" "$(uname -r)"
    printf 'Available: %d MB | App/anonymous: %d MB | Cache: %d MB\n\n' \
      "$(( $(require_numeric_meminfo MemAvailable) / 1024 ))" \
      "$(( $(require_numeric_meminfo AnonPages) / 1024 ))" \
      "$(( $(cache_kb) / 1024 ))"
    printf '%s\n' '1. Normal     - page-out aplikasi besar yang benar-benar idle (butuh password)'
    printf '%s\n' '2. Smooth     - page-out konservatif + file cache ringan (butuh password)'
    printf '%s\n' '3. AI Shield  - lindungi AI/GPU, page-out background idle (butuh password)'
    printf '%s\n' '4. Aggressive - page-out aplikasi + cache + cgroup (butuh password)'
    printf '%s\n' '5. Status     - metrik dan dukungan kernel, tanpa perubahan'
    printf '%s\n' '0. Exit'
    printf '\nPilih mode [1]: '

    if ! read -r selection; then
      return 0
    fi
    selection="${selection:-1}"

    case "${selection}" in
      1|normal)
        run_privileged_mode normal || true
        pause_menu
        ;;
      2|smooth)
        run_privileged_mode smooth || true
        pause_menu
        ;;
      3|ai|ai-shield)
        printf '\nAI Shield melindungi proses AI/GPU dan child process-nya.\n'
        printf 'Hanya proses background idle yang diminta keluar dari RAM; cache global tidak dibuang.\n'
        run_privileged_mode ai-shield || true
        pause_menu
        ;;
      4|aggressive)
        printf '\nAggressive meminta Linux melakukan page-out pada aplikasi idle, lalu mereclaim cache.\n'
        printf 'Jika swap aktif, aplikasi bisa terasa lambat saat halaman itu dipakai kembali.\n'
        printf 'Aplikasi aktif dan process tree-nya dilindungi; tidak ada proses yang dimatikan.\n'
        printf 'Lanjutkan? [y/N]: '
        read -r confirmation || true
        if [[ "${confirmation:-}" =~ ^[Yy]$ ]]; then
          run_privileged_mode aggressive || true
        else
          printf '\nAggressive dibatalkan.\n'
        fi
        pause_menu
        ;;
      5|check|status)
        perform_mode status || true
        pause_menu
        ;;
      0|q|Q|exit)
        return 0
        ;;
      *)
        printf '\nPilihan tidak dikenal: %s\n' "${selection}"
        pause_menu
        ;;
    esac
  done
}

show_usage() {
  printf '%s\n\n' "${program_title}"
  cat <<'EOF'
Usage:
  reduce-memory                  Buka menu jika terminal interaktif
  reduce-memory --menu           Paksa buka menu
  reduce-memory check            Metrik dan dukungan kernel; read-only
  reduce-memory status           Alias read-only untuk server
  reduce-memory normal           Sync-only fallback tanpa root
  sudo reduce-memory normal      Page-out konservatif aplikasi besar yang idle
  sudo reduce-memory smooth      Page-out konservatif + file cache ringan
  sudo reduce-memory ai-shield   Lindungi AI/GPU; page-out background idle
  sudo reduce-memory aggressive  Process page-out + cache + cgroup reclaim

Optional Aggressive setting:
  sudo REDUCE_MEMORY_RECLAIM_MB=1024 reduce-memory aggressive
EOF
}

if [[ "$#" -eq 0 ]]; then
  if [[ -t 0 && -t 1 ]]; then
    show_menu
  else
    perform_mode normal
  fi
  exit 0
fi

requested_command="$1"
shift
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --protect-pid)
      if [[ "$#" -lt 2 || ! "$2" =~ ^[0-9]+$ || "$2" -le 1 ]]; then
        echo "--protect-pid membutuhkan PID numerik lebih besar dari 1." >&2
        exit 2
      fi
      protected_pid="$2"
      shift 2
      ;;
    *)
      echo "Argumen tidak dikenal: $1" >&2
      exit 2
      ;;
  esac
done

case "${requested_command}" in
  --menu|menu)
    show_menu
    ;;
  --help|-h|help)
    show_usage
    ;;
  check|status|normal|smooth|ai-shield|aggressive)
    perform_mode "${requested_command}"
    ;;
  *)
    show_usage >&2
    exit 2
    ;;
esac
