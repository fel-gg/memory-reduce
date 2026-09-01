# Reduce Memory Linux

## Buka seperti aplikasi

Pasang satu kali tanpa root:

```bash
chmod +x Install_ReduceMemory.sh ReduceMemory_Linux.sh
./Install_ReduceMemory.sh
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

## Tetap bisa lewat terminal

```bash
./ReduceMemory_Linux.sh
./ReduceMemory_Linux.sh check
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
