#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Installer ini harus dijalankan di Linux atau WSL2." >&2
  exit 3
fi

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_script="${script_directory}/ReduceMemory_Linux.sh"
bin_directory="${REDUCE_MEMORY_BIN_DIR:-${XDG_BIN_HOME:-${HOME}/.local/bin}}"
application_directory="${REDUCE_MEMORY_APP_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/applications}"
installed_script="${bin_directory}/reduce-memory"
desktop_file="${application_directory}/reduce-memory.desktop"

if [[ ! -f "${source_script}" ]]; then
  echo "ReduceMemory_Linux.sh tidak ditemukan di samping installer." >&2
  exit 4
fi

mkdir -p -- "${bin_directory}" "${application_directory}"
cp -- "${source_script}" "${installed_script}"
chmod 0755 -- "${installed_script}"

escaped_exec="${installed_script//\\/\\\\}"
escaped_exec="${escaped_exec//\"/\\\"}"

cat > "${desktop_file}" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Reduce Memory
Comment=Simple Linux memory cache release
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

printf '%s\n' 'Reduce Memory Linux berhasil dipasang.'
printf 'Buka menu aplikasi lalu cari: Reduce Memory\n'
printf 'Command terminal juga tersedia: %s\n' "${installed_script}"
