# Phase 2 reclaim contract — draft for Luna

Status: `PARTIAL_PREP_BLOCKED_DEPENDENCY`.

This document maps the smallest shared contract needed by the existing
frontend, Windows worker, Linux native helper, and Bash launcher. It does not
introduce a plugin framework or change the engine result yet. H0.1 becomes
accepted only after the Phase 1 baseline gate and H0.2 contract fixtures pass.

## 1. Immutable execution plan

One Optimize operation creates one immutable `ExecutionPlan` before the first
mutating stage:

| Field | Meaning | Existing source of truth |
|---|---|---|
| `session_id` | One operation across all stages and recovery | AutoIt `RM_SessionID`; worker `session=` |
| `profile` | Normal/Smooth/Aggressive/Emergency/AI Shield profile | `RM_RunConfiguredTrim`, Linux profile argument |
| `scope` | Explicit target/scope policy, never implicit global reclaim | Windows `/pid`/`/all` guard; Linux UID/target policy |
| `snapshot_identity` | PID plus birth/creation identity captured before action | Windows worker record `birth_hex`; Linux starttime/boot identity |
| `targets` | Immutable target/range set from the snapshot | Windows process records; Linux `RssTarget`/mapping records |
| `capabilities` | Probe result and permission domain | Windows fallback/elevation state; Linux `command_check` and errno taxonomy |
| `profile_revision` | Config/profile revision used by the plan | portable INI/profile values at plan creation |

Targets discovered after the snapshot are `outside_snapshot`/`deferred`; the
engine does not rescan indefinitely inside one session.

The test-only executable model is in `tests/phase2/reclaim_plan.py`:
`ExecutionPlan` is frozen before action, and `ExecutionLedger` accepts one
record per planned stage while rejecting wrong-session, out-of-plan, and
replay attempts. This proves the contract shape only; it is not yet wired to
the Windows or Linux mutators.

## 2. Stage and result contract

Each stage has a `stage_id`, `stage_kind`, `pass_id`, `session_id`, input scope,
and terminal result. `stage_kind` remains explicit and platform-neutral while
the adapter keeps platform-specific semantics:

```text
stage_kind = process_trim | range_pageout | file_cache | cgroup_reclaim |
             system_release | recovery
status     = done | partial | unsupported | permission_denied |
             no_candidates | cancelled | timeout | failed | unknown
```

The result must carry:

- `mutated`: whether the adapter can prove a mutation request was accepted;
- `bytes_requested` and `bytes_advised`: request/advice domain only;
- `resident_before`/`resident_after` and signed delta when identity and
  snapshots are valid;
- `attempted`, `measured`, `unmeasured`, `deferred`, and `unavailable` counts
  as separate dimensions;
- `os_code`/`os_error` and adapter-specific reason;
- `terminal`: whether the child/action is known to have ended;
- `metadata_unknown`: explicit list of fields unavailable on this platform.

Missing output after a possible mutation is `unknown`/`partial`; it is never a
successful zero and never an automatic broad replay.

## 3. Adapter mapping

### Windows process adapter

- Plan/selection: `RM_RunConfiguredTrim`, `RM_RunNativeProcessPass`.
- Ownership: `RM_RunOwnedNativeWorker`, Job Object kill-on-close, UAC envelope.
- Producer: `ReduceMemoryWorker*.exe` protocol v2.
- Consumer: `RM_ParseNativeProcessResult`, session measurement ledger.
- Identity: PID plus validated creation/birth value in each record.

### Linux range/page-out adapter

- Plan/selection: `snapshot_processes`, `snapshot_mappings`, UID/protection
  policy in `linux/native/reduce-memory-native`.
- Action: `pageout_process`, `process_madvise`/pidfd path.
- Cgroup/system adapter: `command_reclaim` plus Bash stage policy in
  `linux/ReduceMemory_Linux.sh`.
- Consumer: native key/value result, Bash stage status and session output.
- Identity: boot identity plus PID/starttime and mapping identity where
  available; PID alone is insufficient.

## 4. Execution ledger

The execution ledger is separate from the immutable plan. One row represents
one target/stage attempt and contains:

```text
session_id, pass_id, stage_id, target_identity, stage_kind,
disposition, action_status, mutated, before_valid, after_valid,
identity_valid, bytes_requested, bytes_advised, resident_delta,
os_code, reason, started_monotonic, ended_monotonic
```

`disposition` values are not mutually exclusive with measurement fields:
`eligible`, `attempted`, `deferred`, `measured`, `unmeasured`, and
`unavailable` must remain independently reconcilable. A target that exits after
an attempt remains `attempted` even if its final snapshot is unavailable.

## 4.1 Selection reconciliation

The Linux native helper now assigns one selection reason to every process in
the immutable process snapshot before action: `protected`, `below_threshold`,
`active`, `invalid_identity`, or `eligible`. It emits these as
`selection_<reason>` counters, while action outcomes remain separate
(`processes_advised`, `processes_failed`, and RSS measurement statuses). This
prevents an eligible/attempted count from being mistaken for a partition that
also includes observation availability. Windows worker taxonomy remains the
existing `protected`, `filtered`, `foreground`, access/query, threshold, and
trim counters until the cross-platform ledger adapter is accepted.

`linux/ReduceMemory_Linux.sh` now carries the native `selection_*` counters
through stage aggregation and prints them separately from attempted RSS
measurements. Older helper output is treated as a missing optional diagnostic
field (displayed as zero only for that diagnostic); missing measurement or
reclaim bytes are never converted into a successful result.

The Windows worker's `/selection-selftest` covers the name-filter boundary
without introducing an application whitelist: matching is case-insensitive
and exact between pipe delimiters, while Unicode names, null filters, and
unterminated/substring cases are rejected or handled conservatively. This is a
pure selection check; it does not claim path/mixed-bitness runtime coverage.

### 4.2 Capability reconciliation

The Linux native helper performs a read-only `process_madvise` capability probe
before page-out. `syscall_capability()` keeps `supported`, `unsupported`, and
`permission_denied` separate, with a reason identifying a missing syscall,
unknown ISA, non-Linux host, unavailable libc, or permission/seccomp denial.
`command_check` and `pageout` expose the capability status and probe errno;
unsupported or denied capability stops before target discovery/mutation. This
prevents an unavailable or policy-denied syscall from being reported as a
successful zero-byte reclaim or silently widening scope to a global fallback.

### 4.3 Mapping observation metadata

`parse_smaps` now preserves optional per-mapping observation fields—anonymous,
private/shared clean and dirty bytes, swap, kernel/MMU page size, and
`AnonHugePages`—alongside existing RSS, locked bytes, and `VmFlags`. Missing,
malformed, or negative optional values remain explicit unknowns (`None`). The
metadata is observational at this checkpoint; it does not silently broaden or
reduce eligibility until O4.2/O4.3 differential fixtures establish the safety
and coverage effect.

Before iovec construction, O4.2 now validates the runtime page size and each
mapping's start/end bounds, address width, and page alignment. An invalid range
returns `invalid_range` before `process_madvise`; it is recorded as a failed
eligible action, never as advised bytes or measured RSS reduction. The unit
fallback page size exists only to keep pure fixtures executable on Windows;
Linux production capability probing remains authoritative.

The mapping exclusion decision is centralized in `mapping_exclusion_reason`:
locked, device, explicit special `VmFlags` (`lo/io/pf/ht`), special kernel
paths, and non-readable ranges remain protected. `AnonHugePages` alone is not
treated as explicit HugeTLB; any future THP strategy must be evaluated by its
own fixture and never inferred from one metadata field.

`chunk_mapping_range` is the current O4.4 pure seam for future iovec planning:
each chunk carries the parent mapping id and byte offset, and the builder
proves page-aligned, gap-free, non-overlapping coverage under a caller-provided
byte budget. It is intentionally not a new default batch size; O4.5/O4.8 must
measure and integrate it without introducing a session-wide reclaim cap.

`build_iovec_batches` is the companion O4.5 pure seam. It preserves chunk order
while enforcing both a per-call byte budget and an iovec-count budget; an
oversized chunk or non-positive limit is rejected before native construction.
These are per-syscall limits only and do not imply parallel calls or a total
session reclaim ceiling.

### 4.4 Bounded execution and residual accounting

`pageout_process` now accepts an optional monotonic deadline and caller-owned
cancel check. Both are evaluated only at boundaries before a batch or scalar
continuation; a blocking kernel call is not described as instantly
interruptible. When the guard stops execution, the helper returns `deadline`
or `cancelled`, does not issue another advice call, and reports the remaining
virtual range bytes as `bytes_deferred`. Mapping/PID identity is still
reconciled in the unconditional final check, so a later mapping change can
override the control status with the safer identity result.

The CLI exposes `--deadline-ms` (zero disables it) and `--cancel-file`; it
emits `control_status`/`bytes_deferred`. The Bash launcher passes the optional
`REDUCE_MEMORY_NATIVE_DEADLINE_MS` and `REDUCE_MEMORY_NATIVE_CANCEL_FILE`
values and aggregates deferred bytes without turning them into advised bytes.
The cancel marker is caller-owned and read-only; the helper never creates or
deletes it. Ctrl+C remains the launcher-level hard-interrupt path. The unit
fixture proves cancellation before the first advice leaves all range bytes
deferred and the mutator spy untouched; this is contract evidence, not yet a
live Linux timeout/target-exit measurement.

### 4.5 Cgroup reclaim scope identity

`command_reclaim` now requires a cgroup-v2 `memory.reclaim` path whose parent
is inside a mountpoint reported by the current process namespace. Final-path
symlinks and paths outside the verified cgroup2 mount are rejected. Before the
write, the helper opens with `O_NOFOLLOW` where available and compares the
opened device/inode identity with the preflight identity; a replacement race
returns `scope_changed` without calling `write`. This preserves the existing
bounded payload and swappiness validation and does not add a root-cgroup
fallback.

Unit coverage includes unknown/outside mount rejection and an identity-swap
mutator spy. Remote CI run `34743359103` now provides live Linux runner
evidence for native page-out, cgroup write/metadata, launcher mode paths, and
installer checks. Mount-namespace isolation, delegated ownership,
ancestor-limit, permission-change, and the full O4.8/O5.2 matrix remain
`PENDING_ENV` because the current workflow does not exercise those cases.

The Bash cgroup stage records the requested amount, write duration, and the
signed `memory.current` scope delta independently. A missing or malformed
before/after value remains `unknown`; it is never treated as zero reclaim.
Protocol/lost-result handling performs the after snapshot before classifying
the result and never retries the whole request automatically. The delta is a
scope-observation metric, not a claim that the kernel advised exactly that
many bytes.

## 5. Compatibility boundary

Protocol v2 remains the transport baseline. New fields must be optional only
when an old consumer can safely ignore them; otherwise the transport version
must change with producer, parser, fixtures, and CI in one batch. Numeric
values use decimal/hex text with explicit width rules; no pointer struct or
floating-point identity is persisted. Invalid or wrong-session input must not
commit ledger/history/UI totals.

## 6. Acceptance tests still required

H0.2 must exercise denied, unsupported, unknown, cancel, partial, wrong-session,
ready-missing, and result-missing-after-mutation cases with an ordered event
log and zero unintended mutator calls. A test-only H0.3 boundary model now
exists in `tests/phase2/compatibility_harness.py` with `6/6` tests covering
old/new producer metadata, truncation, overflow, duplicate identities, the
8 MiB/16,384-record limits, and unknown metadata. It does not replace the
production parser. H0.3 still requires producer/consumer fixtures and H0.4
must prove the existing engine can invoke the seam without changing
profile/exclusion/trigger decisions.

## 7. H0.4 implementation checkpoint

`src/ReduceMemory.au3` now exposes a narrow Windows adapter seam through
`RM_BuildWindowsProcessStage` and `RM_ValidateWindowsProcessStage`. The
existing `RM_RunNativeProcessPass` builds this stage before launching the
already-owned worker. The stage records session/profile/scope/worker/result/
handshake identity and the exact protocol-v2 command; validation rejects a
missing worker, invalid profile/session, or incomplete command before any
mutator is started.

The seam deliberately retains the existing `RM_RunConfiguredTrim` decisions:
Normal/Smooth still use the same fallback policy, Aggressive/Emergency still
use the same native eligibility and churn-filter branches, and foreground/
include/exclude arguments are formed by the same policy inputs. It is a
structure seam, not a new optimizer or plugin framework.

`/RMPLANSELFTEST` exercises a supported Aggressive stage, an include-only
Normal stage, session/profile command identity, and invalid-profile rejection
without launching a mutating worker. The staged x64 build exited `0`; source
`Au3Check` exited `0` with no warnings. Compiled frontend build coverage now
includes this probe in `tests/windows/Build.Tests.ps1`.

H0.4 remains `PARTIAL_PREP` rather than `PASS`: the seam is proven in the
Windows x64 staging path, but x86 handoff and live Linux adapter integration
still need their platform-specific runtime evidence. No reclaim result or
performance gain is claimed from this checkpoint.
