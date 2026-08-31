# Reduce Memory

Reduce Memory adalah utilitas ringan untuk membantu Windows melepaskan memori
yang sedang tidak diperlukan dari RAM.

Proyek ini terinspirasi oleh **Reduce Memory v1.7 dari Sordum Team**. Repo ini
bukan salinan baru yang dibuat dari nol; ini adalah pengembangan lanjutan dari
alur dan tujuan aplikasi tersebut. Fokus utamanya tetap satu: membuat RAM lebih
lega dengan meminta Windows memangkas working set aplikasi dan cache yang aman
untuk dilepas. Ini bukan antivirus, bukan registry cleaner, dan bukan aplikasi
yang mematikan proses sembarangan.

## Pilihan mode

- **Normal Optimize** — pembersihan ringan untuk pemakaian sehari-hari.
- **Aggressive Smooth** — lebih kuat, tetapi dirancang agar kemungkinan lag
  lebih kecil.
- **Aggressive Release** — pelepasan RAM paling kuat; aplikasi mungkin perlu
  memuat ulang cache setelahnya.
- **Aggressive + Delete Temp** — menjalankan Aggressive Release lalu, setelah
  warning, menghapus file temporary dari `%TEMP%` dan `C:\Windows\Temp` secara
  permanen. File yang sedang dipakai akan dilewati.

Program tidak meminta administrator saat dibuka. Izin administrator hanya
diminta ketika mode yang memang membutuhkan operasi memory Windows dijalankan.

## Platform

- [`windows/ReduceMemory_x64.exe`](windows/ReduceMemory_x64.exe) — Windows 64-bit.
- [`windows/ReduceMemory.exe`](windows/ReduceMemory.exe) — Windows 32-bit (x86).
- [`linux/ReduceMemory_Linux.sh`](linux/ReduceMemory_Linux.sh) — companion native
  Linux dengan mode normal, smooth, dan aggressive.

Source canonical ada di [`src/ReduceMemory.au3`](src/ReduceMemory.au3). Lihat
[`docs/PROGRESS.md`](docs/PROGRESS.md) untuk perkembangan upgrade dan batas
verifikasinya. Memory trimming tidak menghapus virus dan tidak menghapus data
aplikasi yang sedang aktif; Windows atau aplikasi tetap dapat mengambil kembali
halaman memori tersebut ketika diperlukan.

