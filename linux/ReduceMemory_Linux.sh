#!/usr/bin/env bash
set -euo pipefail

mode="${1:-normal}"

available_kb() {
  awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Mode '${mode}' membutuhkan root. Jalankan: sudo $0 ${mode}" >&2
    exit 5
  fi
}

before_kb="$(available_kb)"

case "${mode}" in
  normal)
    # Normal intentionally leaves the kernel page cache intact.
    sync
    ;;
  smooth)
    require_root
    sync
    echo 1 > /proc/sys/vm/drop_caches
    ;;
  aggressive)
    require_root
    sync
    echo 3 > /proc/sys/vm/drop_caches
    if [[ -w /proc/sys/vm/compact_memory ]]; then
      echo 1 > /proc/sys/vm/compact_memory
    fi
    ;;
  *)
    echo "Usage: $0 [normal|smooth|aggressive]" >&2
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

