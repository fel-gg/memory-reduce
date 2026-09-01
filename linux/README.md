# Reduce Memory untuk Linux

Versi Linux memakai jalur yang dibuat khusus untuk kernel Linux. Ia tidak
menyalin `EmptyWorkingSet` Windows karena Linux tidak mempunyai API global yang
sama.

Aggressive sekarang menggabungkan tiga mekanisme yang berbeda:

```text
pidfd_open + process_madvise(MADV_PAGEOUT)
drop_caches
cgroup v2 memory.reclaim
```

Helper page-out membaca `/proc` secara dinamis. Tidak ada daftar Firefox,
Chrome, Discord, Steam, atau nama software lain. Aplikasi yang nanti baru
di-install tetap terdeteksi sebagai proses Linux biasa.

## Kenapa versi lama cuma mengurangi sekitar 100 MB?

Jalur lama hanya:

```text
sync -> drop_caches -> compact_memory
```

Kalau file cache Mint hanya 100 MB, memang hanya sekitar itu yang dapat dilepas.
`compact_memory` juga bukan pelepas RAM; fitur tersebut merapikan free pages
menjadi blok yang lebih kontigu.

Jalur Aggressive terbaru:

```text
1. sync pending filesystem writes
2. scan proses milik user melalui /proc
3. lindungi proses aktif, foreground, dan process tree Reduce Memory
4. MADV_PAGEOUT pada mapping yang aman dan resident
5. ukur pengurangan RSS proses
6. drop page cache + reclaimable slab
7. jalankan cgroup v2 proactive reclaim sebagai tahap tambahan/fallback
8. ukur MemAvailable, cache, anonymous RAM, dan swap
```

`MADV_PAGEOUT` meminta kernel mereclaim page pada range yang dipilih. Anonymous
pages dapat dipindahkan ke swap. File-backed dirty pages dapat ditulis ke
storage. Aplikasi tetap hidup dan memuat page itu kembali saat diperlukan.

## Mode

- `normal`: hanya `sync`; cache dan aplikasi tetap hangat.
- `smooth`: `sync` lalu melepas file/page cache. Tidak melakukan page-out
  terhadap proses aplikasi.
- `aggressive`: page-out mapping proses yang idle, lalu drop page cache,
  reclaimable slab, dan cgroup v2 reclaim.
- `status` atau `check`: hanya membaca metrik dan kemampuan kernel. Tidak
  mengubah RAM atau cache.

## Perlindungan Aggressive

Engine tidak membunuh proses. Sebelum page-out, ia melewati:

- PID sistem awal dan kernel thread;
- proses yang RSS-nya di bawah 64 MB;
- proses yang memakai CPU selama sampling 300 ms;
- aplikasi foreground yang dapat dideteksi melalui X11/Cinnamon;
- child process dari aplikasi yang dilindungi;
- terminal, `sudo`, Reduce Memory, dan seluruh ancestor process-nya;
- locked memory;
- device/PFN/IO mappings;
- stack, VDSO, VVAR, dan mapping khusus kernel.

Proteksi ini tidak bergantung pada nama aplikasi. Untuk Wayland/compositor yang
tidak mengekspos active-window PID, CPU activity shield dan process-tree shield
tetap bekerja, tetapi deteksi foreground tidak selalu tersedia.

## Laporan hasil

Setelah operasi, program memisahkan:

```text
Available memory change
File cache released
Anonymous RAM change
Swap usage change
Native process page-out status
Processes scanned/paged out/skipped/protected
Mappings advised
Bytes advised by the kernel
Measured process RSS reduction
cgroup memory.reclaim status
```

`Bytes advised` adalah jumlah range yang diterima syscall, bukan klaim RAM yang
pasti dilepas. `Process RSS reduced` dan `Available change` adalah pengukuran
sesudah operasi.

## Linux Desktop, termasuk Linux Mint

Dari folder `linux`:

```bash
chmod +x ReduceMemory_Linux.sh native/reduce-memory-native desktop/Install_Desktop.sh
./desktop/Install_Desktop.sh
```

Setelah itu cari **Reduce Memory** dari application menu. Password administrator
baru diminta setelah Smooth atau Aggressive dipilih.

Installer Desktop membuat:

```text
~/.local/bin/reduce-memory
~/.local/bin/reduce-memory-native
~/.local/share/applications/reduce-memory.desktop
```

Tidak ada daemon, autostart, cron, atau service tersembunyi.

Periksa dukungan kernel:

```bash
reduce-memory status
reduce-memory-native check
```

Jalankan mode kuat:

```bash
sudo reduce-memory aggressive
```

## Linux Server atau VPS

```bash
cd linux
chmod +x ReduceMemory_Linux.sh native/reduce-memory-native server/Install_Server.sh
sudo ./server/Install_Server.sh
```

Lalu:

```bash
reduce-memory-server status
reduce-memory-server normal
sudo reduce-memory-server smooth
sudo reduce-memory-server aggressive
```

Jika server dijalankan melalui `sudo`, Aggressive menargetkan UID user pemanggil.
Untuk semua user non-system dengan UID 1000 ke atas:

```bash
sudo REDUCE_MEMORY_ALL_USERS=1 reduce-memory-server aggressive
```

Varian Server tidak membuat desktop launcher, daemon, cron, atau systemd
service.

## Jalankan langsung tanpa install

```bash
./native/reduce-memory-native check
./ReduceMemory_Linux.sh status
./ReduceMemory_Linux.sh normal
sudo ./ReduceMemory_Linux.sh smooth
sudo ./ReduceMemory_Linux.sh aggressive
```

Pengaturan optional:

```bash
sudo REDUCE_MEMORY_RECLAIM_MB=1024 ./ReduceMemory_Linux.sh aggressive
sudo REDUCE_MEMORY_MIN_RSS_MB=128 ./ReduceMemory_Linux.sh aggressive
```

## Dukungan dan batas nyata

- UI Bash membutuhkan kernel Linux, Bash, `awk`, dan `sync`.
- Native process page-out membutuhkan Python 3, kernel Linux 5.10 atau lebih
  baru, `CONFIG_ADVISE_SYSCALLS`, akses ptrace yang diizinkan, dan
  `CAP_SYS_NICE`. Menjalankan Aggressive melalui `sudo` menyediakan capability
  tersebut pada instalasi Linux biasa.
- Anonymous/private application pages membutuhkan swap agar bisa dipindahkan
  keluar dari RAM tanpa menghilangkan datanya.
- Bila helper atau syscall tidak tersedia, Aggressive melanjutkan ke cgroup v2
  dan cache fallback serta melaporkan penyebabnya.
- WSL2 memakai kernel Linux, tetapi pelepasan RAM kembali ke host Windows tetap
  diputuskan oleh WSL2.
- Git Bash/MSYS bukan kernel Linux dan sengaja ditolak.

Tidak ada program aman yang dapat menjamin jumlah RAM tertentu. Page aktif,
locked, kernel-owned, atau page yang langsung dipakai kembali tidak akan tetap
kosong. Mode Aggressive memang lebih kuat dan dapat menimbulkan page fault,
storage I/O, atau stutter ketika aplikasi yang dipage-out digunakan lagi.
