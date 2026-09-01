#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Script ini membutuhkan kernel Linux asli atau WSL2, bukan Git Bash/MSYS." >&2
  exit 3
fi

if [[ ! -r /proc/meminfo ]]; then
  echo "Linux /proc/meminfo tidak tersedia. Jalankan script ini di kernel Linux." >&2
  exit 3
fi

for required_command in awk sync; do
  if ! command -v "${required_command}" >/dev/null 2>&1; then
    echo "Perintah '${required_command}' tidak tersedia di sistem ini." >&2
    exit 7
  fi
done

available_kb() {
  awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo
}

read_available_kb() {
  local value
  value="$(available_kb)"
  if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
    echo "MemAvailable tidak dapat dibaca dari /proc/meminfo." >&2
    return 4
  fi
  printf '%s\n' "${value}"
}

require_root() {
  local selected_mode="$1"
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Mode '${selected_mode}' membutuhkan administrator/root." >&2
    echo "Jalankan: sudo ${script_path} ${selected_mode}" >&2
    return 5
  fi
}

require_drop_caches() {
  if [[ ! -w /proc/sys/vm/drop_caches ]]; then
    echo "/proc/sys/vm/drop_caches tidak dapat ditulis pada sistem ini." >&2
    return 6
  fi
}

print_result() {
  local selected_mode="$1"
  local before_kb="$2"
  local after_kb="$3"
  local released_kb=$((after_kb - before_kb))
  if (( released_kb < 0 )); then
    released_kb=0
  fi

  printf '\nMode                    : %s\n' "${selected_mode}"
  printf 'Available memory before : %d MB\n' "$((before_kb / 1024))"
  printf 'Available memory after  : %d MB\n' "$((after_kb / 1024))"
  printf 'Available memory gained : %d MB\n' "$((released_kb / 1024))"
}

perform_mode() {
  local selected_mode="$1"
  local before_kb
  local after_kb
  before_kb="$(read_available_kb)"

  case "${selected_mode}" in
    check)
      # Safe environment check. No cache or memory state is changed.
      ;;
    normal)
      # Normal leaves useful Linux page cache intact.
      sync
      ;;
    smooth)
      require_root "${selected_mode}"
      require_drop_caches
      sync
      echo 1 > /proc/sys/vm/drop_caches
      ;;
    aggressive)
      require_root "${selected_mode}"
      require_drop_caches
      sync
      echo 3 > /proc/sys/vm/drop_caches
      if [[ -w /proc/sys/vm/compact_memory ]]; then
        echo 1 > /proc/sys/vm/compact_memory
      fi
      ;;
    *)
      echo "Mode tidak dikenal: ${selected_mode}" >&2
      return 2
      ;;
  esac

  sleep 1
  after_kb="$(read_available_kb)"
  print_result "${selected_mode}" "${before_kb}" "${after_kb}"
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
    printf '%s\n' 'Reduce Memory 2.0 - Linux'
    printf '%s\n' '========================='
    printf 'Available memory: %d MB\n\n' "$(($(read_available_kb) / 1024))"
    printf '%s\n' '1. Normal     - aman, tidak membuang page cache'
    printf '%s\n' '2. Smooth     - melepas page cache (butuh password)'
    printf '%s\n' '3. Aggressive - cache penuh + memory compaction (butuh password)'
    printf '%s\n' '4. Check      - pemeriksaan aman'
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
        printf '\nAggressive dapat membuat aplikasi membaca ulang cache dan terasa lambat sementara.\n'
        printf 'Lanjutkan? [y/N]: '
        read -r confirmation || true
        if [[ "${confirmation:-}" =~ ^[Yy]$ ]]; then
          run_privileged_mode aggressive || true
        else
          printf '\nAggressive dibatalkan.\n'
        fi
        pause_menu
        ;;
      4|check)
        perform_mode check || true
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
  cat <<'EOF'
Reduce Memory 2.0 - Linux

Usage:
  reduce-memory                  Buka menu jika terminal interaktif
  reduce-memory --menu           Paksa buka menu
  reduce-memory check            Periksa tanpa mengubah cache
  reduce-memory normal           Sinkronkan write tanpa membuang cache
  sudo reduce-memory smooth      Lepaskan page cache
  sudo reduce-memory aggressive  Lepaskan cache dan compact memory
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
  check|normal|smooth|aggressive)
    perform_mode "$1"
    ;;
  *)
    show_usage >&2
    exit 2
    ;;
esac
