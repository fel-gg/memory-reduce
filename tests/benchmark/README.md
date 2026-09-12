# Phase 1 benchmark harness

Pada Linux, raw trial juga merekam minor/major page-fault sebelum, sesudah,
dan delta; pada platform yang tidak menyediakan `/proc` nilainya `null`.
Collector yang sama merekam CPU time, kernel read/write bytes, dan `VmSwap`
before/after/delta bila permission `/proc` mengizinkan; pada Windows CPU time
diambil dari `GetProcessTimes` dan tetap pointer-safe.

`run_benchmark.py` menjalankan baseline, candidate, dan no-op dalam urutan
acak/berimbang. Setiap trial menyimpan exit code, timeout, durasi, output,
repetition, order, dan peak RSS child bila tersedia. Metadata platform serta
SHA-256 source juga disimpan. Available RAM sebelum/sesudah dicatat; gunakan
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

Smoke test aman:

```text
python tests/benchmark/run_benchmark.py --baseline "python -c \"print('baseline')\"" --candidate "python -c \"print('candidate')\"" --noop "python -c \"print('noop')\"" --source src/ReduceMemory.au3 --output build/benchmark-smoke.json
```
