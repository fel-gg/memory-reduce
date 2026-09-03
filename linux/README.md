# Reduce Memory untuk Linux

Versi Linux memakai jalur yang dibuat khusus untuk kernel Linux. Ia tidak
menyalin `EmptyWorkingSet` Windows karena Linux tidak mempunyai API global yang
sama.

Engine Linux 2.8 menggabungkan tiga mekanisme native yang berbeda:

```text
pidfd_open + process_madvise(MADV_PAGEOUT)
drop_caches
cgroup v2 memory.reclaim
```

Helper page-out membaca `/proc` secara dinamis. Tidak ada daftar Firefox,
Chrome, Discord, Steam, atau nama software lain. Aplikasi yang nanti baru
di-install tetap terdeteksi sebagai proses Linux biasa.

AI Shield menambahkan perlindungan khusus di atas scan dinamis itu: proses yang
memegang device GPU, pola nama/command line AI, dan seluruh child process-nya
tidak dipage-out. Polanya bisa diganti lewat `REDUCE_MEMORY_AI_PATTERNS` untuk
software baru tanpa mengubah source.

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
2. scan semua proses UID non-system melalui /proc
3. lindungi proses aktif, foreground, dan process tree Reduce Memory
4. kirim mapping yang aman dan resident dalam batch MADV_PAGEOUT
5. ukur pengurangan RSS proses pass pertama
6. drop page cache + reclaimable slab
7. jalankan cgroup v2 proactive reclaim (default sekitar 1/8 RAM, dibatasi);
   saat swap tersedia, prioritaskan anonymous RAM dengan `swappiness=max`
8. lakukan page-out kedua setelah cache/cgroup reclaim
9. ukur peak `MemAvailable`, tunggu refault pertama selama 3 detik, lalu ukur
   stable gain dan rebound
10. bila rebound minimal 64 MB sekaligus minimal 20% dari peak gain, lakukan
    tepat satu recovery page-out; proses tetap hidup dan tidak ada loop permanen
11. ukur MemAvailable, cache, anonymous RAM, swap, dan total seluruh pass
```

`MADV_PAGEOUT` meminta kernel mereclaim page pada range yang dipilih. Anonymous
pages dapat dipindahkan ke swap. File-backed dirty pages dapat ditulis ke
storage. Aplikasi tetap hidup dan memuat page itu kembali saat diperlukan.

## Mode

- `normal`: dengan root, page-out hanya aplikasi besar (minimal 256 MB) yang
  benar-benar idle; tanpa root tetap punya fallback `sync` yang aman.
- `smooth`: page-out konservatif aplikasi idle (minimal 128 MB), lalu melepas
  file/page cache ringan.
- `ai-shield`: melindungi AI/GPU workload lalu melakukan page-out hanya pada
  proses background yang idle. Tidak membuang cache global atau menjalankan
  root-cgroup reclaim.
- `aggressive`: scan semua UID non-system, page-out aplikasi idle mulai 32 MB
  dan mapping mulai 256 KB, lalu drop page cache, reclaimable slab, cgroup v2
  reclaim, page-out ulang, dan satu recovery pass bersyarat setelah pengukuran
  rebound. Tidak memakai daftar nama AI/GPU.
- `status` atau `check`: hanya membaca metrik dan kemampuan kernel. Tidak
  mengubah RAM atau cache.

## Perlindungan engine

Engine tidak membunuh proses. Sebelum page-out, ia melewati:

- PID sistem awal dan kernel thread;
- proses di bawah batas RSS profil (256 MB Normal, 128 MB Smooth, 64 MB AI
  Shield, dan 32 MB Aggressive);
- proses yang aktif selama sampling profil;
- aplikasi foreground yang dapat dideteksi melalui X11/Cinnamon;
- child process dari aplikasi yang dilindungi;
- proses AI/GPU dan seluruh child process-nya, **hanya pada AI Shield**;
- terminal, `sudo`, Reduce Memory, dan seluruh ancestor process-nya;
- locked memory;
- device/PFN/IO dan HugeTLB mappings;
- stack, VDSO, VVAR, dan mapping khusus kernel.

Proteksi umum tidak bergantung pada nama aplikasi. AI Shield menambahkan pola
yang dapat dikonfigurasi dan deteksi pemilik GPU. Untuk Wayland/compositor yang
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
Batched syscall count and scalar fallbacks
Native page-out pass count
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
baru diminta setelah Normal, Smooth, AI Shield, atau Aggressive dipilih.
Menjalankan `reduce-memory normal` tanpa root tetap memakai fallback `sync`.

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
sudo reduce-memory ai-shield
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
sudo reduce-memory-server normal
sudo reduce-memory-server smooth
sudo reduce-memory-server ai-shield
sudo reduce-memory-server aggressive
```

Varian Server membuat semua profil native memeriksa UID aplikasi biasa sekaligus
akun service non-root di bawah UID 1000. Ini mencakup workload seperti web worker
atau database yang tidak berjalan sebagai login user. UID root, kernel thread,
dan nama daemon inti tetap dilindungi. Aggressive Desktop memeriksa semua UID
1000 ke atas; Normal, Smooth, dan AI Shield Desktop tetap dibatasi ke akun
pemanggil kecuali `REDUCE_MEMORY_ALL_USERS=1` diberikan. Service UID Desktop
dapat disertakan secara eksplisit dengan `REDUCE_MEMORY_INCLUDE_SERVICE_USERS=1`.

Varian Server tidak membuat desktop launcher, daemon, cron, atau systemd
service.

## Jalankan langsung tanpa install

```bash
./native/reduce-memory-native check
./ReduceMemory_Linux.sh status
./ReduceMemory_Linux.sh normal
sudo ./ReduceMemory_Linux.sh normal
sudo ./ReduceMemory_Linux.sh smooth
sudo ./ReduceMemory_Linux.sh ai-shield
sudo ./ReduceMemory_Linux.sh aggressive
```

Pengaturan optional:

```bash
sudo REDUCE_MEMORY_RECLAIM_MB=1024 ./ReduceMemory_Linux.sh aggressive
sudo REDUCE_MEMORY_RECLAIM_SWAPPINESS=max ./ReduceMemory_Linux.sh aggressive
sudo REDUCE_MEMORY_AGGRESSIVE_MIN_RSS_MB=64 ./ReduceMemory_Linux.sh aggressive
sudo REDUCE_MEMORY_INCLUDE_SERVICE_USERS=1 ./ReduceMemory_Linux.sh aggressive
sudo REDUCE_MEMORY_AI_PATTERNS='my-ai-worker|future-model-server' ./ReduceMemory_Linux.sh ai-shield
```

## Dukungan dan batas nyata

- UI Bash membutuhkan kernel Linux, Bash, `awk`, dan `sync`.
- Native process page-out membutuhkan Python 3, kernel Linux 5.10 atau lebih
  baru, `CONFIG_ADVISE_SYSCALLS`, akses ptrace yang diizinkan, dan
  `CAP_SYS_NICE`. Menjalankan mode native melalui `sudo` menyediakan capability
  tersebut pada instalasi Linux biasa.
- Anonymous/private application pages membutuhkan swap agar bisa dipindahkan
  keluar dari RAM tanpa menghilangkan datanya.
- `REDUCE_MEMORY_RECLAIM_SWAPPINESS` menerima `default`, `max`, atau 0-200.
  Default Aggressive adalah `max` ketika swap tersedia, sehingga tahap cgroup
  itu khusus mencoba anonymous memory; kernel yang belum mendukung nested key
  otomatis mendapat request plain lama.
- Bila helper atau syscall tidak tersedia, Aggressive melanjutkan ke cgroup v2
  dan cache fallback serta melaporkan penyebabnya.
- WSL2 memakai kernel Linux, tetapi pelepasan RAM kembali ke host Windows tetap
  diputuskan oleh WSL2.
- Git Bash/MSYS bukan kernel Linux dan sengaja ditolak.

Tidak ada program aman yang dapat menjamin jumlah RAM tertentu. Page aktif,
locked, kernel-owned, atau page yang langsung dipakai kembali tidak akan tetap
kosong. Mode Aggressive memang lebih kuat dan dapat menimbulkan page fault,
storage I/O, atau stutter ketika aplikasi yang dipage-out digunakan lagi.
