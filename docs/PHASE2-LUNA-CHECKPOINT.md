# Reduce Memory — Phase 2 Luna checkpoint

Dokumen ini menjadi checkpoint tunggal untuk eksekusi Phase 2 dari
`C:\Users\user\ReduceMemory-Phase2-Optimal-Reclaim-Plan-for-Luna.md`.
Phase 2 dimulai sebagai pekerjaan persiapan yang dapat dibuktikan, tetapi
tuning engine belum boleh mengklaim hasil sebelum gerbang fondasi Phase 1
ditutup.

## Aturan status

- `PASS` berarti bukti saat ini benar-benar mencakup acceptance task.
- `PARTIAL` berarti sebagian implementasi atau tes ada, tetapi cakupan belum
  cukup untuk menutup task.
- `BLOCKED_DEPENDENCY` berarti task bergantung pada bukti yang belum ada;
  pekerjaan independen tetap boleh berjalan.
- `NOT_STARTED` berarti belum ada perubahan Phase 2 untuk task tersebut.
- Artefak staging tidak menggantikan `windows/*.exe` aktif dan tidak mengubah
  konfigurasi pengguna.

## G00 — inventory dan target

Status: `PASS` untuk inventaris awal.

- Repo: `C:\Users\user\OneDrive\Dokumen\Desktop\ReduceMemory\ReduceMemory`
- Branch: `codex/phase2-luna-20260913`
- Current continuation HEAD: `ae39e7c916f288ca9342449e023a97dc7df31d8f`
- Working tree memiliki perubahan terarah pada checkpoint, benchmark harness,
  dan test Windows; file untracked `x` dipertahankan dan tidak dihapus.
- Baseline staging yang dapat dirujuk:
  `build/phase1-luna-rerun-20260913-a/BUILD-MANIFEST.json`
- Config staging hash:
  `ReduceMemory.ini` SHA-256
  `C2B98DBA70473A60BF9EC852A1008DB49CBF8887708B9BA64CDA1C9CFF1AEC78`
- Source hash relevan saat inventory:
  - `src/ReduceMemory.au3` — `11BC89D180E4BA000CD0282D306AD76276C735F31DA7029748C05FE2AAC6568E`
  - `windows/native/reduce_memory_worker.c` — `9AA7240D05FD7ED1053FD39888374DF2FC0AF9B836AA8E86B5B84EE95E5A2E3A`
  - `linux/ReduceMemory_Linux.sh` — `F428CAB78FF0090CC0B87C5EDB271E32590EE1A560FB39FC807C1D8847BFAE93`
  - `linux/native/reduce-memory-native` — `B23094B4D7BBFC558622EF14E54C7EB9BD38C06E028AD9B1B5FE5F50B698257F`
- `tests/benchmark/run_benchmark.py` — `851C7EF73921266909AF27539C6735E91C8856BD3287B9F9C5775269AA576F83`
- User config `windows/ReduceMemory.ini` tetap di luar target perubahan.

## G01 — rekonsiliasi Phase 1

Status: `BLOCKED_DEPENDENCY` untuk sign-off Phase 2 tuning.

Yang sudah dibuktikan pada staging/source terbaru dicatat di
`docs/PHASE1-LUNA-CHECKPOINT.md`: build/manifest, frontend dan worker
self-test x86/x64, lifecycle dan parent-death Job Object, protocol, lock,
Temp containment, serta real targeted trim x86/x64.

Gap yang masih material dan tidak boleh ditutup secara implisit:

1. UI interactive: staging x64 sekarang lulus enam mode, ordering, dan
   persistence callback melalui `UiSmoke.Tests.ps1`; smoke x86 pada desktop
   ini belum terminal dan pasangan x86+x64 belum boleh dipromosikan sebagai
   gate penuh.
2. Linux session-accounting, targeted launcher, mode gate, dan installer live
   sudah lulus remote CI Ubuntu 22.04/24.04 pada run `34743359103`; host
   Windows ini tetap tidak memiliki WSL sehingga bukti lokal Linux belum ada.
3. Concurrent Temp path-swap runtime belum memiliki bukti lengkap.
4. Benchmark apples-to-apples final belum diulang setelah perbaikan harness.

Remote CI run `34743359103` adalah evidence terkini untuk gate Linux tersebut;
run ini tidak menutup gap x86 UI, concurrent Temp, atau benchmark candidate.

## G02 — integritas benchmark

Status: `PARTIAL` menuju `PASS`.

- `tests/benchmark/run_benchmark.py` sudah memisahkan action duration dan
  immediate sample dari retained observations.
- `elapsed_ms` sekarang berhenti pada akhir command; `observation_elapsed_ms`
  mencakup retained observation window.
- Sepuluh unit benchmark dan native unit test lulus; smoke clock membuktikan action
  `65.861 ms` terpisah dari observation `166.29 ms`.
- `workload_memory.py` sekarang memakai runtime page size tervalidasi, marker
  ready/retouch/new-allocation bounded, checksum private payload, dan backing
  file-cache yang benar-benar diisi lalu di-flush/fsync sebelum warmup.
- Fixture tests mencakup page pattern deterministic, retouch sesudah marker,
  checksum berubah setelah retouch, file-cache real backing, private/hot/
  new-allocation/short-lived bounded runs, dan unusable page-size rejection.
- `summarize_benchmark.py` sekarang merangkum retained available deltas per
  offset tanpa mengubah null menjadi nol; regression test memastikan sample
  missing tidak masuk median.
- Benchmark collector sekarang merekam process-tree RSS/CPU delta, PID birth
  identity, PID tree scope, dan status `complete`/`direct_only`; direct child
  metrics tetap dipisahkan untuk membandingkan overhead engine versus workload.
- Workflow verification hash setelah memasukkan regression discovery:
  `.github/workflows/verify.yml` —
  `E9A3F16EABCE4742E355A67004CEC028317F5BF5F36D06E9682E29DEB8252DCA`.
- H0.2 preparation memiliki 5 contract tests untuk denied/unsupported,
  ready-missing, result-missing-after-mutation, wrong-session, timeout,
  partial, dan independent-stage continuation. Ini masih fake adapter test
  harness; belum menjadi bukti adapter produksi.
- Linux verification workflow sekarang menjalankan seluruh benchmark fixture
  discovery dan Phase 2 contract discovery, bukan hanya latency test lama;
  release workflow contract lokal `4/4` tetap lulus setelah perubahan.
- Hash fixture revision: `tests/benchmark/workload_memory.py` —
  `1A327BC97B7F371632B78AC7DC1922C5A6F395214FF7E778DDB3B9A0A4EFE6FB`;
  `tests/benchmark/test_workload_memory.py` —
  `234B1DF5113B26EA72650776640A60249DD3A30AD560289C6305194BAF823574`.
- Harness revision belum diberi manifest Phase 2 karena fixture lifecycle,
  descendant accounting, dan apples-to-apples trial belum selesai.
- `tests/phase2/trial_controller.py` menyediakan controller test-only yang
  disposable dengan phase `setup -> ready -> action -> observe -> integrity
  -> teardown`, PID birth-identity ownership, bounded stdout/stderr, timeout
  classification, dan cleanup yang hanya menyentuh proses milik trial.
- `tests/phase2/test_trial_controller.py` lulus `8/8` bersama contract
  harness; discovery benchmark lulus `10/10`. Ini membuktikan lifecycle
  harness pada Windows, tetapi belum menjadi bukti adapter optimizer produksi.
- H0.3 compatibility harness lulus `6/6` untuk producer lama/metadata
  opsional, truncation, overflow, duplicate identity, unknown metadata, dan
  batas 8 MiB/16.384 record; ini masih model boundary test-only.
- `tests/phase2/reclaim_plan.py` kini memodelkan immutable `ExecutionPlan`,
  scoped stage identities, serta `ExecutionLedger` yang menolak replay,
  mismatch session, dan stage di luar snapshot. `test_reclaim_plan.py` lulus
  `5/5`; total discovery Phase 2 saat ini `13/13`.
- Hash controller: `tests/phase2/trial_controller.py` â€”
  `7462334E425000BADD7F1AD3B883F7D645DA9A34645D735D1FB22088E6FCC31D`;
  `tests/phase2/test_trial_controller.py` â€”
  `694A230C2921FF4BC1040B3F594DFC3C91B87AB883216A274983B85E65E211AD`.
- Hash plan/ledger: `tests/phase2/reclaim_plan.py` â€”
  `6F79A371B8EFD9FAB249D0D511448A86823D20D156A9A4B049C3648313AF0EA2`;
  `tests/phase2/test_reclaim_plan.py` â€”
  `0841C2A0E9C81E7549DBC52F928C4F8C9F3DE1EB668E741B3A79B19E9B664E24`.
- Compatibility harness H0.3: `tests/phase2/compatibility_harness.py` —
  `ED89E56E66BE0B96D9F61BAF9F995405FB745045D183E441614732741A7BECA1`;
  `tests/phase2/test_compatibility_harness.py` —
  `27C4637965FB10CAB0140512A9A5E94707C61E7209414D4B828AC814BB6221BE`.
- O0.1 baseline helper: `tests/phase2/baseline_manifest.py` —
  `7044C016F94257A4C7BE0CD0869E9D8DA4BC1E5B5E71924386A38843FBDB347D`;
  `tests/phase2/test_baseline_manifest.py` —
  `2E1C77CEC11EDFA565D3714EFAD42AE99292656A0EE05054F7F46791914AC762`.
- O0.5 fairness validator: `tests/phase2/trial_config.py` —
  `F0960F9A6F4DB4EACA7EEEF97DC7653345CD47BC4351E0ED4D141952A6B68EC1`;
  `tests/phase2/test_trial_config.py` —
  `FCAE1689D27FBAAF4F9B89D65AC2DC1646AA4FDFE8C0DA088F1928093FF90B8E`.
- O0.7 decision classifier: `tests/phase2/decision_rules.py` —
  `4FF99D5C42303CB4D18D6BD0B3814F638B3CEB8DF9CF54831FF7F42405461F2A`;
  `tests/phase2/test_decision_rules.py` —
  `6BE04820DB52ED3EBDD022669FA277963F979EA3ACACC0F7692CE3492F590C86`.
- Phase 2 discovery sekarang lulus `33/33`: controller, plan/ledger,
  compatibility boundary, dan baseline-manifest tests seluruhnya masuk dalam
  discovery workflow.
- O0.6 control-only distribution run `build/phase2/o06-control-20260913/`
  menjalankan 5 repeat per label dengan seed `20260913`, workload private
  32 MiB, observer `+0.1/+0.3`, dan raw/summary terpisah. Semua tiga label
  memakai workload identik sehingga hasil ini hanya mengukur variasi harness,
  bukan reclaim product atau candidate improvement. Raw SHA-256:
  `44340A440960097764AFCA3F4068F4B058A190EED7BB84E7A9FBB92F0583F411`;
  summary SHA-256:
  `E0C5A143B561D56470DDB03373DD2B40E3128F5501C927D3E6A08EE95C5EF2EB`.

## G03 — baseline final

Status: `BLOCKED_DEPENDENCY` sampai G01 dan G02 ditutup.

Staging build belum dipromosikan menjadi baseline final Phase 2. Tidak ada
candidate tuning, perubahan threshold, atau perubahan policy engine yang
boleh dipilih sebelum record baseline memenuhi source hash, artifact hash,
toolchain, environment, config, dan correctness evidence.

## Phase 2 task matrix

| Kelompok | Status | Catatan bukti |
|---|---|---|
| G00 | PASS | Inventory dan ownership dicatat di atas |
| G01 | BLOCKED_DEPENDENCY | UI x64 staging lulus, tetapi pasangan x86+x64 penuh, Linux live/session/installer, Temp path-swap runtime, dan final benchmark gate masih material |
| G02 | PARTIAL_PREP | Collector PID-terminal reuse guard sudah diperbaiki dan dites (`11/11` benchmark tests); Windows disposable apples-to-apples r2 menghasilkan 15/15 trial valid dengan +3/+15/+60, tetapi workload/arm bukan candidate reclaim algorithm Phase 2 dan Linux/VM coverage belum |
| G03 | BLOCKED_DEPENDENCY | Manifest kandidat terbaru `build/phase2/g03-baseline-ui-20260913/BASELINE-MANIFEST.json` sudah dibuat dan diverifikasi untuk source/config/frontend+worker x86/x64; review Phase 1 pasangan UI/Linux/Temp gates masih menunggu |
| O0.1 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Helper `baseline_manifest.py` + tests lulus; manifest aktual `build/phase2/g03-baseline-ui-20260913/` terverifikasi dengan source/config/frontend+worker x86/x64 dan build manifest; pemilihan baseline final tetap menunggu G03 |
| O0.2 | PARTIAL_PREP | Controller disposable + `8/8` lifecycle tests; belum boleh dipakai untuk tuning sebelum baseline final |
| O0.3 | PARTIAL | Runtime page-size, marker, checksum, dan real file-cache sudah ada; seluruh matrix lifecycle belum |
| O0.4 | PARTIAL_PREP | Process-tree RSS/CPU/identity collector dan Windows wrapper trial r2 sudah diuji; terminal PID reuse guard lulus (`11/11`) dan +3/+15/+60 tersedia, tetapi descendant/VM/Linux workload split belum lengkap |
| O0.5 | PARTIAL_PREP | `trial_config.py` + `5/5` tests menolak setup/reset/observer/timeout berbeda dan placeholder sleep; belum ada pilot observer overhead |
| O0.6 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Control-only 5-repeat raw/summary tersedia; baseline product/no-op dan VM snapshot belum |
| O0.7 | PARTIAL_PREP | `decision_rules.py` + `5/5` tests memaksa kriteria gain/noise/latency/fault/I/O eksplisit; angka workload belum dibekukan dari O0.6 |
| O0.8 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `docs/PHASE2-BENCHMARK.md` sekarang membekukan registry hypothesis/experiment ID, dataset route, dan gate; baseline final/apples-to-apples tetap menunggu G01/G03 |
| H0.1 | PARTIAL_PREP | `reclaim_plan.py` + `5/5` tests memodelkan immutable plan/ledger; adapter Windows/Linux produksi dan acceptance baseline belum |
| H0.2 | PARTIAL_PREP | `contract_harness.py` + 5 contract tests, `trial_controller.py` + 3 lifecycle tests, dan plan/ledger tests; belum terhubung ke adapter produksi |
| H0.3 | PARTIAL_PREP | `compatibility_harness.py` + `6/6` tests untuk old/new metadata, truncation, overflow, duplicate identity, 8 MiB, dan 16.384-record boundary; belum menggantikan parser produksi |
| H0.4 | PARTIAL_PREP | `RM_BuildWindowsProcessStage` + `RM_ValidateWindowsProcessStage` now wrap the existing Windows worker path; `/RMPLANSELFTEST` x64 exits `0`, Au3Check/build pass; x86 handoff and Linux adapter evidence remain pending |
| H1.1 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `docs/PHASE2-PORTABILITY.md` + `tests/phase2/abi_contract.py` define x86/x64/Linux-x86_64 widths, checked address+length/count/page-size/signed-delta rules; live Linux/alternate ABI evidence pending |
| H1.2 | PARTIAL_PREP_BLOCKED_DEPENDENCY | AutoIt parser now rejects metric integers above exact 2^53-1 before conversion; `/RMWIRESELFTEST=0`, protocol docs and x64 wire/build evidence updated; cross-platform golden producer/consumer evidence pending |
| O1.1 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Linux native helper now emits reconciliable `selection_*` counts and uses one terminal `selection_reason` per snapshot (`protected`, `below_threshold`, `active`, `invalid_identity`, `eligible`); 21 Linux unit tests pass and Bash fixture/failure adapters pass, Windows parity/runtime evidence pending |
| O1.2 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Windows worker `/selection-selftest` now covers case-insensitive exact executable names, Unicode name, boundary mismatch, malformed unterminated filter, and null filter on x86/x64; mixed-bitness/path fixture and runtime coverage matrix remain pending |
| H1.3 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Build.Tests now verifies explicit x86 frontend/worker and x86_64 frontend/worker manifest pairs, PE machine, hashes, and runtime self-tests; live x86 handoff and wrong-pair negative fixture remain pending |
| H1.4 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Linux capability probe now distinguishes missing `pidfd`/`process_madvise` syscall, unknown ISA, and permission/seccomp denial without mutating a target; 30 native unit tests pass, but live Linux kernel/capability matrix remains pending |
| O1.3 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Linux page-out memusatkan rekonsiliasi PID birth identity dan mapping identity melalui `snapshot_identity_status`; 27 native unit tests lulus, tetapi snapshot-change runtime matrix dan cross-platform ledger evidence masih menunggu host Linux/Phase 1 gate |
| O1.4+ | NOT_STARTED | Dependensi fondasi dan coverage experiments lanjutan belum lulus |
| O2.1 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Benchmark r2 sudah memisahkan action duration, observation window, process-tree CPU/RSS, dan no-op variation; breakdown worker/query/history per phase dan same-target production candidate masih pending |
| O2.2 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `tests/phase2/parity_fixture.py` + `test_parity_fixture.py` membekukan snapshot target, session identity, bounded mutation, dan fallback reason/status (`6/6`); adapter produksi dan runtime parity belum |
| O4.1 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `Mapping`/`parse_smaps` sekarang mempertahankan Anonymous, Private/Shared Clean/Dirty, Swap, Kernel/MMU page size, AnonHugePages, dan unknown metadata secara eksplisit; 29 native unit tests lulus, tetapi fixture kernel nyata dan eligibility differential belum |
| O4.2 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `runtime_page_size` dan `validate_mapping_range` menolak page-size invalid, bounds/overflow, dan unaligned range sebelum advice; invalid fixture membuktikan mutator spy tidak dipanggil; 32 native unit tests lulus, live page-size/mapping-change matrix pending |
| O4.3 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `mapping_exclusion_reason` memusatkan locked/device/special-path/PFNMAP/HugeTLB/non-readable protection dan membedakan THP (`AnonHugePages`) dari `ht`; differential kernel fixtures belum tersedia; 33 native unit tests lulus |
| O4.4 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `chunk_mapping_range` membagi mapping dengan parent identity/offset, page alignment, dan budget byte; pure coverage/no-gap tests lulus, tetapi integrasi iovec dan benchmark budget masih menunggu O4.5/O4.8 |
| O4.5 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `build_iovec_batches` menegakkan dua batas per-call (bytes dan iovec count) dengan tests packing/oversize; belum mengganti default batch atau diuji pada kernel latency nyata; 37 native unit tests lulus |
| O4.6 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `remaining_ranges` kini memiliki coverage exact-boundary, zero-progress, mid-chunk suffix, dan over-advice tanpa prefix replay; syscall errno/target-exit integration Linux masih pending; 40 native unit tests lulus sebelum O4.7 tambahan |
| O4.7 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `pageout_process` kini memiliki monotonic deadline/cancel boundary, mapping revalidation, `bytes_deferred`, CLI `--deadline-ms`, dan caller-owned `--cancel-file`; 49 native unit tests lulus, tetapi timeout/target-exit/cancel runtime Linux belum tersedia |
| O4.8 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `tests/phase2/linux_benchmark_contract.py` membekukan grid clean/dirty file, anonymous no-swap/swap, shared, mixed-COW, THP, sparse, dan many-small serta timing/coverage/integrity dimensions (`8/8`); raw kernel benchmark belum tersedia |
| O4.9 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `tests/phase2/linux_advice_policy.py` memastikan COLD hanya hint tanpa release credit dan PAGEOUT credit tetap advice coverage, dengan identity/capability/error guard (`8/8`); perbandingan syscall nyata belum tersedia |
| O4.10 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Kontrak O4.9 memisahkan strategy result, advised bytes, observed resident delta, dan status; pemilihan strategy default tetap menunggu O4.8/O4.9 Linux data |
| O5.1 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Native `command_reclaim` sekarang memverifikasi mountpoint cgroup2, final-component symlink, device/inode identity sebelum write, dan memakai `O_NOFOLLOW`; unit scope/race lulus, tetapi namespace/mount/ownership live dan delegated-cgroup matrix belum tersedia |
| O5.2 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `tests/phase2/scope_overlap.py` membekukan klasifikasi eligible/protected/excluded/overlap/unknown/outside berbasis PID+birth dan child scope (`8/8`); snapshot cgroup live dan shared-charge kernel evidence belum tersedia |
| O5.3 | PARTIAL_PREP_BLOCKED_DEPENDENCY | `tests/phase2/linux_scope_policy.py` menghitung allowance swap efektif sebagai minimum host/scope/ancestor dan mempertahankan unknown (`9/9`); swap/zram/swap.max live matrix belum tersedia |
| O5.4 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Policy contract memilih targeted process, scoped cgroup, deferred, unsupported, atau `experiment_required` secara deterministic tanpa double-request; runtime capability/overlap evidence belum tersedia |
| O5.5 | PARTIAL_PREP_BLOCKED_DEPENDENCY | Bash cgroup stage sekarang merekam request, duration, scope `memory.current` delta (termasuk unknown/error), dan tidak retry otomatis; EAGAIN/error live serta duplicate/lost-result matrix masih pending |

## Safety boundary

Sampai checkpoint ini tidak ada global trim, purge, cache flush, penghapusan
file pengguna, penggantian executable aktif, perubahan registry/pagefile,
commit, push, tag, publish, atau remote workflow dispatch.

## Full plan-ID coverage audit — 2026-09-13

Audit terhadap `ReduceMemory-Phase2-Optimal-Reclaim-Plan-for-Luna.md`
menemukan 84 task ID. Baris matrix di atas mencakup fondasi yang sudah
memiliki artefak; ID berikut sekarang dicatat eksplisit supaya tidak hilang
dari checkpoint. Status ini adalah status acceptance, bukan prediksi bahwa
implementasi akan otomatis lulus.

| Task ID | Status saat ini | Alasan/bukti batas |
| --- | --- | --- |
| H1.5 | `BLOCKED_DEPENDENCY` | Profiling parse/plan/FFI/kernel Linux belum dapat dijalankan tanpa runner Linux; belum ada migrasi hot path yang boleh dipilih |
| H1.6 | `BLOCKED_DEPENDENCY` | Portable runtime build dan capability matrix Linux belum tersedia; ABI pure tests bukan live support evidence |
| O1.4 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | Proteksi/identity contracts existing dan scope overlap fixtures ada; differential native/fallback policy matrix live belum |
| O1.5 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | Minimum-size fields existing dan benchmark contract ada; grid Windows/Linux target kecil live belum |
| O1.6 | `BLOCKED_DEPENDENCY` | Confirmation coverage belum boleh dipilih sebelum O0.7/G01 baseline ditutup |
| O2.3 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `execution_table.py` + `11/11` tests membekukan snapshot/identity, stale-PID deferral, query denial, handle quota, cancellation-before-action, dan no-replay outcome; production worker integration tetap menunggu O2.1/x86 lifecycle |
| O2.4 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `group_targets` dan bounded progress payload menjaga seluruh plan tetap dikunjungi tanpa stop-when-enough (`11/11`); UI/worker runtime, slow API, pipe backpressure, dan x86 lifecycle masih pending |
| O2.5 | `BLOCKED_DEPENDENCY` | Observation/recovery consolidation belum dibenarkan oleh profiling dan O6 recovery fixtures |
| O2.6 | `BLOCKED_DEPENDENCY` | Native Normal activation membutuhkan parity/runtime evidence O2.2/O2.5 yang belum ada |
| O2.7 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | Lifecycle/parent-death contracts ada; GUI close/cancel, timeout, UAC, dan lost-result live matrix belum |
| O2.8 | `BLOCKED_DEPENDENCY` | Tidak ada candidate native Windows yang boleh dipilih sebelum O2.7 dan O0.7 confirmation |
| O3.1 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `stage_ablation.py` + `9/9` tests memberi inventory stage/capability/endpoint/prerequisite dan independent invocation contract; fake API/live stage inventory production belum |
| O3.2 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | One-difference ablation arms, prerequisite order, cache postcondition, dan no-mutation policy ada (`9/9`); baseline final/workload controlled/live spy belum |
| O3.3 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `validate_cache_postcondition` menolak policy change dan membatasi claim saat postcondition unavailable (`9/9`); API/privilege VM matrix live belum |
| O3.4 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `select_stage_measurements` memisahkan keep/no-change/inconclusive dan menolak double-count endpoint (`9/9`); timeline/latency/IO workload belum |
| O3.5 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | Inventory global-stage identity + prerequisite/order contract menolak duplicate invocation (`9/9`); session/recovery runtime ledger belum |
| O3.6 | `BLOCKED_DEPENDENCY` | Combination confirmation belum tersedia; no-change tetap kemungkinan yang sah |
| O5.6 | `BLOCKED_DEPENDENCY` | Secondary/global cache stage memerlukan Linux VM/permission/failure matrix |
| O5.7 | `BLOCKED_DEPENDENCY` | Server/container/delegated cgroup/swap matrix memerlukan runner Linux disposable |
| O5.8 | `BLOCKED_DEPENDENCY` | Strategi scope tidak boleh dipilih sebelum O5.6/O5.7 dan O0.7 |
| H2.1 | `BLOCKED_DEPENDENCY` | Topology probe read-only belum dijalankan pada target Linux/VM yang diklaim |
| H2.2 | `BLOCKED_DEPENDENCY` | NUMA/domain workload evidence belum tersedia; fake topology bukan support claim |
| H2.3 | `BLOCKED_DEPENDENCY` | Storage/NUMA cost grid belum tersedia |
| H2.4 | `BLOCKED_DEPENDENCY` | Probe overhead production belum dapat dibandingkan dengan live baseline |
| O6.1 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `profile_contract.py` + `7/7` tests membekukan bentuk profile/experiment, bounds parameter, revision, artifact hash, dan holdout digest; pemilihan nilai final tetap menunggu O2/O3/O4/O5 evidence |
| O6.2 | `BLOCKED_DEPENDENCY` | Normal candidate belum memiliki same-scope data baru |
| O6.3 | `BLOCKED_DEPENDENCY` | Aggressive incremental benefit/cost belum diukur |
| O6.4 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | Recovery ledger dan event-driven fixtures ada; live retouch/hot/new-allocation attribution belum |
| O6.5 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `profile_contract.py` + `7/7` tests memisahkan accepted/rejected/needs-confirmation dan mewajibkan confirmation sebelum profile bisa dianggap accepted; candidate decision berbasis primary data belum ada |
| O6.6 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `profile_contract.py` + `7/7` tests hanya mengizinkan integrasi profile jika decision accepted, artifact/revision valid, dan user overrides dipertahankan; profile final masih menunggu O6.5 |
| H3.1 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `interface_evolution.py` + `7/7` tests membatasi major mismatch, missing required field, unknown semantic field, optional metadata, capability subset, dan pre-mutation stage readiness; supported runtime pair/evolution integration belum |
| H3.2 | `PARTIAL_PREP` | Build scripts/manifests/provenance lokal ada; paket lokal Phase 2 berhasil diverifikasi; rebuild provenance lintas environment dan final dependency review belum |
| H3.3 | `BLOCKED_DEPENDENCY` | Reproducibility/support level final membutuhkan candidate final, Linux platform, dan x86 runtime evidence |
| H3.4 | `PARTIAL_PREP` | `interface_evolution.py` + `7/7` tests mensimulasikan backend capability removal, version mismatch, optional field, semantic change, dan independent stage readiness; final adapter integration belum |
| O7.1 | `BLOCKED_DEPENDENCY` | Candidate final dan correctness gate belum dipilih |
| O7.2 | `BLOCKED_DEPENDENCY` | Windows r2 bukan candidate reclaim algorithm Phase 2; final fair benchmark belum |
| O7.3 | `BLOCKED_DEPENDENCY` | Usable headroom allocate-and-touch subtrial belum dijalankan |
| O7.4 | `BLOCKED_DEPENDENCY` | Tail latency/stall/integrity final belum tersedia |
| O7.5 | `BLOCKED_DEPENDENCY` | x86 UI, screenshot/trace, close/cancel, Linux CLI/installer live belum lengkap |
| O7.6 | `PARTIAL_PREP` | Paket lokal `build/phase2-package-final-20260913/ReduceMemory-3.0-phase2.zip` dibuat dari Windows staging + Linux tree; `Verify-ReleasePackage.ps1` lulus setelah ekstraksi/hash; status final-candidate tetap menunggu O7.1/O7.5 |
| O7.7 | `BLOCKED_DEPENDENCY` | Keputusan candidate/no-change seluruh O0–O6 belum dapat ditulis dari raw final |
| O7.8 | `PARTIAL_PREP_BLOCKED_DEPENDENCY` | `docs/PHASE2-HANDOFF.md` sudah ada sebagai partial evidence-first handoff; final handoff menunggu O7.7/H4.2 |
| H4.1 | `BLOCKED_DEPENDENCY` | Evaluasi kernel/hypervisor final harus memakai hasil O2–O7 nyata; belum boleh menyimpulkan dari pure fixtures |
| H4.2 | `BLOCKED_DEPENDENCY` | No-driver/RFC decision final menunggu H4.1; tidak ada driver dipasang |

## Update lanjutan 2026-09-13 — H0.4, H1.1/H1.2, O1.1

- H0.4 mendapat seam produksi Windows yang sempit: `RM_RunNativeProcessPass`
  sekarang membentuk dan memvalidasi descriptor stage melalui
  `RM_BuildWindowsProcessStage`/`RM_ValidateWindowsProcessStage` sebelum
  memanggil worker yang sudah dimiliki Job Object. `/RMPLANSELFTEST` staging
  x64 exit `0`; invalid profile dan include-only cases diuji tanpa mutator.
- H1.1 menambahkan `docs/PHASE2-PORTABILITY.md` dan pure ABI helpers/tests
  untuk pasangan Windows x86/x64 dan Linux x86_64, checked address+length,
  count, page-size, dan signed delta. Discovery Phase 2 sesudahnya lulus
  `38/38`.
- H1.2 memperketat parser AutoIt agar metric yang melewati exact integer
  ceiling `2^53-1` ditolak sebelum konversi double. `/RMWIRESELFTEST` staging
  x64 exit `0`; protocol docs, compatibility harness, dan regression test
  numeric overflow diperbarui.
- O1.1 pada Linux native helper sekarang mengeluarkan satu alasan seleksi per
  snapshot (`selection_protected`, `selection_below_threshold`,
  `selection_active`, `selection_invalid_identity`, `selection_eligible`).
  Bash launcher mengagregasi dan menampilkan counter tersebut terpisah dari
  attempted/RSS measurement. Linux native unit test lulus `21/21`; fixture
  isolation dan fake-syscall adapter lulus. Session-accounting dan installer
  runtime diberi `SKIPPED` pada host Windows karena memerlukan Linux/WSL2.
- Probe PE dengan `GetBinaryTypeW` tidak dipertahankan karena terbukti dapat
  menggantung pada executable staging OneDrive. Tidak ada pemeriksaan blocking
  baru yang masuk ke startup; H1.3 tetap pending untuk probe pasangan binary
  yang aman dan benar-benar teruji.

## Update lanjutan 2026-09-13 — H1.4 capability boundary

- `linux/native/reduce-memory-native` sekarang memiliki `syscall_capability()`
  dan `pidfd_capability()` yang memisahkan `supported`, `unsupported`, dan `permission_denied`, dengan
  alasan `syscall_missing`, `unknown_architecture`, `non_linux`, atau
  `permission_or_seccomp`. Probe memakai argumen kosong/invalid yang tidak
  menyentuh proses target; tidak ada fallback global yang dipicu oleh probe.
- `command_check` dan `pageout` meneruskan status capability serta `probe_errno`
  saat capability tidak tersedia. Wrapper boolean lama dipertahankan agar
  kontrak internal tidak pecah.
- Regression suite Linux native lulus `27/27`; `py_compile`, Bash syntax, dan
  `git diff --check` juga lulus. Karena host ini Windows tanpa WSL2, hasil ini
  tetap `PARTIAL_PREP_BLOCKED_DEPENDENCY`, bukan bukti runtime Linux atau
  efektivitas reclaim.
- O1.3 mendapat helper produksi `snapshot_identity_status()` yang menyatukan
  pemeriksaan start-time dan mapping sebelum serta sesudah mutasi. Perubahan
  identitas/mapping tetap menjadi hasil unknown/failed yang terpisah, bukan
  zero-byte success; unit Linux naik menjadi `27/27`.
- O4.1 menambahkan metadata mapping yang diperlukan sebagai data observasi saja;
  field baru tidak otomatis mengubah eligibility. Nilai malformed/negatif untuk
  field opsional dipertahankan sebagai `None`, sehingga tidak berubah menjadi
  angka nol yang menyesatkan.

H1.4 kemudian diperketat dengan `pidfd_capability()`: probe `pidfd_open` dan
`process_madvise` kini dapat membedakan API hilang, ISA tidak dikenal, dan
permission/seccomp denial secara berurutan sebelum target discovery. Native
unit terbaru lulus `30/30`; ini tetap belum menggantikan matrix kernel Linux
nyata, capability container, atau `CAP_SYS_NICE`/ptrace evidence.
- O4.2 menambahkan page-size/range guard sebelum pembentukan iovec. Range
  invalid berakhir sebagai `invalid_range` tanpa `process_madvise`; validasi
  ini belum dianggap bukti runtime pada page-size non-host atau kernel nyata.
- O4.3 memusatkan policy pengecualian mapping tanpa memperluas eligibility.
  Regression test memastikan explicit `ht` tetap ditolak, sedangkan THP biasa
  hanya menjadi metadata dan tidak otomatis ditolak.
- O4.4 menambahkan pure chunk builder yang menghasilkan coverage lengkap tanpa
  gap/overlap dan menolak budget non-page-multiple. Builder belum dipakai untuk
  mengubah ukuran batch produksi sebelum data latency/coverage tersedia.
- O4.5 menambahkan pure batch packer yang mempertahankan urutan chunk dan
  menolak chunk yang melampaui budget. Integrasi ke syscall tetap ditahan
  sampai partial-return/latency experiment O4.6/O4.8 tersedia.
- O4.6 memperluas regression partial-return agar suffix mempertahankan parent
  identity dan tidak menghasilkan panjang negatif atau replay prefix. Ini masih
  pure accounting evidence, bukan bukti kernel mengembalikan partial bytes.

## Update 2026-09-13 — penutupan O0.8 sebagai persiapan

`docs/PHASE2-BENCHMARK.md` sekarang memiliki registry hypothesis/experiment ID
P2-O1-01 sampai P2-O7-01, mapping ke W01–W06/L01–L09/C01–C05, primary metric,
biaya, aturan reject, dan gate screening/confirmation. Ini menutup pekerjaan
persiapan O0.8 secara dokumenter, tetapi status tetap
`PARTIAL_PREP_BLOCKED_DEPENDENCY` karena baseline final G03 dan live platform
gate belum tersedia. Tidak ada threshold, profile, atau engine policy yang
diubah berdasarkan registry tersebut.

Sesudah perubahan ini, `python -m unittest discover -s tests/phase2 -p
"test_*.py"` lulus `33/33`, benchmark discovery lulus `10/10`,
`Au3Check` source lulus `0 error(s), 0 warning(s)`, PowerShell test yang
diubah berhasil diparse, dan `git diff --check` tidak menemukan whitespace
error. Proses aktif milik pengguna PID `19840` tidak disentuh.

## Verifikasi terkini — 2026-09-13

Setelah H1.4/O1.3, verifikasi lokal terbaru adalah:

- Phase 2 discovery: `38/38` lulus.
- Benchmark discovery: `10/10` lulus.
- Linux native unit: `27/27` lulus.
- `python -m py_compile`, Bash syntax, dan `git diff --check`: lulus.
- Pada host Windows ini, `reduce-memory-native check` berhenti aman dengan
  `native_status=unsupported`, `capability_reason=non_linux`; tidak ada target
  yang disentuh.
- PID aktif pengguna `19840` tetap berjalan; tidak ada commit/push atau
  penggantian executable aktif.

Setelah audit H1.4/O4.6, angka native terbaru menjadi `40/40` dan benchmark
discovery menjadi `11/11` setelah regression guard terhadap PID reuse terminal.
Phase 2 discovery tetap `38/38`; `py_compile`, Bash syntax, PowerShell parser,
Au3Check (`0 error(s), 0 warning(s)`), dan `git diff --check` juga lulus.
Staging Windows `phase1-ui-reconcile-20260913` memberi enam probe frontend x64
dengan exit `0`. UI smoke eksternal masih `PENDING_ENV` karena instance mutex
aplikasi pengguna aktif tidak boleh diambil alih atau dihentikan.

Benchmark Windows r2 (`build/benchmark-phase1-audit-20260913-r2.json`) valid
`15/15` trial, seluruh exit `0`, dan memiliki sampel `+3/+15/+60`; kandidat
belum dipilih karena confidence interval overlap dan arm candidate belum
mengubah algoritme reclaim Phase 2. Manifest baseline staged
`build/phase2/g03-baseline-20260913/BASELINE-MANIFEST.json` dibuat serta
diverifikasi, tetapi status G03 tetap tertahan sampai gate Phase 1 ditutup.
Host ini tidak memiliki distro WSL (`wsl --status` exit `50`), sehingga bukti
Linux live, installer, capability kernel, dan benchmark O4.8 tetap
`PENDING_ENV`.

## Update O4.7 — bounded execution dan residual range — 2026-09-13

`linux/native/reduce-memory-native` sekarang menerima deadline monotonic,
cancel callback, dan caller-owned `--cancel-file` pada `pageout_process`. Guard diperiksa ulang sebelum setiap batch
dan setiap scalar continuation; helper tidak menjanjikan penghentian seketika
untuk syscall yang sedang blocking. Jika guard menghentikan sesi, seluruh
suffix yang belum diproses dijumlahkan sebagai `bytes_deferred`, status
`deadline`/`cancelled` diteruskan melalui CLI `control_status`, dan tidak ada
advice tambahan setelah boundary tersebut.

Launcher Bash meneruskan `REDUCE_MEMORY_NATIVE_DEADLINE_MS` serta optional
`REDUCE_MEMORY_NATIVE_CANCEL_FILE` ke helper dan mengagregasi
`bytes_deferred` terpisah dari bytes yang benar-benar di-advice.

Regression native sekarang lulus `49/49`, termasuk cancel-before-advice,
residual-byte accounting, guard priority, dan parser `--deadline-ms`. Ini
menutup persiapan contract O4.7, bukan bukti timeout/cancel pada kernel Linux
nyata; status matrix tetap `PARTIAL_PREP_BLOCKED_DEPENDENCY`.

O5.1/O5.5 menambah verifikasi scope cgroup dan accounting write. Native
`command_reclaim` menolak mount scope yang tidak terverifikasi serta identity
swap sebelum `write`; Bash mencatat signed `memory.current` delta dan duration
tanpa retry penuh. Unit scope/race masuk ke suite native `49/49`, sedangkan
mount namespace, delegated ownership, dan EAGAIN/lost-result runtime tetap
`PENDING_ENV`.

## Current source inventory refresh — 2026-09-13

Hash source yang dipakai oleh staging/test terbaru (menggantikan angka
historis pada inventory awal di atas) adalah:

- `src/ReduceMemory.au3`: `C7F9C36EBA61CC992E25E42DF9EB066DDC37ECA508B2E52DDDE9962A52CDE924`
- `windows/native/reduce_memory_worker.c`: `7CA14248D47BFD8D11951F56F26BC7362F19D04BC2C9D209669B139A105175A0`
- `linux/ReduceMemory_Linux.sh`: `6FD783B4F97E927D65E7F85AD9E8D1139AF7ED44BC13DE5100A8ECCFBA57DE68`
- `linux/native/reduce-memory-native`: `0554750CCCD1CB7C0DEFB1D6C44EA1591343A2650B893544E55746685A357B3C`
- `tests/benchmark/run_benchmark.py`: `18AD87F1AF8731EFAF03A6B7AEA6EE0957498FC2AA97F976F05E4DB866D8D8D0`
- `tests/phase2/linux_benchmark_contract.py`: `8DCA003EEDCECE4A72FEC9EFAF0D384FE0B555458295272F58E7AFC97F54E3FE`
- `tests/phase2/scope_overlap.py`: `110C1448691ACDD85A5AC60BA3EBA00CCCF5C45A754698F080DDAC982533618D`
- `tests/phase2/linux_scope_policy.py`: `7A39871594EC6C6F6F28C21B004597BF0561C96F83327E2803B8B12E285CEC33`
- `tests/phase2/linux_advice_policy.py`: `39CC6D590DF61D5D79944D2B879FA2DCF992C9595B19052AB18EF0372048E7C6`
- `tests/phase2/plan_coverage.py`: `B620DC08639F3CC7E83C7E9C4809035A8ECDAD69576891EF59FDB50C7954C162`
- `tests/phase2/test_plan_coverage.py`: `8ADEF8A0D69519214D15D9299425DD059BCB417AF00A9C020DF5E8C8FBCF379E`
- `tests/phase2/interface_evolution.py`: `AB8BE6BD9E2B16964F40C4C11C14D8F78FC7EEA7DE24A68F6459B653A874EAAB`
- `tests/phase2/test_interface_evolution.py`: `40E1F03FF18BA5139CD3778D5DAA647D7C7F10CBF1B0840EDF30B83F61BC2632`
- `tests/phase2/execution_table.py`: `3FB2DC4432D240C95EA8F815D7AD3BFB47BD73675CE230FC40E8CA4F0FDA04D9`
- `tests/phase2/test_execution_table.py`: `61D6550DCD825BC034D889EB25B9F70B0284BE07524E70BC28CCB284838C012D`
- `tests/phase2/stage_ablation.py`: `9FFB6F776FC795CD5C0BB28E027AB567E1C47F82E196696158EC32A21695C8B0`
- `tests/phase2/test_stage_ablation.py`: `4C543C731C6F940560AFFED4BA5C8EB0141667712ABCA233ACC872E96D543BAE`
- `tests/phase2/profile_contract.py`: `83A577D14DAB84B754E8B95553BEDCE8AD7715358A6744FD3E3CC3B1DE59C6A1`
- `tests/phase2/test_profile_contract.py`: `CCF7AD0C0D0871A2D6661774074A99F7A052E88B3452A51A3B0858BF6C2C7506`

Manifest baseline UI terbaru tetap
`build/phase2/g03-baseline-ui-20260913/BASELINE-MANIFEST.json` dengan SHA-256
`1EE40A19EE09C585BB76261A93BCE24398070CA7EC80CC90268704DDE4236E58`.
Draft handoff evidence-first tersedia di `docs/PHASE2-HANDOFF.md`; statusnya
tetap partial dan tidak mengubah gate G01/G03.

## Update O2.2 — parity fixture terikat snapshot — 2026-09-13

`tests/phase2/parity_fixture.py` sekarang menyediakan kontrak test-only untuk
Normal, Aggressive, dan fallback. Setiap outcome harus membawa session yang
sama, hanya boleh mencoba atau memutasi identity dari snapshot yang sama, dan
tidak boleh mengklaim mutasi pada status `unsupported`, `permission_denied`,
`cancelled`, atau `timeout`. Fallback wajib menyimpan alasan eksplisit dan
status degraded (`unsupported`, `permission_denied`, atau `partial`).

Regression `test_parity_fixture.py` lulus `6/6`; discovery Phase 2 terbaru
lulus `44/44`. Ini menutup pembekuan input contract O2.2 secara offline, bukan
bukti parity adapter Windows/Linux atau runtime kernel.

## Verifikasi UI dan test suite terbaru — 2026-09-13

Smoke UI interaktif x64 pada `build/phase1-ui-interactive-20260913` lulus:
`modes=6; selection-binding=passed`. Smoke x86 dan parent-death x86 tidak
terminal dalam bounded observation pada desktop ini dan tetap berstatus
`PENDING_ENV`; PID aplikasi pengguna `19840` tidak disentuh. Worker protocol
x86/x64, parent-death x64, dan Temp containment lulus exit `0`. Au3Check source
tetap `0 error(s), 0 warning(s)`, native unit `49/49`, benchmark discovery
`11/11`, dan Phase 2 discovery `117/117`. Parser coverage juga memverifikasi
84 task ID unik pada rencana Luna dan 84/84 representasi pada checkpoint.

## O7.6 local package verification — 2026-09-13

Paket lokal Phase 2 dibuat dari staging `build/phase1-build-contract-20260913`
dan tree Linux yang sedang diuji:

- Paket: `build/phase2-package-20260913/ReduceMemory-3.0-phase2.zip`
- ZIP SHA-256: `CD4C6C4B2CEF31A301075EE71BA2572C8B4706E4338349A75CFC3FCC81299D74`
- `Verify-ReleasePackage.ps1`: lulus; ekstraksi baru, `RELEASE-MANIFEST.json`,
  `SHA256SUMS`, ukuran, dan hash seluruh payload cocok.
- `RELEASE-MANIFEST.json` SHA-256:
  `FA6B079FD8EA2334F26EC670A86E62B7DAD2B6CDB4FD2ABE461836BA7A9B3CDA`

Ini menutup verifikasi mekanis paket lokal, bukan pemilihan candidate final:
manifest masih menandai `sourceDirty=true`, frontend x86 runtime tetap
`PENDING_ENV`, dan Linux live gates belum tersedia.

## H3.1/H3.4 interface evolution contract — 2026-09-13

`tests/phase2/interface_evolution.py` sekarang memberi preflight model untuk
evolusi backend: major-version mismatch, required-field omission, dan unknown
semantic field selalu reject sebelum mutasi; optional non-semantic metadata
dapat diabaikan dengan status eksplisit; capability subset membuat stage yang
tidak didukung menjadi `unsupported` tanpa menghentikan stage independen.
Regression `test_interface_evolution.py` lulus `7/7`. Ini menutup kontrak
offline H3.1/H3.4, bukan bukti bahwa setiap pasangan binary/runtime live sudah
terintegrasi.

## Update O4.8/O5.2 — kontrak benchmark dan overlap scope — 2026-09-13

`linux_benchmark_contract.py` mendefinisikan fixture minimum O4.8 dan menolak
range tidak page-aligned, advised bytes di luar request, timing negatif,
complete result tanpa seluruh breakdown parse/plan/FFI/kernel, serta status
non-complete yang mengklaim integrity sukses. Grid wajib mencakup sembilan
jenis mapping dan memiliki identity untuk same-range comparison. Regression
test lulus `8/8`; ini belum mengukur kernel atau retained gain.

`scope_overlap.py` mendefinisikan ledger test-only O5.2. Child cgroup tetap
berada di bawah parent secara boundary-aware, tetapi protected/excluded,
shared-charge overlap, dan membership unknown menahan full-scope mutation.
Identity memakai PID+birth; duplicate identity ditolak dan member di luar
scope tidak dihitung sebagai eligible. Regression test lulus `8/8`; snapshot
membership cgroup live, migrasi PID, dan shared-page kernel evidence tetap
`PENDING_ENV`.

`linux_scope_policy.py` menutup persiapan O5.3/O5.4 secara read-only. Effective
swap allowance mengambil minimum dari host/scope/ancestor hanya ketika semua
nilai diketahui; unknown tidak berubah menjadi unlimited. Jika targeted process
dan cgroup sama-sama usable, keputusan dikembalikan sebagai
`experiment_required`, bukan memilih default diam-diam atau menjalankan dua
stage pada domain yang sama. Regression test lulus `9/9`; capability, swap,
delegated ownership, dan migration runtime tetap `PENDING_ENV`.

`linux_advice_policy.py` menutup persiapan O4.9/O4.10 secara offline. Hasil
`MADV_COLD` tidak pernah diberi kredit released-RAM walaupun resident delta
terlihat turun; `PAGEOUT` hanya mencatat advice coverage setelah capability,
status, dan identity valid. Regression test lulus `8/8`; syscall latency,
kernel acceptance, retained gain, dan keputusan cold-first tetap `PENDING_ENV`.

## Final local staging/package refresh — 2026-09-13

Setelah diagnostic trace dihapus kembali dari source, staging bersih dibuat:

- `build/phase2-final-build-20260913/BUILD-MANIFEST.json` diverifikasi oleh
  `Build.Tests.ps1 -SkipFrontendExecution`; manifest SHA-256
  `408053D40D32F9C467A82F5B7D2D4D5047BF77EF57F7D6ACFC9D7CF4C0316A0E`.
- `src/ReduceMemory.au3` SHA-256 terbaru:
  `C7F9C36EBA61CC992E25E42DF9EB066DDC37ECA508B2E52DDDE9962A52CDE924`.
- Worker protocol x86/x64, parent-death x64, UI smoke x64, dan Temp
  containment memakai staging ini lulus exit `0`; Temp containment memakai
  pinned `AutoIt3.exe` interpreter sesuai parameter test.
- Paket baru:
  `build/phase2-package-final-20260913/ReduceMemory-3.0-phase2.zip`.
- ZIP SHA-256:
  `F0AD15C91973E1DF3BD5B57E4B293D8FAEA7BF75E2CEFAF423C9E9B7A12D9F32`.
- `RELEASE-MANIFEST.json` SHA-256:
  `E445E31662B7C1555022BE9303E1E9C3E0BB9BBC7F1A88DDAEB437809F9D83D1`.
- `Verify-ReleasePackage.ps1` lulus setelah ekstraksi baru dan hash payload.

Probe diagnostic x86 minimal (`X86LaunchProbe.au3`, termasuk argumen,
resource loading, SID/INI, dan ComboBox/UI message) exit `0`; ini mempersempit
`PENDING_ENV` ke startup executable ReduceMemory x86, tetapi tidak mengubah
status product UI gate dan tidak dipakai sebagai frontend pass.

`execution_table.py` sekarang membekukan target table dan execution-group
contract O2.3/O2.4: record terikat snapshot, identity direvalidasi tepat
sebelum mutasi, stale/reused PID menjadi deferred, query denial tidak mutasi,
handle quota membatasi group, cancel sebelum action aman, dan progress UI
diringkas dalam payload bounded tanpa menghilangkan ledger outcome. Regression
`test_execution_table.py` lulus `11/11`; ini masih contract preparation, bukan
bukti worker production sudah memakai table tersebut.

`stage_ablation.py` menutup persiapan O3.1â€“O3.5 secara offline: setiap stage
memiliki capability/endpoint/prerequisite, arm ablation berbeda satu stage,
cache policy permanen ditolak, hasil unavailable membatasi klaim, dan dua
stage pada physical endpoint sama tidak boleh menjumlahkan delta yang sama.
Regression `test_stage_ablation.py` lulus `9/9`; fake API, privilege,
writeback, timeline, dan global-stage runtime evidence tetap `PENDING_ENV`.

## O6.1/O6.5/O6.6 profile and experiment contract â€” 2026-09-13

`profile_contract.py` membekukan kontrak offline untuk profile Luna dan
eksperimen holdout: parameter harus berada di bounds, profile membawa revision
dan artifact hash yang valid, holdout menyimpan seed serta raw digest, dan
decision dibedakan menjadi `accepted`, `rejected`, atau `needs_confirmation`.
Integrasi hanya boleh terjadi untuk decision `accepted` dengan profile artifact
yang cocok; override pengguna dipertahankan dan tidak dapat diam-diam diganti
oleh profile hasil eksperimen.

Regression `test_profile_contract.py` lulus `7/7`, dan discovery Phase 2
terbaru lulus `117/117`. Ini menutup bentuk kontrak O6.1/O6.5/O6.6 secara
offline; nilai final, candidate confirmation, dan integrasi runtime tetap
menunggu data live O2/O3/O4/O5.

## Remote Linux runtime verification — 2026-09-13

CI run `34743359103` pada commit `ae39e7c916f288ca9342449e023a97dc7df31d8f`
lulus penuh pada Ubuntu 22.04 dan 24.04 untuk Bash syntax, release contract,
native process page-out, targeted launcher reclaim, safe self-check,
Smooth/Aggressive paths, user-local installation, dan server installation.
Kesimpulan dibatasi pada gate yang dijalankan workflow; O4.8 full mapping grid,
O5.2 migration/shared-charge matrix, O6 candidate selection, dan final release
gate tetap belum ditutup.
