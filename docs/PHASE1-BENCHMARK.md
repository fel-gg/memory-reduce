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

Fixture `tests/benchmark/workload_memory.py` sekarang mendukung pola terkontrol
`private`, `file-cache`, `retouch`, `hot`, `new-allocation`, dan `short-lived`.
Semua pola tetap bounded, disposable, dan tidak menyentuh file pengguna; smoke
singkat untuk keenam pola dijalankan sebagai gate Linux CI.

`tests/benchmark/latency_probe.py` menyediakan pengukuran latency workload
terpisah: command dijalankan berulang dengan timeout, raw sample disimpan, lalu
median/p50, p95, dan p99 dihitung secara deterministik. Probe ini mengembalikan
exit non-zero bila ada iteration gagal atau timeout; angka smoke tidak dianggap
sebagai bukti improvement ReduceMemory sampai candidate reclaim nyata dipakai.

Benchmark final wajib mengukur resident/available memory pada +3/+15/+60 detik,
stage/errno, durasi, CPU/peak RSS engine, page faults, disk I/O, swap-in/out,
serta p50/p95/p99 latency workload aktif. Hasil unknown tetap unknown.

Belum ada angka improvement yang ditulis; purge tidak boleh dijalankan di
workstation atau VPS produksi hanya untuk mengisi laporan.

Delayed-sampler smoke valid (host Windows, non-mutating equivalent commands):
one repetition per baseline/candidate/no-op completed with exit code 0 and
samples at +15 and +60 seconds. Raw SHA-256:
16413B72E35F50CC013560A458E98AB347128DC5CD03C5196FBBCC43ED4890AE.
Summary SHA-256:
499E5A923B87BCF049BB0CD7FC7048535F53FFB448EFFE3C73D73EC6D46A37BE.
This validates delayed collection only; baseline and candidate were identical
disposable commands, so it is not an optimization claim.

Harness correctness follow-up (2026-09-12): the Linux `cpu_seconds()` parser now
reads `/proc/<pid>/stat` in the correct function path; previously that parser was
unreachable after the `swap_bytes()` return, which made Linux CPU fields always
unknown. `python -m py_compile` and a live-process CPU probe are now CI gates.
Remote Linux verification passed in run `34684277905`; the Windows job was still
running when this note was written.
