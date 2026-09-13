# Phase 1 benchmark harness

Pada Linux, raw trial juga merekam minor/major page-fault sebelum, sesudah,
dan delta; pada platform yang tidak menyediakan `/proc` nilainya `null`.
Collector yang sama merekam CPU time, kernel read/write bytes, dan `VmSwap`
before/after/delta bila permission `/proc` mengizinkan; pada Windows CPU time
diambil dari `GetProcessTimes` dan tetap pointer-safe.

`run_benchmark.py` menjalankan baseline, candidate, dan no-op dalam urutan
acak/berimbang. Setiap trial menyimpan exit code, timeout, durasi, output,
repetition, order, direct-child peak RSS, serta process-tree RSS/CPU dan birth
identity bila OS mengizinkannya. Metadata platform serta SHA-256 source juga
disimpan. Available RAM sebelum/sesudah dicatat; gunakan
`--after-seconds 3,15,60` untuk sampel pasca-tindakan pada benchmark final.

Gunakan `summarize_benchmark.py` setelah pengumpulan data untuk median/min/max
serta confidence interval 95% bootstrap yang deterministik per kondisi dan
variasi no-op. Summarizer tidak menyimpulkan improvement; interpretasi tetap
harus mempertimbangkan variasi no-op dan workload latency.

Harness ini tidak melakukan purge sendiri. Command yang mengubah memory state
harus dijalankan pada VM/container disposable dan snapshot dipulihkan di antara
trial ketika menyentuh cache atau standby list.

Workload private-memory untuk runner disposable tersedia di
`workload_memory.py`. Fixture ini hanya mengalokasikan dan menyentuh halaman,
menahan proses tetap hidup, lalu keluar; ia tidak menjalankan ReduceMemory atau
reclaim apa pun:

```text
python tests/benchmark/workload_memory.py --megabytes 256 --seconds 20
```

Fixture Phase 2 dapat menerbitkan marker ready setelah halaman disentuh dan
menunggu marker aksi sebelum retouch atau alokasi kedua. `--checksum-file`
menyimpan checksum private payload sebelum/sesudah aksi. `file-cache` menulis
backing data nyata, melakukan flush/fsync, lalu melakukan warmup mapping; ia
tidak mengandalkan file sparse.

Contoh lifecycle retouch:

```text
python tests/benchmark/workload_memory.py --pattern retouch --ready-file build/fixture.ready --retouch-file build/fixture.retouch --checksum-file build/fixture.checksum
```

Smoke test aman:

```text
python tests/benchmark/run_benchmark.py --baseline "python -c \"print('baseline')\"" --candidate "python -c \"print('candidate')\"" --noop "python -c \"print('noop')\"" --source src/ReduceMemory.au3 --output build/benchmark-smoke.json
```

Untuk trial Windows yang memerlukan target private-memory disposable, gunakan
`Windows-TrimTrial.ps1`. Wrapper ini membuat fixture miliknya sendiri,
menjalankan frontend pada mode `trim` atau lifecycle `noop`, memeriksa exit
code/target identity, lalu membersihkan hanya proses dan file yang dibuat oleh
trial tersebut:

```powershell
pwsh -NoProfile -File tests/benchmark/Windows-TrimTrial.ps1 `
  -FrontendPath build/phase1-ui-reconcile-20260913/ReduceMemory_x64.exe `
  -Action trim -Megabytes 256
```

`run_benchmark.py` tidak membaca ulang PID setelah `communicate()` selesai;
sample terminal memakai observasi terakhir saat proses masih hidup. Ini
mencegah PID reuse membuat process-tree CPU/RSS delta negatif pada trial yang
sudah selesai.
