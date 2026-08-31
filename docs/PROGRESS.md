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
- Added a working four-item mode selector:
  Normal Optimize, Aggressive Release, Aggressive Smooth, and Aggressive +
  Delete Temp.
- Added stronger memory-list operations for Aggressive Release and a lighter
  path for Aggressive Smooth.
- Added permanent Temp cleanup with a warning and locked-file skipping.
- Removed the post-Optimize result popup; status is shown in the main window.

## Packaging and platform milestone

- Built and smoke-tested x64 and x86 Windows executables.
- Added a native Bash companion for Linux memory-cache release.
- Verified the Linux script with `bash -n`.
- Verified that both Windows architectures use the same canonical source and
  that the final PE architectures match their filenames.

## Next source-level milestone

The next upgrade will be implemented as an actual source diff:

1. staged Aggressive v3 (stop when enough memory is available);
2. immediate versus stable-after-15-seconds measurement;
3. background worker/progress state so the GUI stays responsive;
4. rebound protection to avoid repeated purge/reload cycles;
5. memory-pressure and commit-pressure aware automatic triggering.
