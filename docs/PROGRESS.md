# Upgrade progress

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

## Deliberately not included

- Stop-when-enough targets are not used; a selected mode runs its defined pass.
- Windows has one narrowly scoped 95% startup-monitor trigger; Linux still has
  no automatic trigger or daemon.
- Temp cleanup behavior was not expanded beyond its existing warning and
  locked-file skipping.
- The first half of Active Application Shield is implemented; GPU, audio,
  recording, and fullscreen detection remain outside the current scope.
