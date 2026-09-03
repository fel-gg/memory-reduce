# Version history

## Reduce Memory 2.8 — 2026

- Removed 13 provably unreachable helpers inherited from the reconstructed
  Windows source, consolidated repeated numeric INI validation, and reused the
  candidate filter's working-set measurement during trimming. This reduces
  source size and per-pass process queries without weakening safety checks or
  changing the visible mode contract.
- Replaced magic mode/profile numbers and the active obfuscated UI/optimizer
  entry points with named constants and descriptive functions. Mode labels now
  have one source of truth while retaining the established dropdown order and
  numeric INI compatibility.
- Preserved the original `AdjustTokenPrivileges` call error before handle
  cleanup, hardened worker-result numeric validation, and made a timed-out
  elevated worker stop with its temporary result removed instead of continuing
  an unobserved release pass.
- Separated the real Windows candidate floors: Normal now defaults to 96 MB,
  Smooth to 48 MB, Aggressive to 4 MB, and AI Shield to 64 MB. The compatible
  legacy `MinProcessMB` setting remains the baseline for conservative profiles.
- Kept the current foreground window protected in Aggressive while allowing an
  application that has moved to the background to become eligible immediately;
  recent-activity and CPU shields remain active for Normal, Smooth, and AI
  Shield.
- Added a final empty-working-set and standby-purge sequence after the second
  elevated Aggressive process pass. Full Aggressive now reports up to six
  distinct native successes; Emergency reports up to twelve across two cycles.
- Extended the Administrator worker protocol and bounded log with its measured
  available-RAM change, while keeping this system delta separate from the sum
  of per-process working-set reductions.
- Added a disposable full-Aggressive Windows integration gate. It requires two
  elevated process passes, at least four accepted native stages, at least 64 MB
  of measured working-set reduction, and proof that the target stays alive.
- Retained the separately validated Linux Desktop/Server 2.7 reclaim engine in
  the unified 2.8 release; its native syscall, cache, cgroup, and installer gates
  continue to run unchanged.

## Reduce Memory 2.7 — 2026

- Added real per-process Windows working-set measurement before and after every
  successful trim, separate from the system-wide Available RAM delta.
- Replaced the Windows elevated worker's success-only file with a structured
  result containing trim operations, measured bytes, native stages, and pass
  count; both x64 and x86 self-tests validate the parser.
- Made Windows Smooth perform one elevated process pass and made full
  Aggressive bracket its native memory-list/cache release with two elevated
  process passes. Emergency still uses its explicit confirmation and two full
  release cycles.
- Strengthened the Windows integration test with a disposable 256 MB resident
  allocation. A build now fails unless each architecture measurably removes at
  least 64 MB while leaving the process alive.
- Batched up to 64 Linux mappings into each `process_madvise(MADV_PAGEOUT)`
  call, with correct partial-result accounting and scalar compatibility
  fallback. HugeTLB mappings are now excluded explicitly.
- Made Linux Aggressive run native application page-out both before and after
  cache/cgroup reclaim, with counters accumulated across both passes.
- Added cgroup v2 `swappiness=max` anonymous-memory reclaim when swap is
  available, plus plain-request fallback for older kernels.
- Expanded Ubuntu verification for real batch calls, two-pass Aggressive,
  anonymous reclaim syntax, compatibility syntax, and reported totals.

## Reduce Memory 2.6 — 2026

- Separated AI Shield from every general optimization profile. Normal, Smooth,
  Aggressive, Temp, and Emergency no longer inherit AI-name or GPU protection.
- Added distinct Windows trim profiles instead of sending nearly every mode
  through the same process filter.
- Added a documented `SetProcessWorkingSetSizeEx` fallback when the primary
  Windows `EmptyWorkingSet` call cannot trim an otherwise accessible process.
- Made Windows Aggressive perform a broad elevated user/background pass before
  the memory-list and system-file-cache release; foreground/recent applications
  and Windows system processes remain protected.
- Made Emergency confirm before any change, then use its dedicated process
  profile and two complete elevated release passes without killing processes.
- Reworked Linux Normal, Smooth, and Aggressive as separate native profiles:
  conservative large-idle page-out, conservative page-out plus light cache
  release, and all-non-system-user page-out plus cache/cgroup reclaim.
- Increased the default Linux Aggressive cgroup request from roughly 1/16 to
  1/8 of physical RAM, bounded from 512 MB through 4 GB, while still accepting
  a smaller kernel result as valid.
- Preferred the cgroup v2 user slice before root-cgroup fallback and made the
  Server build scan regular plus non-root service UIDs for every native profile
  while keeping root and core daemon names protected.
- Added CI assertions proving AI/GPU flags appear only in AI Shield and proving
  every Linux profile receives its own thresholds and target scope.

## Reduce Memory 2.5 — 2026

- Added AI Shield on Windows, Linux Desktop, and Linux Server while keeping all
  existing mode commands compatible.
- Protected known AI processes on Windows and protected Linux AI command lines,
  GPU-device owners, and their complete child-process trees.
- Kept AI Shield away from global standby/cache purge so active models are less
  likely to reload or stutter.
- Fixed Linux automatic protection accidentally including PID 1, which could
  cause almost every server process to be skipped.
- Made Linux Server AI Shield scan all non-system UIDs while keeping root and
  system services outside the reclaim candidate set.
- Centralized repeated Linux per-pass state initialization and expanded CI for
  AI-pattern protection, mode compatibility, and Desktop/Server menus.

## Reduce Memory 2.4 — 2026

- Added Windows login cleanup through the existing startup option: wait for the
  desktop to settle, run one silent Normal pass, and keep only a hidden monitor.
- Added a 95% RAM pressure trigger requiring two consecutive samples.
- Added a five-minute cooldown and 90% re-arm watermark so sustained pressure
  cannot create a trim/reload loop.
- Kept startup non-elevated and independent from the manual dropdown, so an
  Emergency/Aggressive selection never creates a login UAC prompt or stutter.
- Added a named per-user mutex so duplicate startup shortcuts cannot create
  duplicate monitors, while retaining `/H` compatibility for old shortcuts.
- Added deterministic monitor-policy self-tests on Windows x64 and x86.

## Reduce Memory 2.3 — 2026

- Rebuilt Linux Aggressive around `pidfd_open` and
  `process_madvise(MADV_PAGEOUT)` so it can reclaim resident mappings from idle
  applications instead of depending only on cache and cgroup layout.
- Added dynamic `/proc` discovery for current and future applications without a
  process-name allowlist.
- Added CPU-activity, foreground, descendant, ancestor, minimum-RSS, locked-page,
  device-mapping, and kernel-mapping shields.
- Added per-pass process, mapping, bytes-advised, and measured RSS-reduction
  reporting.
- Bundled the native syscall helper in both Linux Desktop and Server installers
  and release packages.
- Added a real Ubuntu page-out integration test against a disposable 128 MB
  resident mapping while proving the target process remains alive.

## Reduce Memory 2.2 — 2026

- Promoted the maintained Windows, Linux Desktop, and Linux Server builds to
  one consistent 2.2 version identity.
- Includes the verified AutoIt 3.3.6.1 compatibility fix for Optimize.
- Includes expanded Windows candidate-selection self-tests on x64 and x86.
- Includes the Linux application launcher and headless Server/VPS installer.
- Includes cross-platform GitHub Actions checks for Windows, Ubuntu desktop
  installation, and Ubuntu server installation.
- Adds automated, tag-driven GitHub Release packages and SHA-256 checksums.
- Separates the Desktop launcher and headless Server installer into distinct
  source and package paths without duplicating the Linux memory engine.
- Reworks Aggressive on Linux around native cgroup v2 `memory.reclaim` instead
  of treating `compact_memory` as RAM release.
- Adds separate Linux measurements for available memory, file cache, anonymous
  application memory, and swap so small results are explained truthfully.
- Adds executable Ubuntu integration coverage for the root-only Smooth and
  Aggressive paths against disposable kernel-interface fixtures.

## Reduce Memory 2.0 — 2026

This project is inspired by Reduce Memory v1.7 from Sordum Team and continues
that idea with an upgraded source and new platform builds.

- Added five selectable optimization modes, including manual Emergency Release.
- Added Aggressive Smooth for a stronger release with less stutter risk.
- Added Aggressive Release memory-list operations.
- Added optional permanent Temp cleanup with locked-file skipping.
- Added Windows x64 and x86 builds.
- Added a native Linux companion script.
- Added a simple Linux menu plus user-local application launcher, with root
  requested only after Smooth or Aggressive is selected.
- Added a headless Linux Server/VPS installer and `reduce-memory-server` SSH
  command without adding a daemon or automatic trigger.
- Fixed the optimizer dropdown so its items and default selection remain visible.
- Removed the post-Optimize result popup and kept status in the main window.
- Added foreground, recently-active, and CPU-activity shields without maintaining
  a list of application names.
- Added immediate and stable-after-15-seconds results, rebound guard, and a
  bounded local operation log.
- Added worker result verification so cancelled or failed privileged operations
  are no longer reported as successful.
- Added safe built-in self-tests and Windows/Linux GitHub Actions verification.
- Fixed an Optimize crash caused by the unsupported AutoIt 3.3.6.1
  `ProcessGetPath()` function and replaced it with a compatible Windows API.
- Expanded self-test coverage to execute the complete Normal candidate-selection
  path on both x64 and x86 before a build is accepted.

## Earlier foundation

The original Reduce Memory v1.7 workflow remains the historical foundation for
this project. Original local backups are kept outside Git so the repository
contains only the maintained source, builds, and documentation.
