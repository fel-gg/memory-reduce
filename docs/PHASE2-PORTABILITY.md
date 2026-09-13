# Phase 2 portability and ABI contract — Luna

Status: `FINAL_IMPLEMENTATION_RELEASE_CANDIDATE`.

This document records the runtime pairs that are actually built by the current
repository and the numeric boundary shared by the Windows worker, AutoIt
frontend, Linux helper, and benchmark parser. It is not a claim that every
listed pair has been live-tested on every OS.

## Supported contract pairs

| Pair | Pointer width | `size_t` / `ssize_t` | Endian | Evidence boundary |
| --- | ---: | ---: | --- | --- |
| Windows frontend x86 + worker x86 | 32-bit | 32 / 32 | little | Local pinned AutoIt/Zig staging and worker protocol tests |
| Windows frontend x64 + worker x64 | 64-bit | 64 / 64 | little | Local pinned AutoIt/Zig staging and worker protocol tests |
| Linux native helper on x86_64 | 64-bit | 64 / 64 | little | Source ABI declarations plus remote CI Ubuntu 22.04/24.04 native/launcher/installer gates; broader matrix pending |

Unknown architecture/ABI is unsupported and must stop before any syscall or
mutator. A string containing an architecture name is not runtime evidence.

## Numeric rules

- Addresses and lengths are unsigned and bounded by the selected pointer
  width. `address + length` is checked before a native call; wraparound is a
  rejection, not a truncated range.
- Counts are bounded independently from bytes. The worker protocol retains its
  16,384-record and 8 MiB limits.
- Resident deltas are signed 64-bit values. Growth remains negative and is not
  converted to zero. Values outside the signed range are invalid telemetry.
- AutoIt numeric metric fields have an exact safe integer ceiling of
  `9007199254740991` (2^53-1); larger decimal telemetry is rejected before
  conversion. Process creation-time identity remains a 16-digit hex string so
  a 64-bit identity is not rounded.
- Byte/count fields are decimal or explicitly validated hexadecimal text; no
  raw C struct or persistent pointer crosses the process boundary.
- Runtime page size must be a positive power of two within the bounded helper
  range and every page-out range must be page-aligned.

The pure reference implementation is
`tests/phase2/abi_contract.py`; its tests exercise x86/x64 boundaries,
address-plus-length overflow, signed growth, record counts, and page-size
validation. These tests prove pre-call arithmetic only; they do not prove a
kernel's capability or reclaim effectiveness.

## Runtime dependencies and support levels

- Windows requires the pinned AutoIt runtime/toolchain and matching x86/x64
  worker pair. The staged manifest and protocol handshake must be checked before
  mutation; unsigned local artifacts retain that provenance.
- Linux requires Python/Bash plus the native helper's available libc/syscall
  interface, `pidfd_open`/`process_madvise` capability where used, and the
  target's permission domain. Missing syscall, denied capability, seccomp, and
  unknown ISA are distinct statuses.
- `runtime-tested` is reserved for a live OS/ISA execution with the required
  fixture. `compile-tested` covers a build without kernel/permission evidence.
  `specification-only` is documentation; `unsupported` is an explicit reject.

## Verification commands

```text
python -m unittest discover -s tests/phase2 -p "test_*.py"
& .\build\toolchains\autoit\install\Au3Check.exe .\src\ReduceMemory.au3
```

The current Windows host cannot reproduce Linux locally because WSL is not
installed. Remote CI run `34743359103` promotes only the Linux checks it
actually executed; swap, namespace, delegated capability, and O4.8 matrix
claims remain unpromoted. No automatic WSL installation is part of this task.
