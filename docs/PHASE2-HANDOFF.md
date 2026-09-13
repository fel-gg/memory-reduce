# Reduce Memory — Phase 2 Luna handoff (partial, evidence-first)

Status: `PARTIAL_PREP_BLOCKED_DEPENDENCY` — this is a working handoff, not a
full Phase 2 sign-off. It records what is actually implemented and what still
requires a Linux runner, an interactive x86 desktop, or a final candidate
experiment.

## Current source and baseline

- Repository: `C:\Users\user\OneDrive\Dokumen\Desktop\ReduceMemory\ReduceMemory`
- Baseline manifest:
  `build/phase2/g03-baseline-ui-20260913/BASELINE-MANIFEST.json`
- Manifest SHA-256:
  `1EE40A19EE09C585BB76261A93BCE24398070CA7EC80CC90268704DDE4236E58`
- Active user process preserved: PID `19840` (`ReduceMemory_x64.exe`).
- User untracked file `x` preserved.
- Continuation commits were pushed on `codex/phase2-luna-20260913`; no tag,
  publish, active executable replacement, global purge, registry/pagefile
  change, or user-file deletion was performed.

## Implemented contract/runtime changes

- Windows H0.4 seam validates the existing worker stage before execution.
- ABI and wire numeric boundaries reject overflow before mutation or lossy
  conversion.
- Linux O1.1/O1.3 selection and PID/mapping identity accounting is explicit.
- Linux O4.1–O4.7 preserve mapping metadata, validate ranges, batch iovecs,
  continue only the unprocessed suffix, and expose bounded deadline/cancel
  residuals as `bytes_deferred`.
- Linux O5.1/O5.5 validate cgroup scope/mount/identity before write and record
  signed scope deltas and duration without full retry.
- O2.2, O2.3/O2.4, O3.1-O3.5, O4.8, O4.9/O4.10, O5.2, O5.3, O5.4, O6.1/O6.5/O6.6, H3.1, and H3.4 now have test-only parity,
  benchmark-grid, advice-credit, scope-overlap, swap-allowance, and
  deterministic path-policy/interface-evolution/target-table/stage-ablation contracts. These are preparation evidence, not
  kernel/runtime claims.

## Evidence commands and latest results

```text
python -m unittest discover -s tests/phase2 -p "test_*.py"  # 117/117
python -m unittest discover -s tests/benchmark -p "test_*.py"  # 11/11
python -m unittest tests/linux/test_native_unit.py  # 49/49
python -c "import pathlib,py_compile; files=list(pathlib.Path('tests/phase2').glob('*.py'))+list(pathlib.Path('tests/benchmark').glob('*.py')); [py_compile.compile(str(p),doraise=True) for p in files]; print('PY_COMPILE_OK',len(files))"  # 45 files
bash -n linux/ReduceMemory_Linux.sh linux/native/reduce-memory-native
Au3Check src/ReduceMemory.au3  # 0 errors, 0 warnings
git diff --check
# Plan audit: 84 unique task IDs in the Luna plan, 84 represented in checkpoint
```

Windows staging evidence:

- x64 UI smoke: `modes=6; selection-binding=passed`.
- x86/x64 worker protocol: exit `0` for both pairs.
- x64 parent-death Job Object: exit `0`.
- Temp containment and locked-file behavior: exit `0`.
- Windows benchmark r2: `15/15` completed, `15/15` exit `0`, observers
  `+3/+15/+60`, `negative_cpu_trials=0`.
- Local package verification: `build/phase2-package-final-20260913/ReduceMemory-3.0-phase2.zip`
  dibuat dari staging bersih + Linux tree; verifier ekstraksi/hash lulus;
  ZIP SHA-256 `F0AD15C91973E1DF3BD5B57E4B293D8FAEA7BF75E2CEFAF423C9E9B7A12D9F32`.

Remote CI runtime evidence:

- Run `34743359103` pada commit `ae39e7c916f288ca9342449e023a97dc7df31d8f`
  lulus pada Windows build, x64/x86 self-test, real working-set trim,
  bounded refault recovery, dan full Windows Aggressive engine.
- Run yang sama lulus pada Ubuntu 22.04 dan 24.04 untuk native page-out,
  targeted launcher reclaim, cgroup telemetry, safe self-check, Smooth/
  Aggressive paths, user-local installation, dan server installation.
- CI result ini menutup runner gate yang dijalankan; tidak memilih candidate
  Phase 2 atau menutup desktop x86 interactive launch.

Profile/experiment preparation:

- `tests/phase2/profile_contract.py` and `test_profile_contract.py` freeze the
  offline O6.1/O6.5/O6.6 contract: bounded parameters, profile revision and
  artifact hash, holdout seed/raw digest, explicit `accepted`/`rejected`/
  `needs_confirmation`, and integration only after acceptance while preserving
  user overrides.
- The profile contract regression is `7/7`; it does not select final values or
  claim a reclaim improvement without the live O2/O3/O4/O5 evidence.

## Open gates

1. Full Phase 1 UI pair is not closed. The x86 compiled frontend does not
   return from launch in the current desktop environment, including its
   bounded self-test path; source interpreted by the pinned x86 AutoIt runtime
   does return. This is recorded as `PENDING_ENV`, not silently converted into
   a product pass.
2. WSL is not installed locally (`wsl --status` exit `50`). Remote CI run
   `34743359103` now proves the Linux syscall/launcher, cgroup output,
   timeout-bounded launcher, mode paths, and both installer checks on Ubuntu
   22.04/24.04. Local namespace/swap/capability exploration and O4.8
   benchmark-grid evidence remain pending.
3. Concurrent Windows Temp path-swap runtime evidence is not complete.
4. O2/O3/O4/O5 candidate selection has not been run. The existing Windows r2
   benchmark changes only seam/UI behavior and must not be called a reclaim
   improvement.
5. Final O6/O7/H2/H3/H4 release, reproducibility, package, and handoff gates
   remain dependent on the preceding live evidence.

## Safe continuation order

1. On a clean interactive Windows x86-capable desktop, reproduce the staged
   x86 frontend launch and capture process-start/loader evidence before changing
   build flags or product logic.
2. On a disposable Linux VM/runner, run the existing Linux unit/failure
   suites, then O4.8 mapping grid and O5.2–O5.7 scope/swap matrix with raw
   manifests.
3. Rebuild the four Windows artifacts after any source change and regenerate
   the baseline manifest; never reuse a stale artifact hash.
4. Only after G01/G03 and O0.7 are closed, run same-target and
   intended-coverage candidate experiments. Keep rejected/no-change decisions
   and raw data.
