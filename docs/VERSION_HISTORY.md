# Version history

## Reduce Memory 2.0 — 2026

This project is inspired by Reduce Memory v1.7 from Sordum Team and continues
that idea with an upgraded source and new platform builds.

- Added five selectable optimization modes, including manual Emergency Release.
- Added Aggressive Smooth for a stronger release with less stutter risk.
- Added Aggressive Release memory-list operations.
- Added optional permanent Temp cleanup with locked-file skipping.
- Added Windows x64 and x86 builds.
- Added a native Linux companion script.
- Fixed the optimizer dropdown so its items and default selection remain visible.
- Removed the post-Optimize result popup and kept status in the main window.
- Added foreground, recently-active, and CPU-activity shields without maintaining
  a list of application names.
- Added immediate and stable-after-15-seconds results, rebound guard, and a
  bounded local operation log.
- Added worker result verification so cancelled or failed privileged operations
  are no longer reported as successful.
- Added safe built-in self-tests and Windows/Linux GitHub Actions verification.

## Earlier foundation

The original Reduce Memory v1.7 workflow remains the historical foundation for
this project. Original local backups are kept outside Git so the repository
contains only the maintained source, builds, and documentation.
