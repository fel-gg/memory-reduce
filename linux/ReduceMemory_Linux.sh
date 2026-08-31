#!/usr/bin/env bash
set -euo pipefail

mode="${1:-normal}"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Script ini membutuhkan kernel Linux asli atau WSL, bukan Git Bash/MSYS." >&2
  exit 3
fi

if [[ ! -r /proc/meminfo ]]; then
  echo "Linux /proc/meminfo tidak tersedia. Jalankan script ini di kernel Linux." >&2
  exit 3
fi

available_kb() {
  awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Mode '${mode}' membutuhkan root. Jalankan: sudo $0 ${mode}" >&2
    exit 5
  fi
}

require_drop_caches() {
  if [[ ! -w /proc/sys/vm/drop_caches ]]; then
    echo "/proc/sys/vm/drop_caches tidak dapat ditulis pada sistem ini." >&2
    exit 6
  fi
}

before_kb="$(available_kb)"
if [[ ! "${before_kb}" =~ ^[0-9]+$ ]]; then
  echo "MemAvailable tidak dapat dibaca dari /proc/meminfo." >&2
  exit 4
fi

case "${mode}" in
  check)
    # Safe environment check. No cache or memory state is changed.
    ;;
  normal)
    # Normal intentionally leaves the kernel page cache intact.
    sync
    ;;
  smooth)
    require_root
    require_drop_caches
    sync
    echo 1 > /proc/sys/vm/drop_caches
    ;;
  aggressive)
    require_root
    require_drop_caches
    sync
    echo 3 > /proc/sys/vm/drop_caches
    if [[ -w /proc/sys/vm/compact_memory ]]; then
      echo 1 > /proc/sys/vm/compact_memory
    fi
    ;;
  *)
    echo "Usage: $0 [check|normal|smooth|aggressive]" >&2
    exit 2
    ;;
esac

sleep 1
after_kb="$(available_kb)"
released_kb=$((after_kb - before_kb))
if (( released_kb < 0 )); then
  released_kb=0
fi

printf 'Mode: %s\n' "${mode}"
printf 'Available memory before: %d MB\n' "$((before_kb / 1024))"
printf 'Available memory after : %d MB\n' "$((after_kb / 1024))"
printf 'Available memory gained: %d MB\n' "$((released_kb / 1024))"
