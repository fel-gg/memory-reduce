# Reduce Memory 2.8

Reduce Memory adalah tool kecil buat membantu RAM terasa lebih lega di Windows
dan Linux. Keduanya punya engine terpisah karena cara Windows dan Linux
mengelola memori memang berbeda.

Proyek ini adalah **Reduce Memory 2.8**, terinspirasi dari Reduce Memory v1.7
buatan Sordum Team.
Di repo ini, alur tersebut kita kembangkan lagi: pilihan mode diperjelas,
Aggressive dibuat lebih kuat, ada versi Smooth supaya tidak gampang bikin lag,
dan ada pilihan untuk membersihkan file Temp.

Intinya tetap sederhana: minta sistem operasi melepas memori yang sedang tidak
terlalu dibutuhkan. Program ini tidak membunuh aplikasi, bukan antivirus, dan
bukan registry cleaner.

Semua aplikasi tetap ditemukan secara dinamis. Normal dan Smooth melihat
foreground serta aktivitas CPU, sedangkan Aggressive memperluas kandidat ke
aplikasi user/background yang lebih kecil. AI Shield sekarang benar-benar jalur
terpisah: hanya mode itu yang menambahkan pola AI/GPU dan melindungi seluruh
child process-nya. Proses inti milik root/system tetap di luar kandidat reclaim.
Jadi software baru tetap ikut scan tanpa harus menunggu daftar nama diperbarui.

## Pilihan mode Windows

- **Normal Optimize** — satu pass ringan untuk aplikasi background besar
  (default minimal 96 MB); aplikasi foreground, aplikasi yang baru aktif, dan
  proses yang sedang memakai CPU dilewati.
- **AI Shield** — melindungi proses AI yang dikenali dan memangkas proses
  background yang idle tanpa menjalankan purge memory-list global.
- **Aggressive Smooth** — process trim konservatif biasa dan elevated ditambah
  pelepasan standby prioritas rendah, tanpa full cache/list purge.
- **Aggressive Release** — satu pass awal lalu dua pass elevated untuk kandidat
  background mulai 4 MB. Di antaranya Windows menjalankan pelepasan working
  set, modified list, standby list, dan system file cache; setelah pass proses
  terakhir, empty-working-set dan purge-standby dijalankan lagi. Worker kemudian
  memberi aplikasi hidup waktu 3 detik untuk melakukan refault normal. Kalau
  Available RAM turun lagi secara material (minimal 64 MB dan 20% dari gain
  awal), satu recovery pass terbatas dijalankan untuk menangkap rebound pertama.
  Jendela yang
  sedang dipakai dan proses kritis Windows tetap dilindungi, tetapi aplikasi
  yang baru dipindah ke background boleh direclaim.
- **Aggressive + Delete Temp** — menjalankan Aggressive Release lalu menawarkan
  penghapusan permanen file dari `%TEMP%` dan `C:\Windows\Temp`. File yang
  sedang dipakai akan dilewati.
- **Emergency Release** — mode manual paling kuat dengan warning dan dua pass;
  aplikasi foreground juga dapat dipangkas, tetapi proses tidak dimatikan.

Saat dibuka, program tidak langsung meminta izin administrator. Izin tersebut
baru diminta ketika kamu memilih operasi yang memang membutuhkannya.

Kalau **Automatically start at Windows startup** diaktifkan dari Options,
program menunggu 10 detik setelah login, menjalankan satu **Normal** pass tanpa
jendela/UAC, lalu tetap menjadi monitor tersembunyi. Saat RAM mencapai 95% pada
dua pemeriksaan berturut-turut, Normal pass dijalankan lagi. Cooldown 5 menit
dan titik re-arm 90% mencegah loop trim berulang. Mode manual yang dipilih di
dropdown tidak diubah; startup sengaja tidak menjalankan Emergency/Aggressive
supaya login tidak tersendat.

Setelah Optimize, hasil langsung tampil di jendela utama. Angka **working set**
berasal dari pengukuran tiap proses sebelum/sesudah trim, sedangkan angka
**available** berasal dari statistik RAM Windows; keduanya sengaja tidak
dicampur. Worker Administrator juga mengembalikan jumlah pass, operasi trim,
perubahan available RAM di dalam worker, dan tahap native yang benar-benar
berhasil. Worker juga memisahkan peak gain, stable gain, jumlah rebound, dan
recovery pass sehingga halaman yang dilepas dua kali tidak disamakan dengan
RAM bersih yang benar-benar tersedia. Lima belas detik kemudian hasil stabil
dihitung ulang sekali lagi. Kalau memori masih langsung diambil kembali,
rebound protection menahan operasi berat selama 60 detik. Ringkasan setiap
operasi juga disimpan di `windows/ReduceMemory.log` dengan ukuran terbatas.

## Isi folder

- [`windows/ReduceMemory_x64.exe`](windows/ReduceMemory_x64.exe) — Windows 64-bit.
- [`windows/ReduceMemory.exe`](windows/ReduceMemory.exe) — Windows 32-bit (x86).
- [`windows/ReduceMemory.ini`](windows/ReduceMemory.ini) — pengaturan Windows.
- [`src/ReduceMemory.au3`](src/ReduceMemory.au3) — source utama AutoIt.
- [`linux/ReduceMemory_Linux.sh`](linux/ReduceMemory_Linux.sh) — script untuk
  Linux.
- [`linux/native/reduce-memory-native`](linux/native/reduce-memory-native) —
  native Linux syscall helper untuk page-out proses aplikasi.
- [`linux/desktop/Install_Desktop.sh`](linux/desktop/Install_Desktop.sh) — installer
  user-local yang menambahkan Reduce Memory ke menu aplikasi Linux.
- [`linux/server/Install_Server.sh`](linux/server/Install_Server.sh) — installer command
  `reduce-memory-server` untuk VPS, server headless, dan SSH.
- [`docs/PROGRESS.md`](docs/PROGRESS.md) — catatan perkembangan upgrade.

## Self-test aman

Self-test biasa tidak memangkas RAM atau membersihkan cache. Ia memeriksa pembacaan
RAM/commit, CPU time, process-path WinAPI, seluruh jalur pemilihan kandidat
Normal, keenam mode, AI Shield, parser hasil worker, logika trigger 95%/re-arm
90%, minimum kandidat tiap profil, dan penulisan log:

```powershell
.\windows\ReduceMemory_x64.exe /RMSELFTEST
.\windows\ReduceMemory.exe /RMSELFTEST
.\windows\ReduceMemory_x64.exe /RMMONITORSELFTEST
.\windows\ReduceMemory.exe /RMMONITORSELFTEST
```

## Versi Linux native

Versi Linux bukan port dari `EmptyWorkingSet` Windows. Engine membaca proses dan
mapping secara dinamis dari `/proc`, lalu memakai `pidfd_open` dan
`process_madvise(MADV_PAGEOUT)` untuk meminta kernel mereclaim resident pages
aplikasi yang idle. Normal memakai batas konservatif, Smooth menambah pelepasan
file cache ringan, dan Aggressive memeriksa semua UID non-system dengan batas
mapping lebih rendah. Aggressive melakukan page-out sebelum dan sesudah
`drop_caches` plus `memory.reclaim` cgroup v2, menunggu refault pertama selama
3 detik, lalu menambah paling banyak satu recovery pass jika rebound material
terukur. Helper mengirim sampai
64 mapping per syscall dan kembali ke panggilan satu-per-satu hanya ketika
kernel memberi hasil parsial atau menolak batch. Bila swap tersedia, cgroup
reclaim memakai `swappiness=max` untuk menarget anonymous memory; kernel lama
otomatis mendapat format kompatibilitas.
Aplikasi lama maupun software baru ikut tanpa daftar nama proses.

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

Setelah itu cari **Reduce Memory** dari menu aplikasi. Normal, Smooth, AI Shield,
Aggressive, dan Status bisa dipilih tanpa menghafal command.

Untuk Linux Server/VPS:

```bash
cd linux
chmod +x ReduceMemory_Linux.sh server/Install_Server.sh
sudo ./server/Install_Server.sh
reduce-memory-server
sudo reduce-memory-server ai-shield
```

Varian server membuka menu terminal melalui SSH dan tidak memasang desktop
launcher, service, daemon, cron, atau automatic trigger.

Di Linux, page-out native membutuhkan kernel 5.10+, Python 3, izin ptrace, dan
`CAP_SYS_NICE`; menu meminta `sudo` saat Normal, Smooth, AI Shield, atau
Aggressive dipilih. Swap yang aktif memberi kernel tempat untuk memindahkan
anonymous pages aplikasi yang dingin. Proses aktif/foreground, process tree
Reduce Memory, locked memory, dan mapping khusus kernel dilewati. Perlindungan
nama AI dan pemilik GPU hanya berlaku saat AI Shield dipilih.

Kalau yang dicari adalah pemakaian rutin tanpa banyak gangguan, gunakan Smooth.
Memory reclaim tidak menghapus virus dan tidak menghapus data aplikasi yang
sedang aktif; Windows maupun Linux bisa memakai kembali memori itu ketika
dibutuhkan.
