# Reduce Memory untuk Linux

Versi Linux sekarang memakai cara kerja Linux sendiri. Ia tidak mencoba
menyalin `EmptyWorkingSet` dari Windows karena API itu memang tidak ada di
Linux.

Engine membaca `/proc/meminfo`, memakai `drop_caches` untuk cache kernel, dan
memakai `memory.reclaim` dari cgroup v2 untuk mode Aggressive. Karena targetnya
adalah cgroup sistem, aplikasi yang baru di-install tetap ikut dikelola tanpa
perlu menambahkan nama proses satu per satu.

## Kenapa sebelumnya cuma berkurang sekitar 100 MB?

Versi lama hanya menjalankan:

```text
sync -> drop_caches -> compact_memory
```

Kalau cache Linux Mint saat itu hanya sekitar 100 MB, memang hanya sebanyak itu
yang bisa dilepas. `compact_memory` juga tidak mengurangi total RAM terpakai;
fitur kernel tersebut hanya mencoba menyusun free pages menjadi blok yang lebih
kontigu.

Jalur Aggressive yang baru adalah:

```text
sync
  -> drop page cache + reclaimable kernel objects
  -> cgroup v2 proactive memory reclaim
  -> ukur cache, anonymous RAM, swap, dan MemAvailable
```

Dengan swap aktif, kernel juga bisa memindahkan halaman aplikasi yang dingin ke
swap. Kalau swap mati atau `memory.reclaim` tidak tersedia, engine tetap jalan,
tetapi hasilnya kembali terbatas pada cache yang memang bisa dilepas.

## Mode

- `normal`: melakukan `sync`, lalu Linux tetap mengatur cache dan aplikasi
  secara normal. Ini mode paling ringan.
- `smooth`: melakukan `sync` dan melepas file/page cache. Tidak menyentuh
  anonymous/private memory aplikasi.
- `aggressive`: melepas page cache, dentry, inode, lalu meminta cgroup v2
  melakukan proactive reclaim. Ukuran permintaan otomatis sekitar 1/16 RAM,
  minimal 256 MB dan maksimal 2 GB.
- `status` atau `check`: hanya membaca metrik dan dukungan kernel. Tidak ada RAM
  atau cache yang diubah.

Aggressive tidak membunuh proses. Kernel memilih halaman yang bisa direclaim.
Jika halaman aplikasi dipindahkan ke swap, aplikasi tersebut mungkin terasa
lebih lambat sesaat ketika halaman itu dibutuhkan lagi.

## Linux Desktop, termasuk Linux Mint

Dari folder `linux`:

```bash
chmod +x ReduceMemory_Linux.sh desktop/Install_Desktop.sh
./desktop/Install_Desktop.sh
```

Setelah itu cari **Reduce Memory** dari application menu. Password administrator
baru diminta ketika Smooth atau Aggressive dipilih.

Installer Desktop hanya membuat:

```text
~/.local/bin/reduce-memory
~/.local/share/applications/reduce-memory.desktop
```

Tidak ada daemon, autostart, cron, atau service tersembunyi.

## Linux Server atau VPS

Dari folder `linux`:

```bash
chmod +x ReduceMemory_Linux.sh server/Install_Server.sh
sudo ./server/Install_Server.sh
```

Lalu jalankan:

```bash
reduce-memory-server status
reduce-memory-server normal
sudo reduce-memory-server smooth
sudo reduce-memory-server aggressive
```

Varian Server hanya memasang `/usr/local/bin/reduce-memory-server`. Ia tidak
membuat desktop launcher, daemon, cron, atau systemd service.

## Jalankan langsung tanpa install

```bash
./ReduceMemory_Linux.sh check
./ReduceMemory_Linux.sh normal
sudo ./ReduceMemory_Linux.sh smooth
sudo ./ReduceMemory_Linux.sh aggressive
```

Untuk meminta ukuran reclaim tertentu:

```bash
sudo REDUCE_MEMORY_RECLAIM_MB=1024 ./ReduceMemory_Linux.sh aggressive
```

Nilai manual dibatasi maksimal seperempat RAM fisik dan maksimal 4 GB agar satu
perintah tidak memberi tekanan yang berlebihan.

## Dukungan distro dan batas nyata

- Pembacaan status dan mode Normal berjalan pada distro Linux dengan Bash dan
  `/proc`, termasuk Mint, Ubuntu, Debian, Fedora, Arch, dan turunannya.
- Smooth memerlukan root dan `/proc/sys/vm/drop_caches`.
- Aggressive paling lengkap pada kernel dengan unified cgroup v2 dan
  `memory.reclaim`. Pada cgroup v1, ia turun otomatis ke cache-only.
- WSL2 memakai kernel Linux dan bisa menjalankan engine, tetapi hasil serta
  pelepasan RAM ke host Windows tetap ditentukan oleh WSL2.
- Git Bash/MSYS bukan kernel Linux dan sengaja ditolak.

Program tidak menjanjikan angka pengurangan tetap. Kalau RAM berisi data aktif
yang tidak bisa direclaim, tidak ada cara aman untuk menghapusnya tanpa menutup
aplikasi. Laporan hasil sengaja memisahkan perubahan cache, anonymous RAM, swap,
dan `MemAvailable` supaya hasilnya tidak dibuat-buat.
