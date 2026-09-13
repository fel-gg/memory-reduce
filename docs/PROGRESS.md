# Upgrade progress

## 2026-09-13 - Reduce Memory 4.0 final implementation audit

- Phase 2 Linux binary evidence now includes hardware provenance and a
  disposable 10-type mapping grid with 5 repeats on Ubuntu 22.04/24.04.
- The checksum lifecycle issue was fixed before final verification; fixture
  exit and final checksum are recorded after the owned fixture exits.
- Phase 1 and Phase 2 documents now point to the final audit
  `docs/PHASE1-PHASE2-FINAL-AUDIT.md`. Baseline/fallback remains the accepted
  strategy when a candidate improvement lacks valid comparison data.

## 2026-09-13 - Reduce Memory 4.0 release candidate

- Version identity is now `4.0` in the AutoIt frontend, Linux launcher,
  README, and release packaging default.
- Phase 1/Phase 2 runtime evidence is recorded in the current checkpoints;
  final package generation must use the rebuilt 4.0 binaries and matching
  manifest hashes.

## 2026-09-12 - Benchmark Windows peak RSS fix (3.0 development)

- M7.5 summarizer diperluas untuk merangkum CPU delta, swap delta, serta
  minor/major fault delta dengan median/min/max dan CI 95%; sample missing tetap
  `null`/tidak dihitung. Smoke metrics summary schema v2 berhasil dibuat.

- M7.4 raw trial diperluas lagi dengan CPU time, kernel read/write bytes, dan
  `VmSwap` before/after/delta pada Linux. Semua helper best-effort dan
  menghasilkan `null` bila `/proc` tidak tersedia; Windows schema tetap valid.
- CPU collector sekarang juga memakai `GetProcessTimes` pada Windows dengan
  handle pointer-safe. Smoke trial Windows menghasilkan CPU delta 0.015625 s
  untuk workload, bukan `null`; Python compile dan diff check lulus.

- M7.4 raw trial ditambah `cpu_seconds_before/after/delta` berbasis
  `/proc/<pid>/stat` pada Linux, dengan fallback `null` saat platform/proses
  tidak menyediakan data. Python compile dan diff check lulus setelah fix
  indentation regression.

- Raw benchmark trial sekarang memiliki field `faults_before`, `faults_after`,
  dan `faults_delta` untuk minor/major page fault Linux; proses yang sudah exit
  dilaporkan `null`. Smoke Windows memvalidasi schema tetap serializable.

- Summary benchmark kini juga menghitung deterministic median CI 95% untuk
  peak RSS dan Available-RAM delta, bukan hanya durasi. Raw RSS-check berhasil
  diringkas ulang dengan schema v2.

- `tests/benchmark/run_benchmark.py` kini memakai pointer-sized WinAPI handle,
  deklarasi argtypes/restype eksplisit, dan struktur penuh
  `PROCESS_MEMORY_COUNTERS_EX`. Sebelumnya struktur terlalu pendek sehingga
  `GetProcessMemoryInfo` mengembalikan null.
- Smoke workload 16 MiB sekarang menghasilkan peak RSS nyata (sekitar 29–30
  MB untuk workload), sementara no-op tetap terukur terpisah. Python compile
  dan diff check lulus.

## 2026-09-12 - M0-M8 requirement matrix audit (3.0 development)

- `docs/PHASE1-LUNA-CHECKPOINT.md` sekarang memetakan seluruh sub-milestone
  M2.8, M3, M4.2-M4.4, M5.1/M5.4/M5.7/M5.8, M6.1-M6.3, M7.2-M7.6,
  dan M8.2/M8.4/M8.6.
- Baris baru sengaja membedakan bukti lokal yang sudah lulus dari integrasi
  live yang belum tersedia. Tidak ada milestone yang ditandai selesai hanya
  karena build atau parser berhasil.
- Regresi dokumentasi: `git diff --check`, Bash syntax, dan Linux unit suite
  18/18 lulus setelah matriks diperbarui.
- Audit lanjutan menemukan harness installer masih memakai continuation `\\`
  (exit 126 pada Bash); sudah diperbaiki menjadi `\\`. Runtime installer
  menolak Git Bash dengan exit 3 sesuai guard platform, sehingga bukti install
  Linux tetap harus diambil pada Linux/WSL/CI, bukan dipalsukan di Windows.
- Benchmark collector dan summarizer juga dijalankan ulang dengan lima
  repetition smoke yang aman (`build/benchmark-smoke-5x.json` dan
  `build/benchmark-summary-5x.json`). Ini memverifikasi harness/statistik,
  bukan hasil penghematan RAM produksi.
- Failure-adapter Linux kini memiliki regression dependency-missing: saat
  `python3` disembunyikan, stage melaporkan `unavailable; python3 not
  installed`, helper native tidak dipanggil, dan fixture `drop_caches` serta
  `memory.reclaim` tetap utuh. Test runtime lulus exit 0.
- M5.8 mendapat pengukuran biaya stage: `sync` dan `drop_caches` kini mencatat
  durasi milidetik per sesi dan melaporkannya terpisah; clock yang tidak valid
  menghasilkan 0 tanpa mengarang nilai. Bash syntax, failure-adapter, unit
  suite 18/18, dan diff check tetap lulus.
- M7.5 summarizer sekarang menghasilkan deterministic bootstrap 95% CI untuk
  median durasi tiap kondisi (schema report v2). Smoke report lima repetition
  berhasil diringkas ulang; CI dipakai sebagai rentang ketidakpastian, bukan
  klaim otomatis bahwa candidate lebih baik.
- M8.4 README diperjelas: credit eksplisit ke Sordum/BlueLife, provenance
  binary/source dipisahkan dari upstream resmi, serta batas redistribusi tidak
  diasumsikan otomatis. Mode, scope, angka, dan batas reclaim tetap dijelaskan
  secara natural.
- M2.3/M2.8 parser self-test ditambah fixture truncated-record dan uint64
  overflow; parser produksi wajib menolak keduanya sebelum commit metrics.
  Au3Check serta regresi Linux tetap lulus.
- Setelah validasi overflow, staging Windows `phase1-luna-final-*` dan paket
  release `release/final-luna/ReduceMemory-3.0.zip` dibuat ulang dari source
  terbaru. Manifest dan checksum verifier lulus; frontend execution sengaja
  memakai `-SkipFrontendExecution`, jadi runtime GUI pada artefak ini tetap
  belum diklaim.
- Overflow fixture sempat mengungkap bug nyata: `Number()` AutoIt menerima
  angka 20 digit dengan pembulatan. Parser sekarang memvalidasi teks uint64 dan
  int64 secara leksikal sebelum konversi; Au3Check dan staged Windows build
  terbaru lulus setelah perbaikan ini.
- Percobaan memakai `Scripting.Dictionary.Keys()` langsung di churn path
  menyebabkan `RMMEASUREMENTSELFTEST` exit 60 pada runtime AutoIt lama; perubahan
  itu dibatalkan. Jalur churn kembali ke `IniReadSection` yang kompatibel,
  sementara cache per-target tetap dipakai dan bug runtime tidak disembunyikan.
- Staging `phase1-luna-runtime-final-*` terbaru diuji ulang dengan WorkerProtocol
  x86/x64 (keduanya exit 0) dan WorkerMeasurement contract (exit 0), sehingga
  handshake/result/metric reconciliation binary terbaru tetap terbukti.
- Paket `release/current-luna/ReduceMemory-3.0.zip` dibuat ulang dari staging
  runtime tersebut setelah rollback cache churn; manifest, checksum, dan
  ekstraksi verifier lulus (exit 0). Paket tetap berstatus lokal karena source
  tree dirty dan belum dipublikasikan.
- Environment gate terakhir: PowerShell berjalan non-Administrator dan WSL
  belum terpasang. Workflow CI tetap mempertahankan gate elevated Aggressive
  dan Linux kernel runtime; kondisi lokal ini dicatat sebagai batas bukti,
  bukan diubah menjadi pass.
- Release packaging menemukan dan memperbaiki reuse-output bug: metadata lama
  dapat masuk ke manifest dan membuat self-hash gagal. `New-ReleasePackage.ps1`
  kini mengecualikan `SHA256SUMS` dan `RELEASE-MANIFEST.json` lama sebelum
  menghasilkan metadata baru; paket `release/current-luna` kemudian dibuat dan
  diverifikasi ulang dengan exit 0.
- Packaging kini juga membersihkan hanya directory `ReduceMemory-$Version`
  yang berada tepat di bawah output directory terpilih sebelum menyalin payload;
  ini mencegah file payload stale ikut ZIP tanpa manifest. Regenerate dan
  verifier `release/current-luna` lulus exit 0 setelah hardening ini.
- M5.5 diperkuat: kegagalan command `sync` tidak lagi mematikan seluruh mode
  karena `set -e`; stage sekarang melaporkan `Kernel sync: failed` lalu native
  page-out/cgroup tetap berjalan dan melapor sendiri. Failure-adapter menguji
  skenario exit 73 ini, Linux unit suite tetap 18/18.
- Paket `release/current-luna` diregenerasi setelah patch M5.5 agar engine
  Linux di ZIP memuat perilaku sync-failure independence terbaru; manifest dan
  verifier checksum kembali lulus exit 0.
- M2.2 lifecycle cleanup diperkuat: jika `WaitForSingleObject` gagal atau
  mengembalikan hasil tidak valid, process handle dan Job Object handle kini
  sama-sama ditutup sebelum fallback/error. Au3Check dan worker measurement
  contract lulus setelah perubahan.
- M7.3 kini memiliki `tests/benchmark/workload_memory.py`, fixture private
  anonymous allocation yang menyentuh setiap page, menahan proses tetap hidup,
  dan membatasi ukuran/durasi. Smoke 8 MiB berjalan exit 0; fixture tidak
  menjalankan reclaim sehingga aman dijadikan workload VM/disposable.
- Collector kemudian dijalankan dengan workload private 32 MiB, lima repetition,
  order acak, timeout 10 detik, dan delayed sample 1/3 detik. Raw dan summary
  tersimpan sebagai `build/benchmark-workload-5x.json` dan
  `build/benchmark-workload-summary-5x.json`; ini bukti harness mengumpulkan
  workload nyata, bukan bukti candidate mengalahkan baseline karena trial
  candidate sengaja masih memakai fixture yang sama.
- Paket release 3.0 dibuat ulang dari staging Windows terbaru setelah perubahan
  M4/M5/M7, lalu `Verify-ReleasePackage.ps1` memvalidasi manifest, ukuran,
  SHA-256, dan seluruh baris `SHA256SUMS` setelah ekstraksi. Hash ZIP terbaru
  dicatat oleh command output; paket ini lokal dan source masih dirty.
- Checkpoint M5.8 diselaraskan dengan implementasi: status berubah menjadi
  `sebagian diperbaiki` karena cost `sync`/`drop_caches` sudah tersedia dan
  dites, sementara korelasi cost-vs-latency pada kernel/workload nyata masih
  menunggu runner disposable.
- Installer Linux smoke fixture kini membuat config user-owned di prefix,
  menjalankan update, memverifikasi isinya tetap, lalu uninstall scoped dan
  memverifikasi config tetap ada. Ini menutup regression preservation untuk
  M6.4/M8.2; syntax semua installer lulus, runtime penuh tetap menunggu Linux.
- M8.5 support matrix dikoreksi agar tidak menyebut installer Linux sudah
  lulus CI remote; sekarang dibedakan jelas antara harness yang siap dijalankan
  dan bukti runtime yang benar-benar tersedia. Bukti targeted Windows x86
  371.5 MB juga ditambahkan.

## 2026-09-12 - Phase 1 hardening continuation (3.0 development)

- Linux RSS records now carry process `starttime` through the native helper and
  Bash session ledger, preventing PID reuse from being reported as one target.
- Linux reclaim is scope-bound: the launcher validates cgroup-root containment,
  while the native writer rejects arbitrary paths and symlink indirection.
- Linux `drop_caches` is now an independent stage; read-only or denied sysctl
  does not prevent native page-out or cgroup reclaim from reporting separately.
- Windows worker foreground protection is explicit (`/protect-foreground=0|1`)
  and x86 threshold conversion rejects values that do not fit `SIZE_T`.
- History parsing rejects malformed/oversized/future data and ignores churn
  entries beyond the 30-day TTL. Temp deletion performs a final reparse check
  immediately before file/directory removal, with broad-root regression tests.
- Native worker waiting uses bounded short polling slices so the AutoIt UI has
  opportunities to process paint/close messages during a long pass.
- Local evidence after these changes: Linux unit suite 18/18, session
  accounting, Bash/Python syntax, Au3Check, Windows staged x86/x64 build,
  worker protocol/lifecycle, and Temp containment tests pass. Phase 1 remains
  open pending live integration matrices and M2.8/M3-M8 gates.
- Follow-up gates also pass: Linux failure-adapter, fixture-isolation, and
  baseline capture; Windows worker measurement contract; real targeted x64
  trim measured 371.2 MB working-set reduction while the disposable target
  remained alive. This is targeted evidence only, not proof of global reclaim.
- A combined regression run after subsequent M3-M6 hardening also passed all
  available Linux adapters/session tests and Windows Temp/worker measurement
  tests in one sequence.
- Real targeted trim now has fresh x86 evidence as well: the disposable
  process lost 371.5 MB of working set and remained alive. This is targeted
  process evidence, not a claim about global memory release.
- History cache regression and native swappiness/bytes bounds were added after
  the initial entry; Au3Check, Linux 18/18, and the full Windows staged build
  were rerun successfully.

## 2026-09-11 - M1 measured results without fabricated savings (3.0 development)

- Windows now treats a successful trim and a successful post-trim query as two
  separate facts. A failed after-query records an unmeasured operation instead
  of claiming the full pre-trim working set was released.
- Working-set and Available RAM deltas stay signed. The UI reports resident
  memory as reduced, increased, unchanged, partial, or unknown; invalid global
  snapshots also remain unknown in the UI and log.
- Aggressive and Emergency use one per-process session ledger. Repeated passes
  retain the first baseline and latest valid final snapshot, so the same target
  is not counted once per pass. System-release modes no longer run an extra
  untracked parent trim before the elevated session.
- The x86/x64 C worker protocol now carries paired before/after values, a
  measured/unknown status per successful trim, signed resident delta, and
  separate measured/unmeasured counters.
- Linux RSS accounting now includes only processes that actually received
  `process_madvise`, still have the same observed identity, and have a valid
  after-read. Exited, identity-changed, permission-changed, and unavailable
  targets are kept out of the claimed gain and reported separately.
- Linux and Windows session tests cover failed after-reads, 32 MiB growth,
  unchanged RSS, untouched exits, duplicate targets across passes, and invalid
  global snapshots. The Windows measurement contract runs on AutoIt x86,
  AutoIt x64, and both native workers.

## 2026-09-10 - M0 reproducible build and isolated fixtures (2.9 development)

- Added one staged Windows build entry point for the canonical AutoIt frontend
  and native C workers in both x86 and x64, without overwriting the active
  portable installation by default.
- Added source-runtime and staged-artifact contract checks plus a build manifest
  containing the source commit, source hash, toolchain versions, artifact sizes,
  architectures, and SHA-256 hashes.
- Added a separate baseline record for the stored binaries, source files,
  compiler hashes, AutoIt include set, OS/architecture, privilege, memory,
  pagefile, configuration hash, and the bounded targeted-trim parameters. The
  private INI content is not copied into the record.
- Linux CI records its source/helper hashes, distribution, kernel,
  architecture, effective UID, physical/swap memory, and cgroup v2 scope in a
  separate provenance artifact before running integration fixtures.
- Moved the real x86/x64 256 MB targeted-trim fixture out of workflow YAML into
  a repeatable test harness. It still requires at least 64 MB of measured
  working-set reduction and proves that the disposable target stays alive.
- Linux test mode is now explicit and refuses to start until meminfo, VM sysctl,
  cgroup reclaim, native helper, sync command, and effective UID are all backed
  by test adapters. Unit and failure-adapter tests therefore do not mix fake
  metadata with real reclaim writes.
- Kept the existing `windows/ReduceMemory.ini` outside the generated artifacts
  so local build verification cannot overwrite user configuration.
- The full CI gate executes freshly compiled frontends. A local
  `-SkipFrontendExecution` escape hatch exists only for machines whose endpoint
  security quarantines a new unsigned AutoIt artifact; it still checks source,
  compilation, PE architecture, manifest hashes, and both native workers, and
  clearly reports that frontend runtime verification was skipped.

This file records real milestones. It intentionally distinguishes reconstructed
build artifacts from source-level history; the original folder did not contain
the AutoIt source for every intermediate binary.

## 2026-09-03 - Refault-aware native diagnostics

- Native Windows worker now records working set and `PageFaultCount` after each
  successful process trim.
- Aggressive recovery requires both at least 16 MB of working-set regrowth and
  at least 64 new page faults on that same process.
- Native output separates protected/filter/foreground candidates, access or
  path/query failures, Windows processes, minimum-size skips, trim failures, and
  successful calls that produced no measurable reduction.
- The elevated result contract, UI tooltip, bounded log, self-test, and CI carry
  and validate the recovery page-fault metric on x64 and x86.
- Added bounded per-executable effectiveness history under Local AppData. It
  stores no PID or full path, caps itself at 128 entries with oldest-entry
  eviction, and continues learning executables that did not exist at build time.
- Aggressive now excludes an executable for 30 minutes after two proven material
  refaults. Emergency bypasses learned cooldowns, and no process is killed.
- Per-target native output now reports released bytes, while native taxonomy is
  propagated through the elevated worker into the UI tooltip and bounded log.
- Directly launching either native worker now opens its matching x64/x86
  frontend. A non-GUI launch-contract check verifies packaging in CI while the
  explicit `/all` or `/pid` guard still blocks malformed backend calls.

## Baseline

- Original portable Reduce Memory v1.7 binaries and INI were preserved under
  `backup-original-v1.7-20260831/` locally and are excluded from Git.
- The upstream repository initially contained only `README.md` and `LICENSE`.
- The upgrade keeps the existing Reduce Memory identity and configuration style.

## Completed source snapshot

- Upgraded the existing engine in place to 2.8; no Windows or Linux path was
  replaced with a from-scratch rewrite.
- Added the first native Windows backend milestone without replacing the AutoIt
  application. A dependency-free C worker now owns Aggressive/Emergency process
  snapshots, protection gates, handle lifecycle, before/after counters, and
  working-set trims on x64 and x86. AutoIt validates the structured output and
  falls back to its existing engine on any missing helper or protocol failure.
- Made system-wide native execution explicit: the worker refuses to enumerate
  broadly unless `/all` is present, while local and CI probes must provide one
  disposable `/pid`. CI downloads the official hash-pinned Zig toolchain,
  rebuilds both workers from source, verifies this guard, and tests each worker
  against a resident target that must stay alive.
- Replaced report-only rebound handling inside full Aggressive with a bounded
  stabilization engine. Windows and Linux now measure immediate peak,
  post-refault stable gain, and rebound; a third backend pass runs only when
  the rebound is at least 64 MB and 20 percent of the initial gain. Processes
  remain alive, active/critical protection stays in force, and recovery is
  capped at one pass so the optimizer cannot become a permanent trim loop.
- Extended the Windows worker protocol from six to ten validated integer
  fields for peak/stable/rebound/recovery metrics, and taught CI to reject
  malformed stabilization results or an unbounded pass count.
- Replaced repeated Windows path/stat/trim queries with one owned process handle
  per eligible candidate. `GetProcessMemoryInfo`, path validation, working-set
  trim, and the after measurement now share that handle and close it exactly
  once. The old duplicate per-process trim helper was removed after all callers
  moved to the new pipeline.
- Made rebound recovery target-aware: the final pass remembers every process it
  actually trimmed and only revisits entries that refault at least 16 MB. A
  disposable x64/x86 integration target now allocates, gets trimmed, deliberately
  re-touches all pages, gets recovered once, and must remain alive.
- Audited all tracked Windows and Linux functions before refactoring. Removed
  13 unreachable reconstructed Windows helpers only after call-site and
  callback-string checks, centralized bounded numeric INI parsing, eliminated
  one redundant working-set query per eligible process, and added a safe
  `ProcessList()` failure path. Linux retained all functions because its shell
  and native call graphs contained no unreferenced implementation.
- Completed a Make It / Make It Work / Make It Pretty pass over the active
  Windows path: introduced named mode/profile constants without changing INI
  values, centralized the visible mode labels, renamed the main window,
  command-line, optimize, working-set, memory-display, tray, Options, and About
  handlers, preserved the uncertain reconstructed helpers, fixed privilege
  error capture, rejected malformed worker results, and terminated timed-out
  owned workers with temporary-result cleanup.
- Made Normal and Aggressive materially different on Windows: Normal now has a
  96 MB conservative floor plus foreground/recent/CPU shields, while Aggressive
  uses a 4 MB floor, protects only the current foreground among user apps, and
  runs a second native empty/purge sequence after its last elevated process
  pass.
- Added elevated worker diagnostics, `native completed/expected`
  status, measured worker Available RAM, and a real full-Aggressive CI gate on
  a disposable Windows process.
- Added measured before/after working-set accounting to every Windows process
  trim and structured Administrator-worker results instead of success-only
  reporting.
- Changed Windows Aggressive into a measured three-process-pass path overall:
  one UI pass plus two elevated passes around the native memory-list/cache
  release. Smooth now also gets one elevated process pass.
- Reworked the Linux syscall loop into 64-range batches with partial-result
  fallback, then made Aggressive execute a second native pass after cache and
  cgroup reclaim.
- Added swap-aware cgroup anonymous reclaim with `swappiness=max` and automatic
  plain-format compatibility fallback.
- Raised the real Windows CI gate from “the API returned success” to a 256 MB
  disposable allocation that must lose at least 64 MB on both x64 and x86
  while staying alive. Linux still uses its real 128 MB mapping gate and now
  also requires a real batched syscall.
- Split Windows candidate handling into Normal, Smooth, Aggressive, Emergency,
  and AI Shield profiles while retaining the existing six visible choices.
- Isolated AI process-tree protection to AI Shield instead of applying it to
  every Optimize pass.
- Added a Windows working-set fallback, broader elevated Aggressive pass, and
  pre-action Emergency confirmation with two complete release passes.
- Turned Linux Normal and Smooth into native application page-out profiles when
  elevated, instead of limiting them to `sync` or cache-only work.
- Expanded Linux Aggressive to all regular UIDs and Linux Server to non-root
  service UIDs too, with smaller safe mapping/RSS thresholds, a larger bounded
  cgroup request, and user-slice-first reclaim.
- Kept the Linux implementation native to `/proc`, pidfds,
  `process_madvise(MADV_PAGEOUT)`, `drop_caches`, and cgroup v2; no Windows
  working-set code was copied into it.
- Extended CI fixtures to reject AI/GPU filters outside AI Shield and verify the
  exact Normal, Smooth, and Aggressive native profiles.

- Added cross-platform AI Shield while preserving Normal, Smooth, Aggressive,
  Temp, Emergency, startup, and legacy command behavior.
- Added configurable Windows AI process protection and Linux name/command-line,
  GPU-owner, and descendant protection.
- Fixed the Linux PID-tree boundary so PID 1 no longer causes a nearly
  system-wide false protection set.
- Added a VPS-safe AI Shield path that scans non-system UIDs while keeping root
  and system services outside reclaim; it does not run global `drop_caches` or
  root-cgroup reclaim.

- Removed the embedded Sordum website reference from the upgraded source/build.
- Kept startup non-elevated; elevation is deferred until a privileged mode is
  actually selected.
- Added a working five-item mode selector: Normal Optimize, Aggressive Release,
  Aggressive Smooth, Aggressive + Delete Temp, and Emergency Release.
- Added stronger memory-list operations for Aggressive Release and a lighter
  path for Aggressive Smooth.
- Added permanent Temp cleanup with a warning and locked-file skipping.
- Removed the post-Optimize result popup; status is shown in the main window.
- Added a generic application shield: processes are evaluated dynamically, the
  Windows directory and ReduceMemory itself are protected, and a recently
  foreground process remains protected briefly after focus changes.
- Added immediate versus stable memory reporting, rebound detection, pressure
  summary (RAM load and commit), and the manual Emergency Release mode.
- Added a 60-second rebound guard, rotating result log, three-stage status, and
  one-elevation Emergency worker with two full passes.
- Fixed the Optimize runtime crash on the original AutoIt 3.3.6.1 engine by
  replacing unsupported `ProcessGetPath()` with `QueryFullProcessImageNameW`.
- Expanded `/RMSELFTEST` to traverse the complete Normal process-selection path
  without trimming, preventing GUI-only compatibility failures from hiding.
- Cleaned the canonical AutoIt source to `0 error(s), 0 warning(s)` under the
  matching AutoIt 3.3.6.1 syntax checker.
- Reworked the existing Windows startup checkbox into a silent login Normal
  pass plus a hidden 95% pressure monitor; the main window and tray do not stay
  open.
- Added two-sample confirmation, a five-minute cooldown, a 90% re-arm
  watermark, and a named mutex preventing duplicate monitors.
- Kept automatic passes non-elevated and separate from manual Aggressive or
  Emergency selection so startup remains smooth and never requests UAC.

## Packaging and platform milestone

- Promoted all maintained Windows, Linux Desktop, and Linux Server artifacts to
  the consistent Reduce Memory 2.2 release identity.
- Built and tested x64 and x86 Windows executables, including real Normal trim
  against a disposable process that remained alive after trimming.
- Added a native Bash companion for Linux memory-cache release.
- Verified the Linux script with `bash -n`.
- Verified that both Windows architectures use the same canonical source and
  that the final PE architectures match their filenames.
- Added cross-platform CI: Windows runs both safe executable self-tests and
  Ubuntu runs the Bash syntax check plus the native Linux `check` mode.
- Added an interactive Linux mode menu and a no-root, user-local installer that
  creates a freedesktop application launcher without a daemon or startup task.
- Added Ubuntu CI coverage for the installed Linux command and generated
  desktop entry, while preserving all existing non-interactive mode commands.
- Added a Linux Server/VPS installer that exposes the same canonical engine as
  `reduce-memory-server` through SSH, without duplicating optimization logic.
- Separated Linux Desktop and Linux Server installers into explicit
  `linux/desktop` and `linux/server` source directories while keeping one tested
  engine for their shared memory operations.
- Added CI coverage for server installation, safe status output, executable
  permissions, and the Linux Server interactive menu.
- Added tag-driven GitHub Release packaging with audited Windows, Linux Desktop,
  Linux Server, and SHA-256 assets created directly from the tagged commit.
- Rebuilt the Linux engine around `/proc/meminfo`, `drop_caches`, and cgroup v2
  `memory.reclaim`; no Windows working-set behavior is reused by the Bash path.
- Removed `compact_memory` from the Linux release path because compaction
  changes fragmentation, not the total amount of available RAM.
- Added a bounded, RAM-sized Aggressive reclaim request with cache-only fallback
  for older cgroup v1 systems and a clear warning when swap is disabled.
- Expanded Linux reporting to distinguish cache release, anonymous application
  pages, swap movement, and actual `MemAvailable` change.
- Added Ubuntu integration checks that execute Smooth and Aggressive as root and
  verify the exact `drop_caches` and `memory.reclaim` requests safely.
- Rebuilt Linux Aggressive again around the direct Linux
  `process_madvise(MADV_PAGEOUT)` syscall so idle application mappings can be
  reclaimed even when desktop cgroup layout makes `memory.reclaim` ineffective.
- Added a bundled portable Python 3 syscall helper using PID file descriptors,
  `/proc/PID/smaps`, kernel mapping flags, and measured before/after RSS.
- Added application shields for recent CPU activity, the detected foreground
  process tree, the Reduce Memory/sudo terminal ancestry, small processes,
  locked pages, and special device/kernel mappings.
- Added real Ubuntu CI evidence using a disposable 128 MB resident file mapping;
  acceptance now requires positive bytes advised, at least 16 MB measured RSS
  reduction, and the target process remaining alive.

## Latest Luna validation (2026-09-12)

- Linux unit suite: `18/18` passed; the fake-syscall failure adapter passed
  without performing real reclaim writes.
- Benchmark tooling now records child peak RSS on Windows with a pointer-safe
  `PROCESS_MEMORY_COUNTERS_EX` call, plus Linux fault/CPU/I/O/swap deltas when
  those `/proc` counters exist. A Windows smoke run produced non-null peak RSS
  and CPU samples for baseline, candidate, and no-op rows.
- Python benchmark modules compile cleanly and `git diff --check` reports no
  whitespace errors.
- Current package regenerated and verified locally:
  `release/current-luna/ReduceMemory-3.0.zip` (SHA-256
  `2F6A16201A5BB9616BEF976B3F6FDB4A5F7A8271FA5539C924862A4F00753F17`).
- These are local gates only. No claim is made for live Linux cgroup/page-out,
  elevated UAC, GUI automation, or a published GitHub artifact until a Linux
  runner and clean tag build provide evidence.
- Linux Aggressive recovery was narrowed to measured/advised PID instances
  from the current session; a per-PID ledger prevents a second recovery pass
  from scanning unrelated or newly-created processes.
- Effectiveness history keys are now versioned, user/logon scoped, and carry a
  deterministic identity fingerprint. Live processes contribute their
  normalized full executable path plus SHA-256 executable bytes (with size/mtime
  metadata fallback); the readable process suffix is not used as the identity
  portion. A dedicated collision matrix on a clean Windows runner remains.
- Added `tests/windows/UiSmoke.Tests.ps1`, a Win32 ComboBox smoke harness that
  verifies the six visible mode labels rather than trusting source strings.
  The x64 staged binary passed locally; x86 remains a clean-runner gate after
  the local host failed to produce an observable completion.
- Added legacy effectiveness-key fallback and one-way migration: v1 name keys
  can be read for compatibility, then are removed only from the atomically
  published temp copy after the v2 identity write succeeds.

## Deliberately not included

- Stop-when-enough targets are not used; a selected mode runs its defined pass.
- Windows has one narrowly scoped 95% startup-monitor trigger; Linux still has
  no automatic trigger or daemon.
- Temp cleanup behavior was not expanded beyond its existing warning and
  locked-file skipping.
- The first half of Active Application Shield is implemented; GPU, audio,
  recording, and fullscreen detection remain outside the current scope.
