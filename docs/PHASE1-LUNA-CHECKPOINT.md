# Phase 1 Luna checkpoint

## Remote verification update — 2026-09-12

GitHub Actions run 34681540951 (https://github.com/fel-gg/memory-reduce/actions/runs/34681540951) pada commit 3869011 selesai dengan success untuk kedua job:

- **Linux**: Bash syntax, M0 provenance, native page-out, safe self-check, Smooth, Aggressive, failure adapter, user-local installer, dan server installer.
- **Windows**: source build frontend/worker x86 dan x64, manifest/provenance, worker self-test, measurement/protocol/lifecycle self-test, real working-set trim, refault recovery, dan full Aggressive engine.

Catatan penting: workflow Windows mendeteksi runner GitHub yang headless dan menunda UI smoke interaktif dengan warning. UI smoke tetap dijalankan dan lulus pada desktop interaktif lokal untuk binary x64; bukti UI x86 pada desktop interaktif lokal belum diarsipkan. Karena itu, remote green run menutup build/native gates, tetapi tidak mengubah batas bukti visual tersebut menjadi klaim universal.

Run pengulangan pada commit 2e4fa94 (34681780458) juga selesai success untuk job Windows dan Linux. Run ini memverifikasi ulang workflow setelah checkpoint diperbarui dan menjadi bukti remote terakhir untuk Phase 1.

Release provenance update: commit 6cbdd13 mengubah release workflow agar job tag membangun empat EXE Windows dari source tag menggunakan toolchain yang checksum-nya dipin, mengunggah hasil build sebagai artifact immutable, lalu job publish memakai artifact tersebut. Workflow tidak lagi mengambil EXE lama dari tree repository untuk paket Windows.

UI x86 follow-up: smoke test interaktif lokal kini lulus untuk ReduceMemory.exe dengan enam mode (exit 0), setelah cleanup instance lifecycle ditambahkan. Smoke x64 juga lulus dengan enam mode. Bukti ini menutup gap binary/ComboBox x86 pada host interaktif; screenshot visual belum diarsipkan.

Checkpoint dibuat saat L00 mulai. Ini bukan tanda Phase 1 atau M0 selesai.

| Task | Status | Source/hash | Tes dan exit code | Belum terbukti | Langkah berikutnya |
| --- | --- | --- | --- | --- | --- |
| L00 harness safety | lulus pada staging worker | `tests/windows/WorkerProtocol.Tests.ps1`, `tests/windows/TempContainment.Tests.ps1` | PowerShell parse lulus; WorkerProtocol v2 pada worker staging x86 dan x64: exit 0; metrics record count direkonsiliasi | Temp containment runtime race matrix masih pending | L01 |
| L01 build/provenance | lulus lokal | `windows/build.ps1`, `tests/windows/Build.Tests.ps1` | Full staged build x86/x64 + worker x86/x64, manifest, baseline, bounded self-tests termasuk frontend runtime: exit 0; rerun terbaru memakai AutoIt buildtools dan Zig toolchain lokal | Remote CI belum dijalankan pada sesi ini | L02 |
| L02 measurement semantics | lulus lokal | `src/ReduceMemory.au3` measurement ledger/parser | Au3Check exit 0; full staged frontend x86/x64 measurement self-tests exit 0; Linux unit 18/18 | Full malformed-result fixture matrix and retained-session integration remain pending | M2.1/M2.3 |
| M2.1 Linux identity/arg validation | lulus lokal | `linux/native/reduce-memory-native`, `tests/linux/test_native_unit.py` | 18/18 unit tests; `--pid -1` and duplicate `--session` both exit 2 before mutation | Full Linux native integration requires Linux/WSL2 privilege; x86 Windows parser boundary remains M2.7 | M2.2 |
| M2.2 Windows worker lifecycle | lulus lokal sebagian | `src/ReduceMemory.au3`, `tests/windows/Build.Tests.ps1` | Full staged build exit 0; bounded frontend x86/x64 lifecycle self-tests dan worker protocol x86/x64 exit 0; runner memakai handle langsung dari `CreateProcessW` + Job Object | Kill-on-close flag actual behavior, forced parent-death/timeout integration, dan elevated envelope masih pending | M2.3 |
| M2.3 result parser transaction | lulus lokal | `RM_ParseNativeProcessResult`, `RM_ParseWorkerResult`, `tests/windows/WorkerProtocol.Tests.ps1` | Full staged build exit 0; frontend measurement/parser self-test exit 0; x86/x64 worker protocol exit 0; metric validation dilakukan sebelum commit totals | Dedicated malformed fixture matrix, overflow/size boundary, and elevated envelope integration still pending | M2.4 |
| M2.4 elevated envelope/fallback | lulus lokal sebagian | `RM_RunAggressiveWorker`, `RM_FinishWorker`, `RM_ParseWorkerResult` | Au3Check exit 0; full staged build + frontend self-tests exit 0; elevated session cocok/salah diuji di measurement self-test; x86/x64 protocol exit 0; parent mengirim dan memvalidasi `RMSESSION` | Elevated UAC integration, child result loss after mutation, no-replay decision, and full fallback stage matrix remain pending | M2.5 |
| M2.5 optimization lock | lulus lokal sebagian | `RM_AcquireOptimizationLock`, CLI branches, `acquire_optimization_lock` | Au3Check exit 0; Windows mutex scope memasukkan logon domain + user; tiga jalur CLI memperoleh lock; Linux launcher memakai `flock` bila tersedia dan fallback atomic `mkdir` lease pada Git Bash/minimal image; Linux session accounting tetap lulus | SID/ACL eksplisit Windows dan dua-instance concurrency integration belum terbukti | M2.6 |
| M2.6 Linux identity ledger | lulus lokal | `linux/native/reduce-memory-native`, `linux/ReduceMemory_Linux.sh` | `python -m py_compile`, `bash -n`, Linux session accounting, dan 18/18 unit tests lulus; `rss_target` membawa PID + `/proc` starttime; parser Bash tetap menerima fixture v2 lama | Full PID-reuse integration pada kernel Linux nyata belum terbukti | M2.7 |
| M2.7 parity selection native/fallback | sebagian lulus lokal | `windows/native/reduce_memory_worker.c`, `src/ReduceMemory.au3`, `tests/windows/WorkerProtocol.Tests.ps1` | Build staged x86/x64 + frontend/worker self-tests exit 0; worker protocol x86/x64 exit 0; threshold dihitung uint64 dan x86 menolak nilai yang tidak muat `SIZE_T`; flag `/protect-foreground=0\|1` eksplisit dan invalid/duplicate flag diuji | Decision fixture native-vs-AutoIt, foreground on/off runtime matrix, dan full minimum boundary matrix belum selesai | M2.8 |
| M2.8 gate penutupan M2 | belum ditutup | Gabungan L00–M2.7 dan `docs/WORKER-PROTOCOL.md` | Gate sintaks, build, parser, identity, lock, dan worker protocol lokal tersedia | Elevated UAC, parent-death/timeout, concurrent-instance, malformed-fixture, dan native/fallback decision matrix belum seluruhnya live | Selesaikan fixture/integrasi yang tercantum lalu review M2 |
| M4 history validation | sebagian diperbaiki | `RM_ReadEffectiveness`, `RM_EffectivenessFileUsable`, `RM_GetChurnExclusions`, AutoIt history self-test | Au3Check exit 0; staged build/self-tests exit 0; malformed/non-numeric, future timestamp, counter/bytes overflow, dan file >256 KiB tidak dipakai; churn lebih tua dari TTL 30 hari atau timestamp mundur diabaikan; cache sesi kini memuat section `Process` sekali per path dan cache-hit mengembalikan nilai terurai | Identity key masih berbasis nama legacy; atomic single-writer, deterministic eviction, dan dedicated TTL/concurrency tests belum selesai | M4.1 |
| M4.5 atomic history replacement | sebagian diperbaiki | `RM_WriteEffectiveness` | History ditulis ke sibling temp lalu diganti hanya setelah `IniWrite` berhasil; kegagalan copy/write/move menghapus temp dan mempertahankan file lama; Au3Check dan direct measurement self-test exit 0 | Multi-process writer lock dan single batch load/save per sesi belum terbukti | M4.5 |
| M4.6 target-array hot path | sebagian diperbaiki | `RM_RecordLastPassTarget`, `RM_ResetLastPassTargets` | Last-pass arrays kini tumbuh geometris (8, 16, 32, ...), bukan `ReDim +1` per target; Au3Check dan direct self-test exit 0 | Benchmark 100/1.000 target dan equivalent session cache belum terbukti | M4.6 |
| M5.2/M5.3 Linux reclaim scope | sebagian diperbaiki | `linux/ReduceMemory_Linux.sh`, `linux/native/reduce-memory-native`, `tests/linux/test_native_unit.py` | Launcher memvalidasi `memory.reclaim` tetap berada di cgroup root (fixture root khusus saat test); native writer menolak basename/symlink/arbitrary path sebelum `open`; unit suite **18/18** dan session accounting lulus | Validasi mount identity dan live permission/errno/ancestor matrix belum terbukti | M5.1 |
| M5.2 numeric bounds | sebagian diperbaiki | `safe_bytes_value`, `bounded_reclaim_mb`, `tests/linux/test_session_accounting.sh` | `memory.current` dan ancestor `memory.max` hanya dipakai jika integer non-negatif yang muat INT64; oversized fixture `99999999999999999999` diabaikan dan request tetap bounded 1024 MiB; leading-zero values dibandingkan sebagai desimal; Bash syntax, session accounting, dan unit suite lulus | Live cgroup limit matrix tetap pending | M5.2 |
| M5.5 Linux stage independence | sebagian diperbaiki | `linux/ReduceMemory_Linux.sh` | `run_drop_caches` sekarang melaporkan unavailable/failed tanpa menghentikan native page-out/cgroup stage; `require_drop_caches` tidak lagi menjadi hard gate untuk Smooth/Aggressive; Bash syntax + session accounting + unit **18/18** lulus | Live read-only/EPERM matrix dan per-stage errno proof belum selesai | M5.6 |
| M5.6 Linux batch errno accounting | sebagian diperbaiki | `linux/native/reduce-memory-native`, `tests/linux/test_native_unit.py` | Native `pageout_process` mengembalikan errno terakhir dari batch/scalar fallback dan protocol mengeluarkan `last_errno`; aggregator mempertahankan error terakhir berdasarkan urutan proses; deterministic partial-batch fixture memverifikasi EAGAIN lalu EPERM; native reclaim juga menolak bytes di luar INT64 dan swappiness di luar 0–200; unit suite **18/18** lulus | Live kernel partial-iovec evidence belum selesai | M5.6 |
| M6.1/M6.2 Temp containment | sebagian diperbaiki | `RM_DeleteTempTree`, `tests/windows/TempContainment.Tests.ps1` | Reparse point dicek saat masuk dan tepat sebelum delete; broad root `C:\` ditolak tanpa mutasi; junction sentinel, locked-file, dan ordinary-file test lulus; Au3Check exit 0 | Handle-relative containment dan root rename/path-swap race belum terbukti | M6.2 |
| M8.5 support matrix | sebagian diperbaiki | `docs/SUPPORT-MATRIX.md`, `README.md` | Matrix baru memisahkan bukti Windows x86/x64, Linux desktop/server, Git Bash limitation, dan future software compatibility; klaim “semua distro” tidak digunakan | Release artifact hash/install matrix dan live Linux server evidence masih pending | M8.5 |
| M3.1 worker wait responsiveness | sebagian diperbaiki | `RM_RunOwnedNativeWorker`, `RM_RunAggressiveWorker` | Native child tetap dimiliki handle/job; wait dipoll dalam slice 100 ms dengan `Sleep(25)` dan timeout bounded; parent yang sudah Administrator kini juga menjalankan Aggressive lewat child/session terpantau, bukan orkestrasi langsung di GUI; Au3Check dan staged build gate lulus | GUI close/cancel fake-slow integration dan kill-on-close runtime belum terbukti | M3.1 |
| M3.5 recovery attempt ledger | sebagian diperbaiki | `RM_RecoveryAttemptKeys`, `RM_RunRefaultRecovery` | Instance recovery ditandai sebelum mutation memakai PID + process birth dan tidak diulang dalam worker session; Au3Check, direct self-test, dan Linux suite lulus | Multi-cycle Emergency integration dan runtime recovery spy belum terbukti | M3.5 |

| M3 Aggressive Windows + GUI | sebagian diperbaiki | `RM_RunAggressiveWorker`, `RM_RunOwnedNativeWorker`, `RM_RecoveryAttemptKeys` | Aggressive kini lewat child worker terukur untuk parent elevated/non-elevated; polling bounded; build dan self-test lokal lulus | Live GUI close/cancel, kill-on-close, timeout, dan hasil purge/recovery pada Windows elevated belum terbukti | Tutup M3.1–M3.5 dengan harness live |

| M4.2 executable identity | sebagian diperbaiki | `RM_EffectivenessKey`, `RM_GetExecutableHash`, `RM_LegacyEffectivenessKey`, `RM_ReadEffectiveness`, `RM_WriteEffectiveness` | Key schema versioned `v2_`, fingerprint dan namespace `LogonDomain\\UserName`; live process memakai normalized full executable path plus SHA-256 bytes via bundled AutoIt Crypt UDF; size/mtime fallback saat hash gagal; legacy name key dibaca sebagai fallback lalu dihapus saat v2 write; source self-tests, Au3Check, Windows build/manifest lulus | Collision/unicode/path matrix live dan hash failure/permission matrix belum terbukti | Jalankan dedicated identity collision matrix pada clean Windows runner |
| M4.3 churn lintas sesi | sebagian diperbaiki | `RM_GetChurnExclusions` | TTL 30 hari, timestamp mundur, dan batas counter sudah ditangani | Bukti lintas sesi 24 jam/30 menit dan satu-strike per executable/session belum dijalankan | Tambahkan fixture multi-session dengan clock terkendali |
| M4.4 decay/missing samples | sebagian diperbaiki | `RM_RecordEffectivenessAttempt`, `RM_ReadEffectiveness` | Positive measured release now decays one prior refault strike; missing/unmeasured release does not create decay; malformed/future/clock-backward records remain rejected; Au3Check passed | Dedicated compiled selftest/runtime evidence for stable decay and missing sample remains blocked by endpoint/security behavior on this host | Re-run staged frontend selftest on a clean Windows runner |
| M5.1 Linux UID/cgroup scope | sebagian diperbaiki | `linux/ReduceMemory_Linux.sh` | Scope cgroup root fixture dan path containment diuji | UID/cgroup ownership eksplisit dan live delegated-cgroup matrix belum terbukti | Tambahkan preflight identity/ownership gate |
| M5.4 swap policy | sebagian diperbaiki | `linux/ReduceMemory_Linux.sh`, `linux/native/reduce-memory-native` | Swappiness tervalidasi 0–200; nilai invalid berhenti sebelum mutation | Matrix live swap, `swap.max`, dan policy 0/200 belum terbukti | Tambahkan fixture/read-only policy tests |
| M5.7 Linux recovery ledger | sebagian diperbaiki | `linux/ReduceMemory_Linux.sh` recovery ledger + native protocol | Aggressive recovery kini hanya mengulang PID yang memiliki pasangan RSS `measured` dan starttime valid pada sesi yang sama; `native_recovery_done_by_pid` mencegah pengulangan per instance; session accounting dan partial errno lulus | Live kernel refault/fault counter dan PID-reuse integration belum terbukti | Jalankan VM/runner Linux disposable untuk membuktikan rebound dan recovery attribution |
| M5.8 Linux cost measurement | sebagian diperbaiki | `linux/ReduceMemory_Linux.sh` | Stage drop-caches independen; durasi `sync` dan `drop_caches` dicatat dalam milidetik dan dilaporkan terpisah; nilai clock invalid tetap 0; Bash syntax, failure-adapter, dan unit suite lulus | Cost belum diukur pada workload/kernel Linux nyata dan belum dikorelasikan dengan latency/cache reclaim | Jalankan benchmark disposable dengan before/after dan cost fields |
| M6.1 handle-relative containment | sebagian diperbaiki | `RM_DeleteTempTree`, `tests/windows/TempContainment.Tests.ps1` | Reparse check sebelum delete dan broad-root rejection lulus | Handle-relative traversal dan rename/path-swap race belum terbukti | Tambahkan Windows race harness atau dokumentasikan batas OS |
| M6.2 Temp race matrix | sebagian diperbaiki | `tests/windows/TempContainment.Tests.ps1` | Junction, locked-file, ordinary-file, dan cleanup guard lulus | Rename/reparse swap saat traversal masih pending | Tambahkan stress loop bounded |
| M6.3 frontend path/architecture/UI | sebagian diperbaiki | `src/ReduceMemory.au3`, `tests/windows/UiSmoke.Tests.ps1`, staged x86/x64 build | UI smoke Win32 membuka binary x64 dan menemukan ComboBox berisi tepat 6 label mode; x64 exit 0; source/build/self-tests x86/x64 lulus; workflow menjalankan smoke untuk kedua arsitektur dengan hard timeout + tree cleanup | UI smoke x86 belum selesai pada host ini (proses tidak menghasilkan completion observable); screenshot visual belum diarsipkan | Jalankan bounded x86 UI smoke pada clean Windows runner dan simpan screenshot/trace |

| M7.1 benchmark harness | sebagian diperbaiki | `tests/benchmark/run_benchmark.py`, `tests/benchmark/summarize_benchmark.py`, `docs/PHASE1-BENCHMARK.md` | Harness cross-platform menyimpan seed, randomised order, repetition, timeout, exit code, durasi, peak RSS child, Available RAM before/after, output, environment, dan source SHA-256; summarizer menghasilkan median/min/max + deterministic median CI95; five-repetition disposable run tersimpan di `build/benchmark-m7-final*.json` dengan delayed +1/+3 samples | Final reclaim comparison dengan candidate ReduceMemory nyata, delayed +15/+60, VM snapshot, dan workload latency belum dijalankan | M7.2 |

| M7.2–M7.6 evidence analysis | belum selesai | `tests/benchmark/*`, `docs/PHASE1-BENCHMARK.md` | Collector dan summarizer smoke lulus | Workload nyata, lima repetition final, delayed sampler, VM snapshot, dan keputusan berbasis confidence interval belum tersedia | Jalankan benchmark final pada fixture terkontrol lalu review hasil |
| M7.3 memory workload fixture | sebagian diperbaiki | `tests/benchmark/workload_memory.py`, `build/benchmark-workload-5x.json` | Fixture anonymous private allocation menyentuh setiap page, menahan proses hidup, membatasi ukuran/durasi; collector menjalankan 32 MiB workload dengan 5 repetition, random order, timeout, dan delayed sample 1/3 detik | Belum dipakai pada VM/runner dengan candidate ReduceMemory yang benar-benar melakukan reclaim atau workload latency | Jalankan baseline/candidate/no-op terisolasi pada disposable runner |
| M6.4 Linux installer paths | sebagian diperbaiki | `linux/desktop/Install_Desktop.sh`, `linux/server/Install_Server.sh`, `tests/linux/test_installers.sh`, `.github/workflows/verify.yml` | Installer smoke harness memeriksa path spasi/Unicode, executable bit, desktop entry, uninstall scoped, dan server prefix disposable; Bash syntax seluruh installer lulus; harness ditambahkan ke Linux CI job | Remote Linux CI belum dijalankan dari sesi ini; update/config preservation dan dependency-missing matrix masih pending | M6.4 |
| M8.1 manifest verifier | sebagian diperbaiki | `windows/build.ps1`, `windows/Verify-BuildManifest.ps1` | Fresh Windows 3.0 staging berhasil diverifikasi: seluruh artifact dan build input dicek keberadaan, ukuran, dan SHA-256; mismatch dari staging lama ditolak | Clean-tag release package dan remote artifact verification belum dijalankan | M8.1 |
| M8.2 provenance/reproducibility | sebagian diperbaiki | Build manifest + `RELEASE-MANIFEST.json` | Input/artifact hash, source commit, dirty-state, ukuran, dan arsitektur dicatat | Rebuild lintas mesin/toolchain dan executable-bit Linux belum diverifikasi | Tambahkan reproducibility note dan mode metadata check |
| M8.3 local release packaging | sebagian diperbaiki | `release/New-ReleasePackage.ps1`, `release/Verify-ReleasePackage.ps1` | Paket ZIP Windows + Linux berhasil dibuat hanya setelah manifest Windows diverifikasi; paket berisi `SHA256SUMS` dan `RELEASE-MANIFEST.json` dengan source commit/dirty-state, daftar file, ukuran, SHA-256, dan arsitektur; verifier berhasil memvalidasi manifest serta setiap baris checksum setelah ekstraksi; tidak menimpa repo; `-RequireClean` atau tag `refs/tags/v*` menolak source tree dirty | Remote release workflow dan published artifact verification belum dijalankan | M8.3 |
| M8.4 release verification | sebagian diperbaiki | `release/Verify-ReleasePackage.ps1` | Ekstraksi fixture dan cross-check manifest/checksum lulus lokal | Verifikasi artifact yang sudah dipublikasikan dan clean-tag CI belum dijalankan | Jalankan workflow tag/CI dengan artifact immutable |
| M8.6 Phase 1 sign-off | belum selesai | Seluruh checkpoint ini | Bukti lokal terindeks dan batas klaim ditulis eksplisit | M2/M3/M4/M5/M6/M7 live gaps di atas belum tertutup; Phase 2 belum boleh dimulai | Tutup semua baris pending lalu minta review sign-off |

## Perubahan L00

- Negative protocol cases tidak lagi mengirim `/all`; semuanya memakai `/pid=0` dan seharusnya berhenti pada validasi tanpa mutasi.
- Positive protocol case membuat target PowerShell disposable di fixture dan memakai PID target tersebut, bukan PID shell test.
- Worker protocol dan Temp containment probe memiliki deadline 15 detik serta terminasi child yang scoped ketika timeout.
- Fixture result, handshake, dan target berada di direktori unik `%TEMP%` dengan cleanup yang tetap divalidasi.

## Bukti dan batas

- Parse PowerShell berhasil.
- Worker protocol terhadap build staging kandidat baru lulus (exit 0). Binary lama di `windows/ReduceMemoryWorker_x64.exe` sebelumnya gagal handshake dan tetap tidak dianggap bukti.
- Build staging kandidat lulus dengan empat artefak, `buildInputs=7`, `sourceDirty=true`, dan manifest hash yang cocok.
- Frontend runtime pada staged build x86/x64 sudah dijalankan; self-test frontend dan worker seluruhnya exit 0. Remote CI tetap belum dijalankan pada sesi ini.
- L02 menambah flag `before_known` yang sticky: baseline yang hilang tidak dapat direkonstruksi oleh pass berikutnya. Kasus itu ditambahkan ke measurement self-test.
- `docs/WORKER-PROTOCOL.md` ditambahkan sebagai kontrak transport v2 untuk producer, consumer, lifecycle, identity, limits, dan fallback.
- CI Windows ditambah dengan x86/x64 worker-lifecycle self-test; hasil remote belum dijalankan pada sesi ini.
- Elevated result parser juga menangani newline terminal secara eksplisit; full staged build setelah penambahan `RMSESSION` kembali exit 0.
- Linux RSS ledger kini membawa process starttime agar PID reuse tidak menggabungkan dua proses berbeda; parser mempertahankan kompatibilitas record empat kolom dari fixture lama.
- Worker protocol staged x86/x64 kembali lulus setelah penambahan flag foreground dan validasi threshold; fixture sementara berada di `%TEMP%` dan tidak menyentuh binary aktif pengguna.
- Cache histori efektivitas diperbaiki agar cache-hit mengembalikan nilai terurai yang benar; worker native x86/x64 hasil build terbaru dipasang ke `windows/` setelah protocol test keduanya lulus.
- Measurement self-test kini memiliki regresi eksplisit untuk pembacaan histori dua kali (cache-hit harus mempertahankan seluruh counter/timestamp); Au3Check versi lokal exit 0.
- Native Linux reclaim validation kini konsisten dengan launcher: `bytes` dibatasi INT64 dan swappiness numerik dibatasi 0–200; tiga nilai invalid diuji berhenti sebelum `open()`.

### Verification update 2026-09-12

- Linux CI run `34684737773` berhasil pada job Linux setelah penambahan
  `REDUCE_MEMORY_TARGET_PID`. Runner membuat workload private disposable,
  menjalankan launcher Aggressive melalui `sudo`, lalu membuktikan mode
  Aggressive menghasilkan native page-out pass, memindai target, dan memberi
  advice mapping. Ini adalah bukti launcher-to-native targeted path pada kernel
  Linux runner, bukan klaim benchmark improvement.
- Workflow verification kini dapat dijalankan ulang dengan `workflow_dispatch`,
  selain trigger push/pull request. Job Windows memiliki timeout 20 menit dan
  download toolchain memiliki timeout 120 detik.
- Run `34684823652` menyelesaikan job Windows dan Linux dengan status `success`.
  Windows membangun frontend/worker x86 dan x64 dari source, menjalankan
  self-test, real working-set trim, refault recovery, dan Aggressive integration;
  Linux menjalankan targeted launcher reclaim serta seluruh installer/native
  gates. Ini menjadi bukti remote cross-platform terbaru untuk source commit
  `3c33822`.
- Release workflow juga kini memiliki timeout eksplisit: 30 menit untuk build
  Windows dan 15 menit untuk packaging/publish Linux, dengan timeout 120 detik
  untuk setiap download toolchain. Kontrak release tetap lulus pada
  `tests/release/test_release_workflow_contract.py`.
- Run `34685622785` sebelumnya gagal pada baseline Windows karena host runner
  tidak menyediakan `Get-FileHash`; kegagalan itu terisolasi dan diperbaiki pada
  commit `1fe47a0` dengan hashing SHA-256 berbasis .NET di seluruh jalur
  baseline/build/verifier. Run `34685802730` sedang memverifikasi perbaikan ini.
- Run `34685836992` kemudian terminal dengan `success` pada job Windows dan
  Linux. Windows berhasil melewati baseline capture, build AutoIt/Zig x86/x64,
  self-test, real trim, refault recovery, dan Aggressive integration setelah
  migrasi hash .NET; Linux seluruh gate tetap `success`. Ini adalah bukti remote
  terbaru bahwa failure `Get-FileHash` sudah teratasi.
- Full Windows staged build rerun terbaru lulus tanpa `-SkipFrontendExecution`; frontend runtime, worker x86/x64, manifest, dan baseline selesai dalam satu staging directory.
- Jalur `RM_RunAggressiveWorker` elevated diperbaiki agar parent Administrator tetap membuat child worker terukur dengan session envelope dan Job Object; validasi sintaks/build lulus, sedangkan close/timeout live masih menunggu harness GUI.
- `RM_ReadEffectiveness` kini memakai dictionary cache satu-sesi untuk seluruh section `Process`; write menginvalidasi snapshot sebelum replace, sehingga hot path tidak melakukan I/O INI per-target.
- Additional local gates: Linux failure-adapter and fixture-isolation passed; Linux baseline capture exited 0; Windows worker measurement contract exited 0; real targeted x64 trim fixture measured 371.2 MB reduction with target kept alive.
- Combined regression run after the latest history/recovery/scope/containment changes passed: Linux failure-adapter, fixture isolation, session accounting, 18/18 unit tests, Windows Temp containment, and worker measurement contract.
- Fresh real targeted x86 trim fixture measured 371.5 MB reduction with its disposable target remaining alive; x64 evidence remains 371.2 MB from the earlier run.
- Tidak ada global trim, purge, penghapusan file pengguna, atau perubahan konfigurasi pengguna yang dijalankan.
- File untracked `x` belum dihapus karena kepemilikannya belum terbukti sebagai artefak fixture L00.
