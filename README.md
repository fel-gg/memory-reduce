# Reduce Memory 2.0

Reduce Memory adalah tool kecil buat membantu RAM terasa lebih lega saat
Windows sedang banyak memakai memori.

Proyek ini adalah **Reduce Memory 2.0**, terinspirasi dari Reduce Memory v1.7
buatan Sordum Team.
Di repo ini, alur tersebut kita kembangkan lagi: pilihan mode diperjelas,
Aggressive dibuat lebih kuat, ada versi Smooth supaya tidak gampang bikin lag,
dan ada pilihan untuk membersihkan file Temp.

Intinya tetap sederhana: minta Windows melepas memori yang sedang tidak terlalu
dibutuhkan. Program ini tidak membunuh aplikasi, bukan antivirus, dan bukan
registry cleaner.

Semua aplikasi Windows diperlakukan secara dinamis. Tidak ada daftar nama
aplikasi yang harus diperbarui setiap kali ada software baru. Aplikasi yang baru
di-install akan ikut terdeteksi otomatis; yang dilindungi hanya proses Windows,
aplikasi yang sedang dipakai, dan proses yang baru saja aktif.

## Pilihan mode

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

## Isi folder

- [`windows/ReduceMemory_x64.exe`](windows/ReduceMemory_x64.exe) — Windows 64-bit.
- [`windows/ReduceMemory.exe`](windows/ReduceMemory.exe) — Windows 32-bit (x86).
- [`windows/ReduceMemory.ini`](windows/ReduceMemory.ini) — pengaturan Windows.
- [`src/ReduceMemory.au3`](src/ReduceMemory.au3) — source utama AutoIt.
- [`linux/ReduceMemory_Linux.sh`](linux/ReduceMemory_Linux.sh) — script untuk
  Linux.
- [`docs/PROGRESS.md`](docs/PROGRESS.md) — catatan perkembangan upgrade.

Kalau RAM sedang benar-benar penuh, mode Aggressive bisa membantu cukup banyak.
Kalau yang dicari adalah pemakaian rutin tanpa banyak gangguan, gunakan Smooth.
Memory trimming tidak menghapus virus dan tidak menghapus data aplikasi yang
sedang aktif; Windows bisa memakai kembali memori itu ketika dibutuhkan.
