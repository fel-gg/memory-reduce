# Reduce Memory Linux

## Desktop dan Server dipisahkan

```text
linux/
├── ReduceMemory_Linux.sh
├── desktop/
│   └── Install_Desktop.sh
├── server/
│   └── Install_Server.sh
└── README.md
```

`desktop` khusus application menu dan instalasi user-local. `server` khusus
VPS/headless melalui SSH dan command global. Keduanya memakai satu engine agar
fungsi Normal, Smooth, dan Aggressive selalu konsisten dan diuji bersama.

## Buka seperti aplikasi

Pasang satu kali tanpa root:

```bash
chmod +x ReduceMemory_Linux.sh desktop/Install_Desktop.sh
./desktop/Install_Desktop.sh
```

Setelah itu buka menu aplikasi Linux dan cari **Reduce Memory**. Aplikasi membuka
menu sederhana untuk Normal, Smooth, Aggressive, dan Check. Password root baru
diminta setelah Smooth atau Aggressive dipilih.

Installer hanya menambahkan dua file milik user:

```text
~/.local/bin/reduce-memory
~/.local/share/applications/reduce-memory.desktop
```

Tidak ada daemon, service, startup otomatis, atau perubahan sistem saat instalasi.

## Linux Server atau VPS

Pada server headless, pasang command system-wide satu kali:

```bash
chmod +x ReduceMemory_Linux.sh server/Install_Server.sh
sudo ./server/Install_Server.sh
```

Setelah itu melalui SSH:

```bash
reduce-memory-server
reduce-memory-server status
reduce-memory-server normal
sudo reduce-memory-server smooth
sudo reduce-memory-server aggressive
```

Tanpa argumen membuka menu terminal bertuliskan **Linux Server**. Installer
server hanya menyalin engine yang sama ke:

```text
/usr/local/bin/reduce-memory-server
```

Tidak ada GUI, desktop entry, daemon, cron, systemd service, atau automatic
trigger pada varian server.

## Tetap bisa lewat terminal

```bash
./ReduceMemory_Linux.sh
./ReduceMemory_Linux.sh check
./ReduceMemory_Linux.sh status
./ReduceMemory_Linux.sh normal
sudo ./ReduceMemory_Linux.sh smooth
sudo ./ReduceMemory_Linux.sh aggressive
```

- Tanpa argumen membuka menu ketika terminal interaktif tersedia.
- `check` memeriksa environment tanpa mengubah cache.
- `normal` menyelesaikan pending write dan mempertahankan page cache.
- `smooth` melepas page cache saja.
- `aggressive` melepas page cache, dentry, inode, lalu meminta compaction jika
  kernel menyediakannya.

Windows `EmptyWorkingSet` tidak ada di Linux. Versi ini memakai interface native
Linux dan melaporkan `MemAvailable` sebelum dan sesudah. Git Bash/MSYS ditolak
karena bukan kernel Linux.
