#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Installer server ini harus dijalankan pada kernel Linux." >&2
  exit 3
fi

installer_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"

if [[ "${EUID}" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "Meminta akses administrator untuk memasang command server..."
    exec sudo -- "${installer_path}" "$@"
  fi
  echo "Installer server membutuhkan root. Jalankan: sudo ${installer_path}" >&2
  exit 5
fi

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_script="${script_directory}/ReduceMemory_Linux.sh"
install_directory="${REDUCE_MEMORY_SERVER_BIN_DIR:-/usr/local/bin}"
installed_script="${install_directory}/reduce-memory-server"

if [[ ! -f "${source_script}" ]]; then
  echo "ReduceMemory_Linux.sh tidak ditemukan di samping installer." >&2
  exit 4
fi

case "${install_directory}" in
  /*) ;;
  *)
    echo "Target instalasi server harus berupa absolute path." >&2
    exit 6
    ;;
esac

mkdir -p -- "${install_directory}"
cp -- "${source_script}" "${installed_script}"
chmod 0755 -- "${installed_script}"

printf '%s\n' 'Reduce Memory Linux Server berhasil dipasang.'
printf 'Buka menu SSH       : %s\n' "${installed_script}"
printf 'Periksa status      : %s status\n' "${installed_script}"
printf 'Normal              : %s normal\n' "${installed_script}"
printf 'Smooth              : sudo %s smooth\n' "${installed_script}"
printf 'Aggressive          : sudo %s aggressive\n' "${installed_script}"
