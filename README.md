# Reduce Memory 2.2

Reduce Memory adalah tool kecil buat membantu RAM terasa lebih lega di Windows
dan Linux. Keduanya punya engine terpisah karena cara Windows dan Linux
mengelola memori memang berbeda.

Proyek ini adalah **Reduce Memory 2.2**, terinspirasi dari Reduce Memory v1.7
buatan Sordum Team.
Di repo ini, alur tersebut kita kembangkan lagi: pilihan mode diperjelas,
Aggressive dibuat lebih kuat, ada versi Smooth supaya tidak gampang bikin lag,
dan ada pilihan untuk membersihkan file Temp.

Intinya tetap sederhana: minta sistem operasi melepas memori yang sedang tidak
terlalu dibutuhkan. Program ini tidak membunuh aplikasi, bukan antivirus, dan
bukan registry cleaner.

Semua aplikasi Windows diperlakukan secara dinamis. Tidak ada daftar nama
aplikasi yang harus diperbarui setiap kali ada software baru. Aplikasi yang baru
di-install akan ikut terdeteksi otomatis; yang dilindungi hanya proses Windows,
aplikasi yang sedang dipakai, proses yang baru saja aktif, dan proses yang
sedang memakai CPU cukup tinggi.

## Pilihan mode Windows

- **Normal Optimize** — pilihan aman untuk dipakai sehari-hari.
- **Aggressive Smooth** — lebih kuat dari Normal, tetapi dibuat lebih halus
  supaya kemungkinan stutter lebih kecil.
- **Aggressive Release** — pelepasan RAM paling kuat. Beberapa aplikasi mungkin
  perlu memuat ulang cache setelahnya.
- **Aggressive + Delete Temp** — menjalankan Aggressive Release lalu menawarkan
  penghapusan permanen file dari `%TEMP%` dan `C:\Windows\Temp`. File yang
  sedang dipakai akan dilewati.
- **Emergency Release** — mode manual paling kuat dengan warning dan dua pass
  pelepasan memory.

Saat dibuka, program tidak langsung meminta izin administrator. Izin tersebut
baru diminta ketika kamu memilih operasi yang memang membutuhkannya.

Setelah Optimize, hasil langsung tampil di jendela utama. Lima belas detik
kemudian hasil stabil dihitung ulang. Kalau memori langsung diambil kembali,
rebound protection menahan operasi berat selama 60 detik. Ringkasan setiap
operasi juga disimpan di `windows/ReduceMemory.log` dengan ukuran terbatas.

## Isi folder

- [`windows/ReduceMemory_x64.exe`](windows/ReduceMemory_x64.exe) — Windows 64-bit.
- [`windows/ReduceMemory.exe`](windows/ReduceMemory.exe) — Windows 32-bit (x86).
- [`windows/ReduceMemory.ini`](windows/ReduceMemory.ini) — pengaturan Windows.
- [`src/ReduceMemory.au3`](src/ReduceMemory.au3) — source utama AutoIt.
- [`linux/ReduceMemory_Linux.sh`](linux/ReduceMemory_Linux.sh) — script untuk
  Linux.
- [`linux/desktop/Install_Desktop.sh`](linux/desktop/Install_Desktop.sh) — installer
  user-local yang menambahkan Reduce Memory ke menu aplikasi Linux.
- [`linux/server/Install_Server.sh`](linux/server/Install_Server.sh) — installer command
  `reduce-memory-server` untuk VPS, server headless, dan SSH.
- [`docs/PROGRESS.md`](docs/PROGRESS.md) — catatan perkembangan upgrade.

## Self-test aman

Self-test tidak memangkas RAM atau membersihkan cache. Ia memeriksa pembacaan
RAM/commit, CPU time, process-path WinAPI, seluruh jalur pemilihan kandidat
Normal, kelima mode, dan penulisan log:

```powershell
.\windows\ReduceMemory_x64.exe /RMSELFTEST
.\windows\ReduceMemory.exe /RMSELFTEST
```

## Versi Linux native

Versi Linux bukan port dari `EmptyWorkingSet` Windows. Engine Linux membaca
`/proc/meminfo`, memakai `drop_caches` untuk cache kernel, dan memakai
`memory.reclaim` cgroup v2 untuk Aggressive. Ini membuat aplikasi yang sudah ada
maupun software baru ikut ditangani tanpa daftar nama proses.

Pemeriksaan environment yang aman bisa dijalankan dengan:

```bash
./linux/ReduceMemory_Linux.sh check
```

Untuk pemakaian sederhana seperti aplikasi, pasang launcher satu kali:

```bash
cd linux
chmod +x ReduceMemory_Linux.sh desktop/Install_Desktop.sh
./desktop/Install_Desktop.sh
```

Setelah itu cari **Reduce Memory** dari menu aplikasi. Normal, Smooth,
Aggressive, dan Status bisa dipilih tanpa menghafal command.

Untuk Linux Server/VPS:

```bash
cd linux
chmod +x ReduceMemory_Linux.sh server/Install_Server.sh
sudo ./server/Install_Server.sh
reduce-memory-server
```

Varian server membuka menu terminal melalui SSH dan tidak memasang desktop
launcher, service, daemon, cron, atau automatic trigger.

Di Linux, Aggressive baru bisa melampaui cache-only kalau kernel menyediakan
cgroup v2 `memory.reclaim`. Swap yang aktif memberi kernel tempat untuk
memindahkan halaman aplikasi yang dingin. Kalau cache hanya 100 MB dan swap
mati, hasilnya memang bisa kecil karena RAM aktif tidak aman untuk dihapus.

Kalau yang dicari adalah pemakaian rutin tanpa banyak gangguan, gunakan Smooth.
Memory reclaim tidak menghapus virus dan tidak menghapus data aplikasi yang
sedang aktif; Windows maupun Linux bisa memakai kembali memori itu ketika
dibutuhkan.
