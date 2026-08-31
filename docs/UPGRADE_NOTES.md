# ReduceMemory v1.7 â€” adaptive upgrade

This folder keeps the original Sordum ReduceMemory project and adds a
ReduceMemory v2.0 upgrade built from the canonical source.
conservative adaptive pass to the x64 executable.

## Active build

- `ReduceMemory_x64.exe` is the modified build compiled from the verified
  extracted AutoIt source.
- `ReduceMemory.exe` is the v2.0 x86 build compiled from the same canonical
  source as the x64 build.
- `backup-original-v1.7-20260831` contains the original executable, INI, and
  history file. Copy those files back to roll back.

## What changed

- Automatic optimization now uses a lower watermark (hysteresis) and a
  cooldown, avoiding repeated working-set trimming during sustained load.
- The normal automatic pass protects the foreground application and critical
  Windows processes.
- Small processes below the configured working-set floor are skipped.
- `EmptyWorkingSet` results are checked instead of treating every attempted
  process as a success.
- Existing CLI, include/exclude behavior, UI, and old INI keys are retained.

## New INI keys

```ini
SmartOptimize=1
CooldownSeconds=300
HysteresisPercent=5
MinProcessMB=32
ProtectForeground=1
```

All keys have safe defaults in the executable, so older INI files remain
compatible. Set `SmartOptimize=0` to return the automatic scheduler to its
original trigger behavior. Manual Optimize and explicit include mode remain
available.

The modified executable is unsigned because recompilation invalidates the
original Sordum Authenticode signature. The original signed files are kept in
the backup directory.

## Current mode-feature status

The Normal/Aggressive/Aggressive + Delete Temp source changes are present in ReduceMemory_Upgraded_Source_x64.au3, but are not active in the shipped x64 binary yet. A startup smoke test exposed an AutoIt 3.3.6.1 runtime compatibility issue in that new UI path, so the active executable was deliberately restored to the previously validated adaptive build. No unverified binary is left active.

## Current build (2026-08-31)

### Aggressive v2 fix

- Active x64 SHA-256: `A98F0F5261FEBCAD95B204411386AF265E4405B3529EFAE3978C79248909A81D` (909,915 bytes).
- Aggressive now explicitly enables `SeProfileSingleProcessPrivilege` and `SeIncreaseQuotaPrivilege`, checks every native return status, and no longer reports success unconditionally.
- Aggressive runs system working-set emptying, modified-list flushing, standby-list purging, and documented system file-cache flushing in addition to the normal per-process trim.
- The old bug that forced the displayed result to `0 MB` whenever per-process trimming returned zero has been fixed; cache/standby release is now counted independently.
- Manual Aggressive runs wait for the memory manager, then show the available-RAM delta in the main status bar.
- Administrator access is requested by a short-lived worker only when an Aggressive operation is started.
- Dead external string-loader `FileInstall` dependencies were removed, so `Aggressive + Delete Temp` can no longer delete build resources needed for future compilation.
- The previous GUI build is backed up as `backup-original-v1.7-20260831\ReduceMemory_x64.pre-aggressive-v2.exe`.

- Final mode/UI pass (2026-09-01): startup is non-elevated. Normal opens without UAC; an elevated worker is requested only when an Aggressive action needs Windows memory privileges.
- The selector contains `Normal Optimize`, `Aggressive Release`, `Aggressive Smooth`, and `Aggressive + Delete Temp`.
- `Aggressive Smooth` purges only the low-priority standby list after the protected process trim. It skips modified-list and system file-cache flushing to reduce stutter.
- Selecting a mode writes `OptimizeMode=0/1/2/3` to `[Main]`. Result report popups were removed; the main status bar shows released memory. Permanent temp deletion still requires confirmation.
- The x86 build now uses the same upgraded source and passed the same launch/responding smoke test as x64.
- Linux support is provided by `ReduceMemory_Linux.sh`; see `LINUX_README.md`.
- Final side-by-side x64 SHA-256: `BCEB7F755FDF8398D8D11184295C82EE11CCAAF53DB1BD7E31E156CDF668573F`.
- Final active x86 SHA-256: `39AE96251C013E0A60628726FED012FA5CAD25CBAA30245957310847481D6067`.
- All `www.sordum.org` / `sordum.org` URL strings were removed from the upgraded source, active x64 executable, and active INI.
- The original x64 executable is preserved as `backup-original-v1.7-20260831\ReduceMemory_x64.pre-upgrade-20260831.exe`.
- The earlier incomplete/no-selector build is preserved as `backup-original-v1.7-20260831\ReduceMemory_x64.previous-no-ui-build.exe`.
- The x86 executable is now the upgraded build.
