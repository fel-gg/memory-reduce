#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Installer Server harus dijalankan pada kernel Linux." >&2
  exit 3
fi

installer_path="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"

if [[ "${EUID}" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    echo "Meminta akses administrator untuk memasang command server..."
    exec sudo -- "${installer_path}" "$@"
  fi
  echo "Installer Server membutuhkan root. Jalankan: sudo ${installer_path}" >&2
  exit 5
fi

installer_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
linux_directory="$(cd -- "${installer_directory}/.." && pwd)"
source_script="${linux_directory}/ReduceMemory_Linux.sh"
source_native="${linux_directory}/native/reduce-memory-native"
install_directory="${REDUCE_MEMORY_SERVER_BIN_DIR:-/usr/local/bin}"
installed_script="${install_directory}/reduce-memory-server"
installed_native="${install_directory}/reduce-memory-native"

if [[ ! -f "${source_script}" ]]; then
  echo "Engine Linux tidak ditemukan: ${source_script}" >&2
  exit 4
fi
if [[ ! -f "${source_native}" ]]; then
  echo "Native Linux page-out helper tidak ditemukan: ${source_native}" >&2
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
cp -- "${source_native}" "${installed_native}"
chmod 0755 -- "${installed_script}"
chmod 0755 -- "${installed_native}"

printf '%s\n' 'Reduce Memory Linux Server berhasil dipasang.'
printf 'Buka menu SSH       : %s\n' "${installed_script}"
printf 'Periksa status      : %s status\n' "${installed_script}"
printf 'Normal              : %s normal\n' "${installed_script}"
printf 'Smooth              : sudo %s smooth\n' "${installed_script}"
printf 'AI Shield           : sudo %s ai-shield\n' "${installed_script}"
printf 'Aggressive (page-out): sudo %s aggressive\n' "${installed_script}"
printf 'Native helper         : %s\n' "${installed_native}"
