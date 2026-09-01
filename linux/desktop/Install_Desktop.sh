#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Installer Desktop harus dijalankan di Linux atau WSL2." >&2
  exit 3
fi

installer_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
linux_directory="$(cd -- "${installer_directory}/.." && pwd)"
source_script="${linux_directory}/ReduceMemory_Linux.sh"
source_native="${linux_directory}/native/reduce-memory-native"
bin_directory="${REDUCE_MEMORY_BIN_DIR:-${XDG_BIN_HOME:-${HOME}/.local/bin}}"
application_directory="${REDUCE_MEMORY_APP_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/applications}"
installed_script="${bin_directory}/reduce-memory"
installed_native="${bin_directory}/reduce-memory-native"
desktop_file="${application_directory}/reduce-memory.desktop"

if [[ ! -f "${source_script}" ]]; then
  echo "Engine Linux tidak ditemukan: ${source_script}" >&2
  exit 4
fi
if [[ ! -f "${source_native}" ]]; then
  echo "Native Linux page-out helper tidak ditemukan: ${source_native}" >&2
  exit 4
fi

mkdir -p -- "${bin_directory}" "${application_directory}"
cp -- "${source_script}" "${installed_script}"
cp -- "${source_native}" "${installed_native}"
chmod 0755 -- "${installed_script}"
chmod 0755 -- "${installed_native}"

escaped_exec="${installed_script//\\/\\\\}"
escaped_exec="${escaped_exec//\"/\\\"}"

cat > "${desktop_file}" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Reduce Memory
Comment=Native Linux application page-out and cache reclaim
Exec="${escaped_exec}" --menu
Icon=utilities-system-monitor
Terminal=true
Categories=System;Utility;
Keywords=RAM;Memory;Cache;
StartupNotify=true
EOF

chmod 0644 -- "${desktop_file}"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "${application_directory}" >/dev/null 2>&1 || true
fi

printf '%s\n' 'Reduce Memory Linux Desktop berhasil dipasang.'
printf 'Buka menu aplikasi lalu cari: Reduce Memory\n'
printf 'Command terminal juga tersedia: %s\n' "${installed_script}"
printf 'Native page-out helper terpasang: %s\n' "${installed_native}"
