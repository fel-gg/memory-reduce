# Phase 2 benchmark contract — Luna

Dokumen ini adalah kontrak pengukuran awal, bukan klaim bahwa Phase 2 lebih
cepat atau lebih efektif daripada baseline.

## Current harness revision

- Source: `tests/benchmark/run_benchmark.py`
- SHA-256 pada checkpoint revision saat ini: `851C7EF73921266909AF27539C6735E91C8856BD3287B9F9C5775269AA576F83`
- `elapsed_ms`: durasi action command sampai terminal.
- `observation_elapsed_ms`: durasi dari awal trial sampai seluruh retained
  observation selesai.
- `available_bytes_after`: immediate sample setelah action, bukan sample
  terakhir setelah delay.
- `available_bytes_after_delay`: map retained samples sesuai offset dari akhir
  action; key dapat berupa `3`, `15`, `60`, dan seterusnya.
- `summarize_benchmark.py` mempertahankan retained delta per offset dan
  mengecualikan nilai `null` dari kalkulasi, tanpa mengubah missing menjadi
  nol.
- `tests/benchmark/workload_memory.py` memakai page size runtime, marker ready
  atomik, marker retouch/new-allocation yang bounded, checksum private
  payload, dan file-cache backing yang diisi nyata sebelum warmup.
- `tests/phase2/trial_controller.py` dan `trial_config.py` memisahkan
  lifecycle/ownership dari tiga arm serta menolak setup, reset, observer,
  timeout, atau command placeholder yang tidak adil.
- `tests/phase2/decision_rules.py` menerima kriteria gain/noise dan budget
  latency/fault/I/O secara eksplisit; classifier tidak mengarang threshold.

## Validity rules

1. Baseline, no-op, dan candidate harus memakai workload, seed, warmup,
   observer, reset, timeout, dan teardown yang sama.
2. Delay retained tidak boleh masuk ke action latency.
3. Missing metric tetap `null`; tidak boleh diubah menjadi nol saat summary.
4. Trial timeout, setup failure, observer failure, dan teardown failure tetap
   disimpan sebagai status invalid dengan sebab.
5. Engine cost, workload cost, host available memory, cgroup headroom, swap
   usage, dan swap-in/out adalah domain terpisah.
6. Process-tree ownership harus dibuktikan sebelum descendant dimasukkan ke
   engine cost atau dibersihkan.

## Not yet accepted

Fixture deterministik dan controller lifecycle disposable sekarang ada di
`tests/benchmark/` dan `tests/phase2/`, tetapi belum ada manifest baseline
Phase 2 yang diterima atau candidate report apples-to-apples. Gate Phase 1
masih terbuka, sehingga hasil tuning belum boleh dipromosikan. Report di
`build/` tetap artefak historis dengan batas klaim asal dan tidak ditulis ulang.

Control-only distribution run 2026-09-13 tersedia di
`build/phase2/o06-control-20260913/` dengan 5 repeat per label, seed
`20260913`, workload private 32 MiB, dan observer `+0.1/+0.3`. Ketiga label
memakai command workload identik; run ini hanya mengukur variasi harness/no-op
dan tidak boleh dibaca sebagai baseline/candidate reclaim.

## O0.8 — hipotesis dan experiment registry

Status: `PARTIAL_PREP_BLOCKED_DEPENDENCY`; registry dan gate sudah dibekukan untuk persiapan. Ini
bukan hasil eksperimen dan tidak mengubah profile produk.

### Konvensi experiment ID

`P2-<kelompok>-<nomor>` adalah ID stabil. Satu ID hanya boleh mengubah satu
keluarga parameter. Raw trial, manifest, dan summary wajib menyimpan ID ini;
rerun dengan seed/reset baru memakai ID sama dan `run_id` baru. Hasil yang
belum memiliki baseline manifest yang cocok tetap `PENDING_BASELINE`.

| Experiment ID | Hipotesis yang dapat dibantah | Bottleneck yang diukur | Dataset minimum | Primary metric | Biaya/gate penolakan | Task pemilik |
| --- | --- | --- | --- | --- | --- | --- |
| P2-O1-01 | Ambang eligible yang lebih rendah menambah retained gain tanpa membuat biaya/false-attempt melewati baseline | Coverage dan proses kecil yang terlewat | W01, W02, W03 | `G_arm(+60)` dan eligible/attempted/reason counts | Reject bila proteksi berubah, identity stale diterima, atau p95 action >10% baseline | O1.1–O1.6 |
| P2-O2-01 | Kelompok eksekusi native Windows mengurangi overhead per target dibanding jalur existing tanpa mengubah parity Normal/Aggressive | Startup/IPC/handle/worker coordination | W01, W03, W04 | action p95, worker CPU, terminal status | Reject bila timeout, lost result, broad replay, atau parity profile berubah | O2.1–O2.8 |
| P2-O3-01 | Stage global Windows yang dijalankan sekali per sesi memberi manfaat usable yang dapat diatribusikan | Cache/writeback dan I/O global | W05 | retained gain per stage, I/O, stall | Reject bila stage berulang, host-wide mutation tak terkendali, atau stall >20% baseline | O3.1–O3.6 |
| P2-O4-01 | Chunk/range batching Linux berbatas byte dan request mengurangi syscall/latency tanpa gap atau overlap | Range formation dan partial progress | L01, L02, L03 | advised bytes, request count, action p95, integrity | Reject bila partial suffix direplay, mapping berubah tanpa guard, atau range overlap/gap | O4.1–O4.10 |
| P2-O5-01 | Pemilihan scope/capability Linux yang deterministik menghindari false success saat swap/cgroup/privilege berbeda | Scope authorization dan effective allowance | L04, L05, L06, L08 | status capability, scoped headroom, swap/I/O, fault | Reject bila unsupported/denied diklaim sukses, host scope termutasi, atau overlap double-count | O5.1–O5.8 |
| P2-O6-01 | Recovery bounded sesudah action meningkatkan retouch/new-allocation outcome tanpa replay luas | Retention dan bounded recovery | C01, C02, W01, L07 bila tersedia | operational latency, fault/I/O, integrity | Reject bila recovery membuka scan baru, mutasi target di luar snapshot, atau no-op lebih baik | O6.1–O6.6 |
| P2-O7-01 | Kandidat yang lolos mekanisme tetap memberi manfaat operasional pada workload steady-state | Usable headroom, tail latency, release readiness | W01, W05, L07, C02 | primary retained gain + p95/p99/stall | Reject bila gain tidak melewati noise band, fault/I/O budget, atau provenance tidak lengkap | O7.1–O7.8 |

### Registry workload dan rute pengujian

Semua kasus minimum plan memiliki pemilik dan tidak boleh dilewati hanya karena
host Windows ini tidak menyediakan kernel Linux:

| Dataset | Rute saat ini | Status klaim |
| --- | --- | --- |
| W01–W06, C01–C03 | Windows fixture/staging + benchmark controller | Contract/preparation; runtime UI dan apples-to-apples tetap pending |
| L01–L09 | Linux unit/fake adapter sekarang; Linux VM/runner untuk syscall, swap, cgroup, installer | Unit bukan bukti kernel; platform live `PENDING_ENV` |
| C04–C05 | Pure contract/ABI/fixture tests | Tidak menjadi klaim hardware/platform sampai environment tersedia |

### Gate yang dibekukan sebelum candidate

1. Setiap trial menyimpan source hash, artifact hash, config hash, toolchain,
   environment, seed, reset identity, command array, dan experiment ID.
2. Screening awal memakai sekurangnya lima repeat per arm. Kandidat tidak boleh
   dipilih dari satu repeat terbaik; confirmation memakai seed/reset baru dan
   sekurangnya sepuluh repeat setelah baseline diterima.
3. Primary metric adalah retained available delta pada offset yang ditentukan
   workload. `action_duration`, observation duration, process-tree cost,
   faults, I/O, dan integrity adalah dimensi terpisah.
4. Missing/unknown tidak diubah menjadi nol. Timeout, setup, observer,
   capability, dan teardown failure membuat trial invalid dengan alasan.
5. Keputusan hanya `ACCEPT`, `REJECT`, atau `INCONCLUSIVE`; classifier
   `tests/phase2/decision_rules.py` menjadi gate offline, bukan adaptive daemon.

O0.8 dianggap siap sebagai fondasi dokumenter setelah registry ini ditinjau
bersama `decision_rules.py`, `trial_config.py`, dan `baseline_manifest.py`.
Belum ada candidate yang dinyatakan unggul dan belum ada perubahan threshold
produk yang dipilih.

## Audit baseline/arms 2026-09-13 — r2

Trial disposable Windows terbaru memakai `tests/benchmark/Windows-TrimTrial.ps1`
dengan target private 256 MiB yang sama untuk setiap arm. Baseline dan candidate
menjalankan targeted `/RMTRIMTEST`; no-op memakai lifecycle setup/teardown yang
sama tanpa mutator. Observer `+3/+15/+60` memakai seed `20260914`, lima repeat
per arm, dan timeout 90 detik.

Artefak:

- Raw report: `build/benchmark-phase1-audit-20260913-r2.json`
- Summary: `build/benchmark-phase1-audit-20260913-r2-summary.json`
- Raw SHA-256: `6F047D722036F6A589CC9DB89D72AF32C1B3574FCC62572F5E1D62BB906C2FB4`
- Summary SHA-256: `03E877D41B63FD0754BE8F7E099593B86ED849EED695202542F268A9697F55BC`
- Trial result: `15/15` completed, `15/15` exit `0`, lima repeat per arm.
- Integrity check collector: `negative_cpu_trials=0`; terminal PID tidak dibaca
  ulang setelah proses mati.

Median ringkas (bytes signed untuk available delta):

| Arm | Action ms | CPU s | Immediate delta | +3 s | +15 s | +60 s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Baseline | 2499.673 | 0.5625 | -18,751,488 | -8,650,752 | -3,104,768 | 6,021,120 |
| Candidate | 2506.290 | 0.6250 | -20,611,072 | -11,833,344 | -2,908,160 | 8,777,728 |
| No-op | 1672.350 | 0.5000 | -13,029,376 | -3,022,848 | 397,312 | 2,998,272 |

Report ini menutup sebagian G02/O0.4 evidence untuk lifecycle dan collector,
tetapi tidak memilih candidate: confidence intervals overlap, immediate
available delta berada di bawah noise/control variation, dan kedua binary
Windows yang dibandingkan hanya berbeda pada seam/UI reconciliation, bukan
perubahan reclaim algorithm Phase 2. Baseline manifest tetap yang staged di
`build/phase2/g03-baseline-ui-20260913/`; G03 masih membutuhkan review/gate Phase
1 yang tertunda sebelum tuning O0/O1 dapat dipromosikan.

## O4.8/O5.2 contract preparation — 2026-09-13

Sebelum runner Linux tersedia, grid O4.8 dibekukan secara test-only di
`tests/phase2/linux_benchmark_contract.py`. Satu grid wajib mencakup clean dan
dirty file, anonymous dengan dan tanpa swap, shared, mixed COW, THP, sparse,
dan many-small mappings. Setiap result memisahkan `parse_ms`, `plan_ms`,
`ffi_ms`, dan `kernel_ms`; `requested_bytes`, `advised_bytes`, resident
before/after, status, dan integrity tidak boleh saling menggantikan. Complete
tidak diterima tanpa seluruh dimensi timing dan checksum/integrity.

O5.2 contract preparation di `tests/phase2/scope_overlap.py` menjaga scope
parent/child, PID+birth identity, protected/excluded members, shared-charge
overlap, dan membership unknown. Unknown/overlap/protected tidak boleh
menjadi full-scope success. Kedua file hanya membuktikan bentuk input/output
dan safety classification; tidak membuktikan syscall Linux, cgroup migration,
swap, atau retained gain.

## Remote Linux runtime gate — 2026-09-13

Run `34743359103` pada commit `ae39e7c916f288ca9342449e023a97dc7df31d8f`
lulus untuk Ubuntu 22.04 dan 24.04 pada native process page-out, targeted
launcher, safe self-check, Smooth/Aggressive mode gate, serta user-local dan
server installer. Ini menutup bukti runtime gate Linux yang memang dijalankan
workflow; ini bukan O4.8 benchmark grid dan tidak memilih candidate O4/O5/O7.
