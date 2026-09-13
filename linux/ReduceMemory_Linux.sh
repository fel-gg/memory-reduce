#!/usr/bin/env bash
set -euo pipefail

if [[ "${REDUCE_MEMORY_TEST_MODE:-0}" == "1" ]]; then
  required_test_variables=(
    REDUCE_MEMORY_TEST_ROOT
    REDUCE_MEMORY_MEMINFO_FILE
    REDUCE_MEMORY_VM_ROOT
    REDUCE_MEMORY_TARGET_CGROUP
    REDUCE_MEMORY_NATIVE_HELPER
    REDUCE_MEMORY_SYNC_COMMAND
    REDUCE_MEMORY_TEST_EFFECTIVE_UID
  )
  for variable_name in "${required_test_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
      echo "Test mode ditolak: ${variable_name} wajib menunjuk fixture disposable." >&2
      exit 2
    fi
  done

  test_root="$(readlink -m -- "${REDUCE_MEMORY_TEST_ROOT}")"
  case "${test_root}" in
    /|/proc|/proc/*|/sys|/sys/*)
      echo "Test mode ditolak: REDUCE_MEMORY_TEST_ROOT harus berupa direktori fixture terisolasi." >&2
      exit 2
      ;;
  esac
  fixture_path_variables=(
    REDUCE_MEMORY_MEMINFO_FILE
    REDUCE_MEMORY_VM_ROOT
    REDUCE_MEMORY_TARGET_CGROUP
    REDUCE_MEMORY_NATIVE_HELPER
    REDUCE_MEMORY_SYNC_COMMAND
  )
  for variable_name in "${fixture_path_variables[@]}"; do
    fixture_path="$(readlink -m -- "${!variable_name}")"
    case "${fixture_path}" in
      "${test_root}"/*) ;;
      *)
        echo "Test mode ditolak: ${variable_name} berada di luar REDUCE_MEMORY_TEST_ROOT." >&2
        exit 2
        ;;
    esac
  done
fi

script_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"
script_directory="$(cd -- "$(dirname -- "${script_path}")" && pwd)"
  program_title="Reduce Memory 4.0 - Linux"
server_mode=0
if [[ "${script_path##*/}" == "reduce-memory-server" ]]; then
  program_title="Reduce Memory 4.0 - Linux Server"
  server_mode=1
fi

# Alternate roots let CI execute the real reclaim paths against disposable
# files instead of changing the runner host.
proc_root="${REDUCE_MEMORY_PROC_ROOT:-/proc}"
meminfo_file="${REDUCE_MEMORY_MEMINFO_FILE:-${proc_root}/meminfo}"
vm_root="${REDUCE_MEMORY_VM_ROOT:-${proc_root}/sys/vm}"
sync_command="${REDUCE_MEMORY_SYNC_COMMAND:-sync}"
effective_uid="${EUID}"
if [[ "${REDUCE_MEMORY_TEST_MODE:-0}" == "1" ]]; then
  effective_uid="${REDUCE_MEMORY_TEST_EFFECTIVE_UID}"
  if [[ ! "${effective_uid}" =~ ^[0-9]+$ ]]; then
    echo "Test mode ditolak: REDUCE_MEMORY_TEST_EFFECTIVE_UID harus berupa angka." >&2
    exit 2
  fi
fi
settle_seconds="${REDUCE_MEMORY_SETTLE_SECONDS:-1}"
aggressive_stabilize_seconds="${REDUCE_MEMORY_AGGRESSIVE_STABILIZE_SECONDS:-3}"
aggressive_rebound_min_mb="${REDUCE_MEMORY_AGGRESSIVE_REBOUND_MIN_MB:-64}"
aggressive_rebound_percent="${REDUCE_MEMORY_AGGRESSIVE_REBOUND_PERCENT:-20}"
protected_pid="${REDUCE_MEMORY_PROTECT_PID:-}"
default_ai_patterns="ollama|vllm|llama-server|llama.cpp|text-generation|tritonserver|torchrun|stable-diffusion|comfyui|automatic1111|invokeai|localai|koboldcpp|open-webui"
ai_patterns="${REDUCE_MEMORY_AI_PATTERNS:-${default_ai_patterns}}"
declare -A native_rss_before_by_pid=()
declare -A native_rss_after_by_pid=()
declare -A native_rss_status_by_pid=()
declare -A native_rss_starttime_by_pid=()
declare -A native_recovery_done_by_pid=()
optimization_lock_fd=""
optimization_lock_path=""
optimization_lock_dir=""

kernel_name="${REDUCE_MEMORY_KERNEL_NAME:-$(uname -s)}"
if [[ "${kernel_name}" != "Linux" ]]; then
  echo "Script ini membutuhkan kernel Linux asli atau WSL2, bukan Git Bash/MSYS." >&2
  exit 3
fi

acquire_optimization_lock() {
  local scope="${REDUCE_MEMORY_LOCK_SCOPE:-${SUDO_UID:-${EUID}}}"
  local lock_root="${REDUCE_MEMORY_LOCK_ROOT:-${XDG_RUNTIME_DIR:-/tmp}}"
  [[ "${scope}" =~ ^[0-9]+$ ]] || scope="unknown"
  [[ "${lock_root}" == /tmp || "${lock_root}" == /tmp/* || "${lock_root}" == /run/user/* ]] || {
    echo "Lock root ditolak: ${lock_root}" >&2
    return 2
  }
  mkdir -p -- "${lock_root}" 2>/dev/null || return 2
  optimization_lock_path="${lock_root%/}/reduce-memory-${scope}.lock"
  umask 077
  eval "exec {optimization_lock_fd}>\"${optimization_lock_path}\"" || return 2
  if command -v flock >/dev/null 2>&1; then
    if ! flock -n "${optimization_lock_fd}"; then
      eval "exec ${optimization_lock_fd}>&-"
      optimization_lock_fd=""
      return 7
    fi
    return 0
  fi
  # Git Bash/minimal images may not ship util-linux flock. Use an atomic
  # mkdir lease there; stale leases are removed only when their recorded
  # owner is no longer alive.
  eval "exec ${optimization_lock_fd}>&-"
  optimization_lock_fd=""
  optimization_lock_dir="${optimization_lock_path}.d"
  if ! mkdir "${optimization_lock_dir}" 2>/dev/null; then
    local owner_pid=""
    [[ -r "${optimization_lock_dir}/owner" ]] && owner_pid="$(<"${optimization_lock_dir}/owner")"
    if [[ "${owner_pid}" =~ ^[0-9]+$ ]] && ! kill -0 "${owner_pid}" 2>/dev/null; then
      rm -f -- "${optimization_lock_dir}/owner" 2>/dev/null || true
      rmdir -- "${optimization_lock_dir}" 2>/dev/null || true
      mkdir "${optimization_lock_dir}" 2>/dev/null || return 7
    else
      return 7
    fi
  fi
  printf '%s\n' "$$" > "${optimization_lock_dir}/owner"
  return 0
}

release_optimization_lock() {
  if [[ -n "${optimization_lock_fd}" ]]; then
    flock -u "${optimization_lock_fd}" 2>/dev/null || true
    eval "exec ${optimization_lock_fd}>&-"
    optimization_lock_fd=""
  fi
  if [[ -n "${optimization_lock_dir}" ]]; then
    rm -f -- "${optimization_lock_dir}/owner" 2>/dev/null || true
    rmdir -- "${optimization_lock_dir}" 2>/dev/null || true
    optimization_lock_dir=""
  fi
}

cleanup_optimization_lock() {
  release_optimization_lock
}
trap cleanup_optimization_lock EXIT INT TERM

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
if [[ ! "${aggressive_stabilize_seconds}" =~ ^[0-9]+$ ]] || (( aggressive_stabilize_seconds < 1 || aggressive_stabilize_seconds > 15 )); then
  echo "REDUCE_MEMORY_AGGRESSIVE_STABILIZE_SECONDS harus berupa angka 1-15." >&2
  exit 2
fi
if [[ ! "${aggressive_rebound_min_mb}" =~ ^[0-9]+$ ]] || (( aggressive_rebound_min_mb < 16 || aggressive_rebound_min_mb > 2048 )); then
  echo "REDUCE_MEMORY_AGGRESSIVE_REBOUND_MIN_MB harus berupa angka 16-2048." >&2
  exit 2
fi
if [[ ! "${aggressive_rebound_percent}" =~ ^[0-9]+$ ]] || (( aggressive_rebound_percent < 5 || aggressive_rebound_percent > 80 )); then
  echo "REDUCE_MEMORY_AGGRESSIVE_REBOUND_PERCENT harus berupa angka 5-80." >&2
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

optional_numeric_meminfo() {
  local value
  value="$(meminfo_kb "$1")"
  [[ "${value}" =~ ^[0-9]+$ ]] || return 1
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

optional_cache_kb() {
  local cached_kb reclaimable_kb shared_kb
  cached_kb="$(optional_numeric_meminfo Cached)" || return 1
  reclaimable_kb="$(optional_numeric_meminfo SReclaimable)" || return 1
  shared_kb="$(optional_numeric_meminfo Shmem)" || return 1
  printf '%s\n' "$((cached_kb + reclaimable_kb - shared_kb))"
}

distribution_name() {
  local os_release_file="${REDUCE_MEMORY_OS_RELEASE_FILE:-/etc/os-release}"
  local pretty_name="Linux"
  if [[ -r "${os_release_file}" ]]; then
    pretty_name="$(awk -F= '$1 == "PRETTY_NAME" { value=substr($0, index($0, "=") + 1); gsub(/^"|"$/, "", value); print value; exit }' "${os_release_file}")"
  fi
  printf '%s\n' "${pretty_name:-Linux}"
}

require_root() {
  local selected_mode="$1"
  if [[ "${effective_uid}" -ne 0 ]]; then
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

valid_reclaim_scope() {
  local candidate="$1"
  local parent="${candidate%/memory.reclaim}"
  local normalized_candidate normalized_parent allowed_root
  [[ "${candidate##*/}" == "memory.reclaim" && -e "${candidate}" ]] || return 1
  normalized_candidate="$(readlink -m -- "${candidate}")"
  normalized_parent="$(readlink -m -- "${parent}")"
  [[ "${normalized_candidate}" == "${candidate}" && "${normalized_parent}" == "${parent}" ]] || return 1
  if [[ "${REDUCE_MEMORY_TEST_MODE:-0}" == "1" ]]; then
    allowed_root="$(readlink -m -- "${REDUCE_MEMORY_TEST_ROOT}")"
  else
    allowed_root="$(readlink -m -- "$(detect_cgroup2_root 2>/dev/null || printf '%s' /nonexistent)")"
  fi
  [[ "${allowed_root}" != "/nonexistent" && ( "${parent}" == "${allowed_root}" || "${parent}" == "${allowed_root}"/* ) ]] || return 1
  return 0
}

find_reclaim_file() {
  local cgroup_root
  local current_path
  local candidate
  local original_uid="${REDUCE_MEMORY_TARGET_UID:-${SUDO_UID:-}}"

  if [[ -n "${REDUCE_MEMORY_TARGET_CGROUP:-}" ]]; then
    candidate="${REDUCE_MEMORY_TARGET_CGROUP%/}/memory.reclaim"
    valid_reclaim_scope "${candidate}" || return 1
    printf '%s\n' "${candidate}"
    return 0
  fi

  cgroup_root="$(detect_cgroup2_root)" || return 1

  # Desktop scope is the invoking user's slice, never the broader user.slice.
  if [[ "${original_uid}" =~ ^[0-9]+$ ]] && [[ "${original_uid}" != "0" ]]; then
    candidate="${cgroup_root}/user.slice/user-${original_uid}.slice/memory.reclaim"
    if valid_reclaim_scope "${candidate}"; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  fi

  current_path="$(current_cgroup_path)"
  if [[ -n "${current_path}" && "${current_path}" != "/" ]]; then
    candidate="${cgroup_root}${current_path}/memory.reclaim"
    if valid_reclaim_scope "${candidate}"; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  fi
  # No root/user.slice fallback: an unclear scope is skipped while independent
  # native/cache stages may still run.
  return 1
}

bounded_reclaim_mb() {
  local reclaim_file="$1"
  local requested_mb="$2"
  local scope="${reclaim_file%/memory.reclaim}"
  local current_file="${scope}/memory.current"
  local current_bytes=""
  local bounded_mb="${requested_mb}"
  local cursor="${scope}"
  local value=""
  if [[ -r "${current_file}" ]]; then
    current_bytes="$(<"${current_file}")"
    if current_bytes="$(safe_bytes_value "${current_bytes}")"; then
      local current_mb=$((current_bytes / 1048576))
      (( current_mb < bounded_mb )) && bounded_mb="${current_mb}"
    fi
  fi
  while [[ "${cursor}" != "/" && -n "${cursor}" ]]; do
    if [[ -r "${cursor}/memory.max" ]]; then
      value="$(<"${cursor}/memory.max")"
      if value="$(safe_bytes_value "${value}")"; then
        local limit_mb=$((value / 1048576))
        (( limit_mb < bounded_mb )) && bounded_mb="${limit_mb}"
      fi
    fi
    cursor="${cursor%/*}"
    [[ -n "${cursor}" ]] || cursor="/"
  done
  (( bounded_mb < 0 )) && bounded_mb=0
  printf '%s\n' "${bounded_mb}"
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

safe_bytes_value() {
  local value="${1:-}"
  [[ "${value}" =~ ^[0-9]{1,19}$ ]] || return 1
  # Compare as decimal text after left-padding, avoiding Bash's octal
  # interpretation for kernel values that contain leading zeroes.
  local normalized="${value#${value%%[!0]*}}"
  [[ -n "${normalized}" ]] || normalized="0"
  if (( ${#normalized} > 19 )); then return 1; fi
  if (( ${#normalized} == 19 )) && [[ "${normalized}" > "9223372036854775807" ]]; then return 1; fi
  printf '%s\n' "${normalized}"
}

record_native_rss_targets() {
  local native_output="$1"
  local record pid starttime before_kb after_kb status rss_records
  rss_records="$(awk -F= '$1 == "rss_target" { print substr($0, index($0, "=") + 1) }' <<< "${native_output}")"
  while IFS= read -r record; do
    IFS='|' read -r pid starttime before_kb after_kb status <<< "${record}"
    if [[ -z "${status}" ]]; then
      status="${after_kb}"; after_kb="${before_kb}"; before_kb="${starttime}"; starttime="0"
    fi
    [[ "${pid}" =~ ^[0-9]+$ ]] || continue
    [[ "${starttime}" =~ ^[0-9]+$ ]] || continue
    if [[ -n "${native_rss_starttime_by_pid[${pid}]+present}" && "${native_rss_starttime_by_pid[${pid}]}" != "${starttime}" && "${starttime}" != "0" ]]; then
      unset 'native_rss_after_by_pid['"${pid}"']'
      native_rss_status_by_pid[${pid}]="identity_mismatch"
      continue
    fi
    [[ -n "${native_rss_starttime_by_pid[${pid}]+present}" ]] || native_rss_starttime_by_pid[${pid}]="${starttime}"
    case "${status}" in
      measured)
        [[ "${before_kb}" =~ ^[0-9]+$ && "${after_kb}" =~ ^[0-9]+$ ]] || continue
        if [[ -z "${native_rss_status_by_pid[${pid}]+present}" ]]; then
          native_rss_before_by_pid[${pid}]="${before_kb}"
        elif [[ "${native_rss_status_by_pid[${pid}]}" != "measured" ]]; then
          # An earlier unknown result is sticky for the whole optimization
          # session. A later process using the same PID must not retroactively
          # turn that missing pair into a measured reduction.
          continue
        elif [[ -z "${native_rss_before_by_pid[${pid}]+present}" ]]; then
          # A missing first baseline cannot be reconstructed from a later pass.
          continue
        fi
        native_rss_after_by_pid[${pid}]="${after_kb}"
        native_rss_status_by_pid[${pid}]="measured"
        ;;
      exited|identity_mismatch|mapping_changed|permission_denied|after_unavailable|before_unavailable)
        if [[ -z "${native_rss_status_by_pid[${pid}]+present}" && "${before_kb}" =~ ^[0-9]+$ ]]; then
          native_rss_before_by_pid[${pid}]="${before_kb}"
        fi
        unset 'native_rss_after_by_pid['"${pid}"']'
        native_rss_status_by_pid[${pid}]="${status}"
        ;;
    esac
  done <<< "${rss_records}"

  native_rss_delta_kb=0
  native_rss_measured_targets=0
  native_rss_unmeasured_targets=0
  native_rss_exited_targets=0
  native_rss_identity_mismatch_targets=0
  native_rss_permission_denied_targets=0
  native_recovery_done_by_pid=()
  for pid in "${!native_rss_status_by_pid[@]}"; do
    status="${native_rss_status_by_pid[${pid}]}"
    if [[ "${status}" == "measured" && -n "${native_rss_before_by_pid[${pid}]+present}" && -n "${native_rss_after_by_pid[${pid}]+present}" ]]; then
      native_rss_delta_kb=$((native_rss_delta_kb + native_rss_before_by_pid[${pid}] - native_rss_after_by_pid[${pid}]))
      native_rss_measured_targets=$((native_rss_measured_targets + 1))
    else
      native_rss_unmeasured_targets=$((native_rss_unmeasured_targets + 1))
      case "${status}" in
        exited)
          native_rss_exited_targets=$((native_rss_exited_targets + 1))
          ;;
        identity_mismatch)
          native_rss_identity_mismatch_targets=$((native_rss_identity_mismatch_targets + 1))
          ;;
        permission_denied)
          native_rss_permission_denied_targets=$((native_rss_permission_denied_targets + 1))
          ;;
      esac
    fi
  done
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
  reclaim_scope_delta_bytes="unknown"
  reclaim_duration_ms=0
  reclaim_scope_before_bytes="unknown"
  reclaim_scope_after_bytes="unknown"
  native_processes_seen=0
  native_processes_advised=0
  native_processes_active_skipped=0
  native_processes_protected=0
  native_workloads_protected=0
  native_selection_protected=0
  native_selection_below_threshold=0
  native_selection_active=0
  native_selection_invalid_identity=0
  native_selection_eligible=0
  native_mappings_advised=0
  native_bytes_advised=0
  native_bytes_deferred=0
  native_control_status="none"
  native_rss_reduced_kb=0
  native_rss_delta_kb=0
  native_rss_measured_targets=0
  native_rss_unmeasured_targets=0
  native_rss_exited_targets=0
  native_rss_identity_mismatch_targets=0
  native_rss_permission_denied_targets=0
  native_rss_before_by_pid=()
  native_rss_after_by_pid=()
  native_rss_status_by_pid=()
  native_rss_starttime_by_pid=()
  native_pageout_passes=0
  native_batch_calls=0
  native_fallback_calls=0
  aggressive_peak_gain_kb=0
  aggressive_stable_gain_kb=0
  aggressive_peak_known=0
  aggressive_stable_known=0
  aggressive_rebound_kb=0
  aggressive_recovery_passes=0
  stage_sync_duration_ms=0
  stage_drop_caches_duration_ms=0
  optimization_session_id="rm-$$-${RANDOM}-${RANDOM}"
}

reset_stage_state

run_sync() {
  local started finished
  started="$(date +%s%3N 2>/dev/null || printf '0')"
  if ! "${sync_command}"; then
    finished="$(date +%s%3N 2>/dev/null || printf '0')"
    if [[ "${started}" =~ ^[0-9]+$ && "${finished}" =~ ^[0-9]+$ && ${finished} -ge ${started} ]]; then
      stage_sync_duration_ms=$((finished - started))
    fi
    stage_sync="failed"
    return 0
  fi
  finished="$(date +%s%3N 2>/dev/null || printf '0')"
  if [[ "${started}" =~ ^[0-9]+$ && "${finished}" =~ ^[0-9]+$ && ${finished} -ge ${started} ]]; then
    stage_sync_duration_ms=$((finished - started))
  fi
  stage_sync="done"
}

run_drop_caches() {
  local level="$1"
  local target_file
  local started finished
  target_file="$(drop_caches_file)"
  if [[ ! -w "${target_file}" ]]; then
    stage_drop_caches="unavailable; ${target_file} not writable"
    return 0
  fi
  started="$(date +%s%3N 2>/dev/null || printf '0')"
  if printf '%s\n' "${level}" > "${target_file}"; then
    finished="$(date +%s%3N 2>/dev/null || printf '0')"
    if [[ "${started}" =~ ^[0-9]+$ && "${finished}" =~ ^[0-9]+$ && ${finished} -ge ${started} ]]; then
      stage_drop_caches_duration_ms=$((finished - started))
    fi
    stage_drop_caches="done (level ${level})"
  else
    stage_drop_caches="failed; write denied"
  fi
}

run_native_pageout() {
  local profile="${1:-default}"
  # A benchmark or supervised caller may provide one explicit target without
  # broadening the scan. Recovery passes still supply the positional PID.
  local target_pid="${2:-${REDUCE_MEMORY_TARGET_PID:-}}"
  local native_helper
  local target_uid="${REDUCE_MEMORY_TARGET_UID:-${SUDO_UID:-}}"
  local native_output=""
  local native_exit=0
  local arguments=(pageout --protocol 2 --session "${optimization_session_id}")
  local minimum_rss_mb
  local minimum_mapping_kb
  local activity_ms
  local active_ticks
  local native_settle_ms
  local native_deadline_ms
  local pass_status
  local pass_processes_seen
  local pass_processes_advised
  local pass_processes_active_skipped
  local pass_processes_protected
  local pass_workloads_protected
  local pass_selection_protected
  local pass_selection_below_threshold
  local pass_selection_active
  local pass_selection_invalid_identity
  local pass_selection_eligible
  local pass_mappings_advised
  local pass_bytes_advised
  local pass_bytes_deferred
  local pass_control_status
  local pass_batch_calls
  local pass_fallback_calls

  # `command -v` alone is insufficient on minimal/managed systems: a stale
  # shim may exist while the interpreter is unavailable. Probe execution
  # without importing modules or touching reclaim state.
  if ! command -v python3 >/dev/null 2>&1 || ! python3 --version >/dev/null 2>&1; then
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
  if [[ "${target_pid}" =~ ^[1-9][0-9]*$ ]]; then
    arguments+=(--pid "${target_pid}")
  elif [[ "${REDUCE_MEMORY_ALL_USERS:-0}" == "1" || "${REDUCE_MEMORY_INCLUDE_SERVICE_USERS:-0}" == "1" || "${profile}" == "aggressive" || "${server_mode}" == "1" ]]; then
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

  native_deadline_ms="${REDUCE_MEMORY_NATIVE_DEADLINE_MS:-0}"
  if [[ ! "${native_deadline_ms}" =~ ^[0-9]+$ ]]; then
    stage_native_pageout="invalid deadline configuration"
    return 0
  fi

  arguments+=(
    --min-rss-mb "${minimum_rss_mb}"
    --min-mapping-kb "${minimum_mapping_kb}"
    --activity-ms "${activity_ms}"
    --active-ticks "${active_ticks}"
    --settle-ms "${native_settle_ms}"
    --deadline-ms "${native_deadline_ms}"
  )
  if [[ -n "${REDUCE_MEMORY_NATIVE_CANCEL_FILE:-}" ]]; then
    arguments+=(--cancel-file "${REDUCE_MEMORY_NATIVE_CANCEL_FILE}")
  fi

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
  if [[ "$(native_value "${native_output}" protocol)" != "2" || "$(native_value "${native_output}" session)" != "${optimization_session_id}" ]]; then
    pass_status="protocol_error"
    native_pageout_passes=$((native_pageout_passes + 1))
    if [[ "${stage_native_pageout}" == "not requested" ]]; then
      stage_native_pageout="pass${native_pageout_passes}=${pass_status}"
    else
      stage_native_pageout+="; pass${native_pageout_passes}=${pass_status}"
    fi
    return 0
  fi
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
  pass_selection_protected="$(native_value "${native_output}" selection_protected)"
  pass_selection_below_threshold="$(native_value "${native_output}" selection_below_threshold)"
  pass_selection_active="$(native_value "${native_output}" selection_active)"
  pass_selection_invalid_identity="$(native_value "${native_output}" selection_invalid_identity)"
  pass_selection_eligible="$(native_value "${native_output}" selection_eligible)"
  pass_mappings_advised="$(native_value "${native_output}" mappings_advised)"
  pass_bytes_advised="$(native_value "${native_output}" bytes_advised)"
  pass_bytes_deferred="$(native_value "${native_output}" bytes_deferred)"
  pass_control_status="$(native_value "${native_output}" control_status)"
  pass_batch_calls="$(native_value "${native_output}" batch_calls)"
  pass_fallback_calls="$(native_value "${native_output}" fallback_calls)"

  pass_processes_seen="$(numeric_or_zero "${pass_processes_seen}")"
  pass_processes_advised="$(numeric_or_zero "${pass_processes_advised}")"
  pass_processes_active_skipped="$(numeric_or_zero "${pass_processes_active_skipped}")"
  pass_processes_protected="$(numeric_or_zero "${pass_processes_protected}")"
  pass_workloads_protected="$(numeric_or_zero "${pass_workloads_protected}")"
  pass_selection_protected="$(numeric_or_zero "${pass_selection_protected}")"
  pass_selection_below_threshold="$(numeric_or_zero "${pass_selection_below_threshold}")"
  pass_selection_active="$(numeric_or_zero "${pass_selection_active}")"
  pass_selection_invalid_identity="$(numeric_or_zero "${pass_selection_invalid_identity}")"
  pass_selection_eligible="$(numeric_or_zero "${pass_selection_eligible}")"
  pass_mappings_advised="$(numeric_or_zero "${pass_mappings_advised}")"
  pass_bytes_advised="$(numeric_or_zero "${pass_bytes_advised}")"
  pass_bytes_deferred="$(numeric_or_zero "${pass_bytes_deferred}")"
  [[ -n "${pass_control_status}" ]] || pass_control_status="none"
  pass_batch_calls="$(numeric_or_zero "${pass_batch_calls}")"
  pass_fallback_calls="$(numeric_or_zero "${pass_fallback_calls}")"

  native_processes_seen=$((native_processes_seen + pass_processes_seen))
  native_processes_advised=$((native_processes_advised + pass_processes_advised))
  native_processes_active_skipped=$((native_processes_active_skipped + pass_processes_active_skipped))
  native_processes_protected=$((native_processes_protected + pass_processes_protected))
  native_workloads_protected=$((native_workloads_protected + pass_workloads_protected))
  native_selection_protected=$((native_selection_protected + pass_selection_protected))
  native_selection_below_threshold=$((native_selection_below_threshold + pass_selection_below_threshold))
  native_selection_active=$((native_selection_active + pass_selection_active))
  native_selection_invalid_identity=$((native_selection_invalid_identity + pass_selection_invalid_identity))
  native_selection_eligible=$((native_selection_eligible + pass_selection_eligible))
  native_mappings_advised=$((native_mappings_advised + pass_mappings_advised))
  native_bytes_advised=$((native_bytes_advised + pass_bytes_advised))
  native_bytes_deferred=$((native_bytes_deferred + pass_bytes_deferred))
  if [[ "${pass_control_status}" != "none" ]]; then
    if [[ "${native_control_status}" == "none" ]]; then
      native_control_status="${pass_control_status}"
    elif [[ "${native_control_status}" != "${pass_control_status}" ]]; then
      native_control_status="mixed"
    fi
  fi
  record_native_rss_targets "${native_output}"
  native_rss_reduced_kb=$((native_rss_delta_kb > 0 ? native_rss_delta_kb : 0))
  native_batch_calls=$((native_batch_calls + pass_batch_calls))
  native_fallback_calls=$((native_fallback_calls + pass_fallback_calls))
}

record_reclaim_scope_after() {
  local current_file="${reclaim_scope}/memory.current"
  local current_value
  [[ -r "${current_file}" ]] || return 0
  current_value="$(<"${current_file}")"
  if reclaim_scope_after_bytes="$(safe_bytes_value "${current_value}")"; then
    if [[ "${reclaim_scope_before_bytes}" =~ ^[0-9]+$ ]]; then
      reclaim_scope_delta_bytes=$((reclaim_scope_before_bytes - reclaim_scope_after_bytes))
    fi
  else
    reclaim_scope_after_bytes="unknown"
  fi
}

run_cgroup_reclaim() {
  local reclaim_file
  local swap_total_kb
  local swap_free_kb
  local requested_swappiness
  local native_helper
  local reclaim_output=""
  local reclaim_exit=0
  local reclaim_status=""
  local reclaim_started reclaim_finished
  local current_file current_value
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

  reclaim_request_mb="$(bounded_reclaim_mb "${reclaim_file}" "${reclaim_request_mb}")"
  if (( reclaim_request_mb <= 0 )); then
    stage_cgroup_reclaim="no reclaimable bytes in scope"
    return 0
  fi

  swap_total_kb="$(require_numeric_meminfo SwapTotal)"
  swap_free_kb="$(require_numeric_meminfo SwapFree)"
  requested_swappiness="${REDUCE_MEMORY_RECLAIM_SWAPPINESS:-}"
  if [[ -z "${requested_swappiness}" ]]; then
    requested_swappiness="default"
  fi
  if [[ "${requested_swappiness}" != "default" && "${requested_swappiness}" != "max" && ! "${requested_swappiness}" =~ ^([0-9]|[1-9][0-9]|1[0-9][0-9]|200)$ ]]; then
    echo "REDUCE_MEMORY_RECLAIM_SWAPPINESS harus default, max, atau angka 0-200." >&2
    return 2
  fi

  if [[ "${requested_swappiness}" != "default" && ( ${swap_total_kb} -eq 0 || ${swap_free_kb} -eq 0 ) ]]; then
    requested_swappiness="default"
  fi

  if ! native_helper="$(find_native_helper)"; then
    stage_cgroup_reclaim="unavailable; native helper missing"
    return 0
  fi
  current_file="${reclaim_scope}/memory.current"
  if [[ -r "${current_file}" ]]; then
    current_value="$(<"${current_file}")"
    if ! reclaim_scope_before_bytes="$(safe_bytes_value "${current_value}")"; then
      reclaim_scope_before_bytes="unknown"
    fi
  fi
  reclaim_started="$(date +%s%3N 2>/dev/null || printf '0')"
  reclaim_output="$("${native_helper}" reclaim --protocol 2 --session "${optimization_session_id}" --path "${reclaim_file}" --bytes "$((reclaim_request_mb * 1048576))" --swappiness "${requested_swappiness}" 2>&1)" || reclaim_exit=$?
  reclaim_finished="$(date +%s%3N 2>/dev/null || printf '0')"
  if [[ "${reclaim_started}" =~ ^[0-9]+$ && "${reclaim_finished}" =~ ^[0-9]+$ && ${reclaim_finished} -ge ${reclaim_started} ]]; then
    reclaim_duration_ms=$((reclaim_finished - reclaim_started))
  fi
  record_reclaim_scope_after
  if [[ "$(native_value "${reclaim_output}" protocol)" != "2" || "$(native_value "${reclaim_output}" session)" != "${optimization_session_id}" ]]; then
    stage_cgroup_reclaim="protocol_error"
    return 0
  fi
  reclaim_status="$(native_value "${reclaim_output}" native_status)"
  [[ -n "${reclaim_status}" ]] || reclaim_status="failed (exit ${reclaim_exit})"
  stage_cgroup_reclaim="${reclaim_status} (${reclaim_request_mb} MB requested; scope_delta=${reclaim_scope_delta_bytes} bytes; ${reclaim_duration_ms} ms) | swappiness=${requested_swappiness}"
}

should_recover_rebound() {
  local peak_gain_kb="$1"
  local stable_gain_kb="$2"
  local rebound_kb
  local threshold_kb=$((aggressive_rebound_min_mb * 1024))
  local proportional_kb=$((peak_gain_kb * aggressive_rebound_percent / 100))

  (( peak_gain_kb > 0 && stable_gain_kb >= 0 && stable_gain_kb < peak_gain_kb )) || return 1
  (( proportional_kb > threshold_kb )) && threshold_kb="${proportional_kb}"
  rebound_kb=$((peak_gain_kb - stable_gain_kb))
  (( rebound_kb >= threshold_kb ))
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
  local available_delta_text="unknown"
  local cache_delta_text="unknown"
  local anon_delta_text="unknown"
  local swap_delta_text="unknown"
  local after_available_text="unknown"
  local swap_current_text="unknown"
  local process_rss_change_text="+0 MB"
  local current_swap_total_kb
  current_swap_total_kb="$(optional_numeric_meminfo SwapTotal || true)"

  if [[ "${after_available_kb}" =~ ^[0-9]+$ ]]; then
    after_available_text="$((after_available_kb / 1024)) MB"
    available_delta_text="$(signed_mb "$((after_available_kb - before_available_kb))")"
  fi
  if [[ "${after_cache_kb}" =~ ^[0-9]+$ ]]; then
    cache_delta_text="$(signed_mb "$((before_cache_kb - after_cache_kb))")"
  fi
  if [[ "${after_anon_kb}" =~ ^[0-9]+$ ]]; then
    anon_delta_text="$(signed_mb "$((before_anon_kb - after_anon_kb))")"
  fi
  if [[ "${after_swap_used_kb}" =~ ^[0-9]+$ && "${current_swap_total_kb}" =~ ^[0-9]+$ ]]; then
    swap_delta_text="$(signed_mb "$((after_swap_used_kb - before_swap_used_kb))")"
    swap_current_text="$((after_swap_used_kb / 1024)) / $((current_swap_total_kb / 1024)) MB used"
  fi
  if (( native_rss_measured_targets > 0 )); then
    process_rss_change_text="$(signed_mb "${native_rss_delta_kb}")"
    if (( native_rss_unmeasured_targets > 0 )); then
      process_rss_change_text+=" (partial)"
    fi
  elif (( native_rss_unmeasured_targets > 0 )); then
    process_rss_change_text="unknown"
  fi

  printf '\nSystem                  : %s\n' "$(distribution_name)"
  printf 'Kernel                  : %s\n' "$(uname -r)"
  printf 'Mode                    : %s\n' "${selected_mode}"
  printf 'Available before        : %d MB\n' "$((before_available_kb / 1024))"
  printf 'Available after         : %s\n' "${after_available_text}"
  printf 'Available change        : %s\n' "${available_delta_text}"
  printf 'File cache released     : %s\n' "${cache_delta_text}"
  printf 'Anonymous RAM change    : %s\n' "${anon_delta_text}"
  printf 'Swap usage change       : %s\n' "${swap_delta_text}"
  printf 'Swap current            : %s\n' "${swap_current_text}"
  if [[ "${selected_mode}" == "check" || "${selected_mode}" == "status" ]]; then
  printf 'Default Aggressive ask  : %d MB\n' "$(default_reclaim_mb)"
  fi
  printf 'Kernel sync             : %s\n' "${stage_sync}"
  printf 'Sync cost               : %d ms\n' "${stage_sync_duration_ms}"
  if [[ "${selected_mode}" == "aggressive" ]]; then
    if (( aggressive_peak_known == 1 )); then
      printf 'Peak available change   : %s\n' "$(signed_mb "${aggressive_peak_gain_kb}")"
    else
      printf 'Peak available change   : unknown\n'
    fi
    if (( aggressive_stable_known == 1 )); then
      printf 'Stable available change : %s\n' "$(signed_mb "${aggressive_stable_gain_kb}")"
      printf 'Observed rebound        : %d MB\n' "$((aggressive_rebound_kb / 1024))"
    else
      printf 'Stable available change : unknown\n'
      printf 'Observed rebound        : unknown\n'
    fi
    printf 'Rebound recovery passes : %d\n' "${aggressive_recovery_passes}"
  fi
  printf 'Native process page-out : %s\n' "${stage_native_pageout}"
  if [[ "${stage_native_pageout}" != "not requested" ]]; then
    printf 'Native page-out passes  : %s\n' "${native_pageout_passes}"
    printf 'Processes scanned       : %s\n' "${native_processes_seen}"
    printf 'Processes paged out     : %s\n' "${native_processes_advised}"
    printf 'Active processes skipped: %s\n' "${native_processes_active_skipped}"
    printf 'Protected processes     : %s\n' "${native_processes_protected}"
    printf 'AI/GPU workloads safe   : %s\n' "${native_workloads_protected}"
    printf 'Selection protected     : %s\n' "${native_selection_protected}"
    printf 'Selection below floor   : %s\n' "${native_selection_below_threshold}"
    printf 'Selection active        : %s\n' "${native_selection_active}"
    printf 'Selection invalid ID    : %s\n' "${native_selection_invalid_identity}"
    printf 'Selection eligible      : %s\n' "${native_selection_eligible}"
    printf 'Mappings advised        : %s\n' "${native_mappings_advised}"
    printf 'Bytes advised           : %d MB\n' "$((native_bytes_advised / 1024 / 1024))"
    printf 'Bytes deferred          : %d MB\n' "$((native_bytes_deferred / 1024 / 1024))"
    printf 'Native control status   : %s\n' "${native_control_status}"
    printf 'Process RSS change      : %s\n' "${process_rss_change_text}"
    printf 'Measured RSS targets    : %s\n' "${native_rss_measured_targets}"
    printf 'Unmeasured advised      : %s\n' "${native_rss_unmeasured_targets}"
    printf 'Exited before after-read: %s\n' "${native_rss_exited_targets}"
    printf 'Identity changed        : %s\n' "${native_rss_identity_mismatch_targets}"
    printf 'Permission changed      : %s\n' "${native_rss_permission_denied_targets}"
    printf 'Batched native calls    : %s\n' "${native_batch_calls}"
    printf 'Scalar fallback calls   : %s\n' "${native_fallback_calls}"
  fi
  printf 'drop_caches             : %s\n' "${stage_drop_caches}"
  printf 'drop_caches cost        : %d ms\n' "${stage_drop_caches_duration_ms}"
  printf 'cgroup memory.reclaim   : %s\n' "${stage_cgroup_reclaim}"
  if [[ "${reclaim_scope}" != "-" ]]; then
    printf 'Reclaim scope           : %s\n' "${reclaim_scope}"
    printf 'Reclaim request         : %d MB\n' "${reclaim_request_mb}"
    printf 'Reclaim scope delta     : %s bytes\n' "${reclaim_scope_delta_bytes}"
    printf 'Reclaim write cost      : %d ms\n' "${reclaim_duration_ms}"
  fi

  if [[ "${selected_mode}" == "aggressive" && "${current_swap_total_kb}" =~ ^[0-9]+$ ]] && (( current_swap_total_kb == 0 )); then
    printf 'Note                    : swap tidak aktif; private application RAM tidak bisa dipindahkan ke swap.\n'
  fi
}

perform_mode() {
  local selected_mode="$1"
  local lock_acquired=0
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

  if [[ "${selected_mode}" != "check" && "${selected_mode}" != "status" ]]; then
    if ! acquire_optimization_lock; then
      printf '%s\n' "Mode ${selected_mode} sedang dijalankan oleh instance lain (optimization lock busy)." >&2
      return 7
    fi
    lock_acquired=1
  fi

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
      if [[ "${effective_uid}" -eq 0 ]]; then
        run_native_pageout normal
      else
        stage_native_pageout="root not granted; sync-only fallback"
      fi
      ;;
    smooth)
      require_root "${selected_mode}"
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
      run_sync
      run_native_pageout aggressive
      run_sync
      run_drop_caches 3
      run_cgroup_reclaim
      run_native_pageout aggressive
      # Keep applications alive, observe their first refault wave, then page
      # out that rebound once when it is material. This deliberately avoids a
      # permanent reclaim loop, which would trade free RAM for constant stalls.
      local peak_available_kb
      peak_available_kb="$(optional_numeric_meminfo MemAvailable || true)"
      if [[ "${peak_available_kb}" =~ ^[0-9]+$ ]]; then
        aggressive_peak_gain_kb=$((peak_available_kb - before_available_kb))
        aggressive_peak_known=1
      fi
      sleep "${aggressive_stabilize_seconds}"
      local stable_available_kb
      stable_available_kb="$(optional_numeric_meminfo MemAvailable || true)"
      if [[ "${stable_available_kb}" =~ ^[0-9]+$ ]]; then
        aggressive_stable_gain_kb=$((stable_available_kb - before_available_kb))
        aggressive_stable_known=1
      fi
      if (( aggressive_peak_known == 1 && aggressive_stable_known == 1 )); then
        aggressive_rebound_kb=$((aggressive_peak_gain_kb - aggressive_stable_gain_kb))
        (( aggressive_rebound_kb < 0 )) && aggressive_rebound_kb=0
      fi
      if (( aggressive_peak_known == 1 && aggressive_stable_known == 1 )) && should_recover_rebound "${aggressive_peak_gain_kb}" "${aggressive_stable_gain_kb}"; then
        # Recover only instances that produced a valid measured pair in this
        # session. A second broad scan could advise unrelated/new processes
        # and would make the recovery metric impossible to attribute.
        local recovery_pid recovery_status
        for recovery_pid in "${!native_rss_status_by_pid[@]}"; do
          recovery_status="${native_rss_status_by_pid[${recovery_pid}]}"
          [[ "${recovery_status}" == "measured" ]] || continue
          [[ -n "${native_rss_starttime_by_pid[${recovery_pid}]+present}" ]] || continue
          [[ -z "${native_recovery_done_by_pid[${recovery_pid}]+present}" ]] || continue
          native_recovery_done_by_pid[${recovery_pid}]=1
          run_native_pageout aggressive "${recovery_pid}"
        done
        run_sync
        aggressive_recovery_passes=1
      fi
      ;;
    *)
      echo "Mode tidak dikenal: ${selected_mode}" >&2
      return 2
      ;;
  esac

  if (( settle_seconds > 0 )) && [[ "${selected_mode}" != "check" && "${selected_mode}" != "status" ]]; then
    sleep "${settle_seconds}"
  fi

  after_available_kb="$(optional_numeric_meminfo MemAvailable || true)"
  after_cache_kb="$(optional_cache_kb || true)"
  after_anon_kb="$(optional_numeric_meminfo AnonPages || true)"
  swap_total_kb="$(optional_numeric_meminfo SwapTotal || true)"
  local after_swap_free_kb
  after_swap_free_kb="$(optional_numeric_meminfo SwapFree || true)"
  after_swap_used_kb=""
  if [[ "${swap_total_kb}" =~ ^[0-9]+$ && "${after_swap_free_kb}" =~ ^[0-9]+$ ]]; then
    after_swap_used_kb=$((swap_total_kb - after_swap_free_kb))
  fi

  print_result \
    "${selected_mode}" \
    "${before_available_kb}" "${before_cache_kb}" "${before_anon_kb}" "${before_swap_used_kb}" \
    "${after_available_kb}" "${after_cache_kb}" "${after_anon_kb}" "${after_swap_used_kb}"
  if (( lock_acquired == 1 )); then
    release_optimization_lock
  fi
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

  if [[ "${effective_uid}" -eq 0 ]]; then
    perform_mode "${selected_mode}"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    if [[ "${REDUCE_MEMORY_TARGET_PID:-}" =~ ^[1-9][0-9]*$ ]]; then
      sudo env "REDUCE_MEMORY_TARGET_PID=${REDUCE_MEMORY_TARGET_PID}" -- "${script_path}" "${selected_mode}" "${extra_arguments[@]}"
    else
      sudo -- "${script_path}" "${selected_mode}" "${extra_arguments[@]}"
    fi
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
