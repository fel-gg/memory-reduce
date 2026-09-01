# Upgrade progress

This file records real milestones. It intentionally distinguishes reconstructed
build artifacts from source-level history; the original folder did not contain
the AutoIt source for every intermediate binary.

## Baseline

- Original portable Reduce Memory v1.7 binaries and INI were preserved under
  `backup-original-v1.7-20260831/` locally and are excluded from Git.
- The upstream repository initially contained only `README.md` and `LICENSE`.
- The upgrade keeps the existing Reduce Memory identity and configuration style.

## Completed source snapshot

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
- Added CI coverage for server installation, safe status output, executable
  permissions, and the Linux Server interactive menu.
- Added tag-driven GitHub Release packaging with audited Windows, Linux Desktop,
  Linux Server, and SHA-256 assets created directly from the tagged commit.

## Deliberately not included

- Stop-when-enough targets are not used; a selected mode runs its defined pass.
- No new automatic memory-pressure trigger was added.
- Temp cleanup behavior was not expanded beyond its existing warning and
  locked-file skipping.
- The first half of Active Application Shield is implemented; GPU, audio,
  recording, and fullscreen detection remain outside the current scope.
