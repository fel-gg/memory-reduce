#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"
program_title="Reduce Memory 2.2 - Linux"
if [[ "${script_path##*/}" == "reduce-memory-server" ]]; then
  program_title="Reduce Memory 2.2 - Linux Server"
fi

# Alternate roots let CI execute the real reclaim paths against disposable
# files instead of changing the runner host.
proc_root="${REDUCE_MEMORY_PROC_ROOT:-/proc}"
meminfo_file="${REDUCE_MEMORY_MEMINFO_FILE:-${proc_root}/meminfo}"
vm_root="${REDUCE_MEMORY_VM_ROOT:-${proc_root}/sys/vm}"
settle_seconds="${REDUCE_MEMORY_SETTLE_SECONDS:-1}"

if [[ "$(uname -s)" != "Linux" ]]; then
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
  local original_uid="${SUDO_UID:-}"

  if [[ -n "${REDUCE_MEMORY_TARGET_CGROUP:-}" ]]; then
    candidate="${REDUCE_MEMORY_TARGET_CGROUP%/}/memory.reclaim"
    [[ -e "${candidate}" ]] || return 1
    printf '%s\n' "${candidate}"
    return 0
  fi

  cgroup_root="$(detect_cgroup2_root)" || return 1

  # The root cgroup covers all current and future applications, which is the
  # closest native Linux equivalent to a system-wide aggressive reclaim.
  candidate="${cgroup_root}/memory.reclaim"
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

  return 1
}

default_reclaim_mb() {
  local total_mb
  local target_mb
  total_mb=$(( $(require_numeric_meminfo MemTotal) / 1024 ))

  # Request roughly 1/16 of physical RAM, bounded so small machines remain
  # responsive and large machines do not receive an excessive blind request.
  target_mb=$((total_mb / 16))
  (( target_mb < 256 )) && target_mb=256
  (( target_mb > 2048 )) && target_mb=2048
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
  maximum_mb=$((total_mb / 4))
  (( maximum_mb < 64 )) && maximum_mb=64
  (( maximum_mb > 4096 )) && maximum_mb=4096
  if (( requested_mb > maximum_mb )); then
    requested_mb="${maximum_mb}"
  fi
  printf '%s\n' "${requested_mb}"
}

stage_sync="not requested"
stage_drop_caches="not requested"
stage_cgroup_reclaim="not requested"
reclaim_scope="-"
reclaim_request_mb=0

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

run_cgroup_reclaim() {
  local reclaim_file
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

  # EAGAIN means the kernel reclaimed less than requested; that can still be a
  # useful partial reclaim, so measured before/after values remain primary.
  if { printf '%sM\n' "${reclaim_request_mb}" > "${reclaim_file}"; } 2>/dev/null; then
    stage_cgroup_reclaim="done (${reclaim_request_mb} MB requested)"
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

  stage_sync="not requested"
  stage_drop_caches="not requested"
  stage_cgroup_reclaim="not requested"
  reclaim_scope="-"
  reclaim_request_mb=0

  before_available_kb="$(require_numeric_meminfo MemAvailable)"
  before_cache_kb="$(cache_kb)"
  before_anon_kb="$(require_numeric_meminfo AnonPages)"
  swap_total_kb="$(require_numeric_meminfo SwapTotal)"
  before_swap_used_kb=$((swap_total_kb - $(require_numeric_meminfo SwapFree)))

  case "${selected_mode}" in
    check|status)
      # Read-only capability and memory report.
      if reclaim_file="$(find_reclaim_file 2>/dev/null)"; then
        stage_cgroup_reclaim="available via ${reclaim_file}"
      else
        stage_cgroup_reclaim="unavailable; Aggressive uses cache-only fallback"
      fi
      ;;
    normal)
      # Make dirty data reclaimable while leaving useful caches and app pages
      # under the normal Linux memory manager policy.
      run_sync
      ;;
    smooth)
      require_root "${selected_mode}"
      require_drop_caches
      run_sync
      run_drop_caches 1
      ;;
    aggressive)
      require_root "${selected_mode}"
      require_drop_caches
      run_sync
      run_drop_caches 3
      run_cgroup_reclaim
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
  if [[ "${EUID}" -eq 0 ]]; then
    perform_mode "${selected_mode}"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo -- "${script_path}" "${selected_mode}"
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
    printf '%s\n' '1. Normal     - sync saja; cache dan aplikasi tetap hangat'
    printf '%s\n' '2. Smooth     - melepas file cache saja (butuh password)'
    printf '%s\n' '3. Aggressive - cache + native cgroup reclaim (butuh password)'
    printf '%s\n' '4. Status     - metrik dan dukungan kernel, tanpa perubahan'
    printf '%s\n' '0. Exit'
    printf '\nPilih mode [1]: '

    if ! read -r selection; then
      return 0
    fi
    selection="${selection:-1}"

    case "${selection}" in
      1|normal)
        perform_mode normal || true
        pause_menu
        ;;
      2|smooth)
        run_privileged_mode smooth || true
        pause_menu
        ;;
      3|aggressive)
        printf '\nAggressive meminta Linux mereclaim cache dan halaman aplikasi yang dingin.\n'
        printf 'Jika swap aktif, aplikasi bisa terasa lambat saat halaman itu dipakai kembali.\n'
        printf 'Tidak ada proses yang dimatikan. Lanjutkan? [y/N]: '
        read -r confirmation || true
        if [[ "${confirmation:-}" =~ ^[Yy]$ ]]; then
          run_privileged_mode aggressive || true
        else
          printf '\nAggressive dibatalkan.\n'
        fi
        pause_menu
        ;;
      4|check|status)
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
  reduce-memory normal           Sync tanpa membuang cache atau app pages
  sudo reduce-memory smooth      Lepaskan Linux file/page cache
  sudo reduce-memory aggressive  Cache + cgroup v2 proactive reclaim

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

case "$1" in
  --menu|menu)
    show_menu
    ;;
  --help|-h|help)
    show_usage
    ;;
  check|status|normal|smooth|aggressive)
    perform_mode "$1"
    ;;
  *)
    show_usage >&2
    exit 2
    ;;
esac
