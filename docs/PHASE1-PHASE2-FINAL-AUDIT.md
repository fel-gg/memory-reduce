# Reduce Memory 4.0 - Phase 1 and Phase 2 final audit

Date: 2026-09-13  
Branch: `codex/phase2-luna-20260913`  
Implementation head: `0d6d8f4`  
Final CI gate: `34744977411`

## Final result

The maintained Phase 1 foundation and Phase 2 implementation are packaged as
the Reduce Memory 4.0 release candidate. The release decision preserves the
existing baseline/fallback strategy. No unmeasured threshold or reclaim
strategy change is advertised as an improvement.

This is the final evidence boundary of this checkout: claims below marked
`PASS` have a corresponding local or remote executable gate; claims marked
`NOT_EXERCISED` were not silently promoted.

## Phase 1 gates

| Area | Result | Evidence |
| --- | --- | --- |
| Windows x86 build and worker pair | PASS | CI build, PE/manifest checks, protocol and self-test |
| Windows x64 build and worker pair | PASS | CI build, PE/manifest checks, protocol and self-test |
| Real working-set trim | PASS | CI disposable target kept alive and measured before/after |
| Bounded refault recovery | PASS | CI recovery gate with bounded observation |
| Full Aggressive engine | PASS | CI taxonomy, stages, passes, reduction, and recovery fields |
| Linux native helper | PASS | Ubuntu 22.04/24.04 `process_madvise` and page-out gate |
| Linux launcher/cgroup path | PASS | Targeted launcher, cgroup telemetry, safe mode and failure gates |
| Linux installers | PASS | Desktop and server installer smoke on both Ubuntu images |
| Contract/unit suites | PASS | Phase 2 discovery 117 tests; benchmark discovery 11 tests |
| Compiled x86 interactive behavior on this desktop | NOT_EXERCISED | Product binary remains environment-sensitive; source/interpreter and CI build evidence are retained |
| Explicit UAC/SID/ACL live matrix | NOT_EXERCISED | Requires a dedicated disposable Windows security lab |
| Concurrent Temp path-swap race | NOT_EXERCISED | Existing containment contract passes; full concurrent runtime trace is not claimed |

## Phase 2 binary and hardware gates

| Area | Result | Evidence |
| --- | --- | --- |
| Immutable plan/ledger, ABI, compatibility, stage and scope contracts | PASS | `tests/phase2` discovery and source contracts |
| Linux hardware provenance | PASS | CI artifacts from both Ubuntu images: x86_64, 64-bit, 4096-byte pages, 4 CPUs, 1 NUMA node, RAM/swap, cgroup v2 mount, CPU model, syscall probe |
| Linux mapping grid | PASS | 10 mapping labels x 5 repeats per Ubuntu image; 50/50 ready/native terminal records per image |
| Mapping integrity lifecycle | PASS | Commit `0d6d8f4` waits for owned fixture exit and records final checksum/fixture exit |
| Linux scope read-only matrix | PASS | cgroup mount/current/max/swap/reclaim facts captured without host mutation |
| Delegated cgroup migration/overlap | NOT_EXERCISED | Read-only runner probe records `status_not_exercised_read_only`; no unsafe nested-cgroup mutation |
| Forced swap/no-swap experiment | NOT_EXERCISED | Swap availability is recorded; harness does not force paging state |
| NUMA/storage differential cost grid | NOT_EXERCISED | Available CI topology is one NUMA node; no multi-node claim |
| Alternate ISA and physical hardware variation | NOT_EXERCISED | Only available x86_64 Azure runner hardware is claimed |
| Candidate optimization superiority | NO_CHANGE_BASELINE | No candidate is accepted without valid apples-to-apples baseline, holdout, and tail-latency evidence |

## Raw evidence locations

- CI run: `https://github.com/fel-gg/memory-reduce/actions/runs/34744977411`
- Hardware artifacts: `phase2-hardware-ubuntu-22.04` and
  `phase2-hardware-ubuntu-24.04`
- Mapping artifacts: `phase2-mapping-grid-ubuntu-22.04` and
  `phase2-mapping-grid-ubuntu-24.04`
- Source fixture: `tests/linux/phase2_mapping_fixture.py`
- Mapping runner: `tests/linux/phase2_mapping_benchmark.sh`
- Scope runner: `tests/linux/phase2_scope_matrix.sh`
- Release package scripts: `release/New-ReleasePackage.ps1` and
  `release/Verify-ReleasePackage.ps1`

## Release safety

The worktree-only file `x` remains untracked and was not added, changed, or
deleted. No active user executable, user configuration, registry, pagefile,
swap configuration, or global cache was changed. CI fixtures own their child
processes and temporary files and clean them up on exit.

## Finalization rule

After the final CI gate is green, create and push tag `v4.0`, then let the
release workflow build the clean GitHub checkout. The local package generated
while `x` is present is useful for verification but is not the clean-tag
provenance source.
