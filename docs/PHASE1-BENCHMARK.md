# Phase 1 benchmark report

Status: harness tersedia; disposable five-repetition smoke/equivalence run
completed locally. Memory-mutating reclaim comparison on a Linux VM remains
pending.

Latest raw artifacts (kept under ignored `build/`):

- `build/benchmark-m7-final.json` SHA-256
  `DB2ECBBE09FA354B0690F4791B3736F22FB74B4D93D4AC4DBFE38D3AEE7ACCE2`
- `build/benchmark-m7-final-summary.json` SHA-256
  `FBC1F17440C1726722E6B6DB6FD174DADE32CB23B60A8E1A4843646FA38110EF`

The run used seed `20260912`, five repetitions per baseline/candidate/no-op,
randomized order, a 32 MiB private allocation fixture, bounded 10 second
trials, and delayed samples at +1/+3 seconds. It demonstrates collector and
summarizer behavior; because baseline and candidate were intentionally the same
disposable command on this Windows host, it is not an optimization claim.

`tests/benchmark/run_benchmark.py` menyimpan seed, urutan trial, command,
repetition, timeout, exit code, durasi, output mentah, metadata platform, dan
SHA-256 source. Selama child masih hidup, harness mengambil sampel resident size
dan menyimpan `peak_rss_bytes` (atau `null` jika proses terlalu singkat/API tidak
tersedia). Harness juga menyimpan Available RAM sebelum/sesudah dan dapat
menambahkan sampel tertunda dengan `--after-seconds 3,15,60`. Minimal lima
repetition diperlukan untuk hasil Phase 1.

`tests/benchmark/summarize_benchmark.py` menghasilkan median/min/max per label
dan menampilkan variasi no-op sebagai baseline variasi, tanpa mengubahnya menjadi
klaim penghematan.

Benchmark final wajib mengukur resident/available memory pada +3/+15/+60 detik,
stage/errno, durasi, CPU/peak RSS engine, page faults, disk I/O, swap-in/out,
serta p50/p95/p99 latency workload aktif. Hasil unknown tetap unknown.

Belum ada angka improvement yang ditulis; purge tidak boleh dijalankan di
workstation atau VPS produksi hanya untuk mengisi laporan.
