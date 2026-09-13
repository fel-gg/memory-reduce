#!/usr/bin/env python3
"""Owned disposable mapping fixture for the Phase 2 Linux mapping grid."""
from __future__ import annotations

import argparse
import ctypes
import hashlib
import mmap
import os
from pathlib import Path
import tempfile
import time

PAGE = os.sysconf("SC_PAGE_SIZE")
MADV_HUGEPAGE = 14


def touch(mapping: mmap.mmap, stride: int = PAGE) -> None:
    for offset in range(0, len(mapping), max(PAGE, stride)):
        mapping[offset] = (offset // max(PAGE, stride) + 17) & 0xFF


def checksum(mapping: mmap.mmap) -> str:
    digest = hashlib.sha256()
    for offset in range(0, len(mapping), PAGE * 64):
        digest.update(mapping[offset : min(len(mapping), offset + PAGE * 64)])
    return digest.hexdigest()


def swap_total_kib() -> int:
    try:
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            if line.startswith("SwapTotal:"):
                return int(line.split()[1])
    except (OSError, ValueError):
        pass
    return -1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--ready", required=True)
    parser.add_argument("--seconds", type=float, default=8.0)
    args = parser.parse_args()
    cases = {
        "anonymous-private", "anonymous-with-swap", "anonymous-without-swap",
        "clean-file", "dirty-file", "shared-file", "mixed-cow", "thp",
        "sparse-file", "many-small",
    }
    if args.case not in cases:
        raise SystemExit(f"unknown fixture case: {args.case}")

    size = 32 * 1024 * 1024
    mappings: list[mmap.mmap] = []
    files: list[object] = []
    owned_dir = tempfile.TemporaryDirectory(prefix="reduce-memory-phase2-")
    try:
        if args.case == "many-small":
            for _ in range(128):
                mapping = mmap.mmap(-1, 256 * 1024, access=mmap.ACCESS_WRITE)
                touch(mapping, PAGE * 2)
                mappings.append(mapping)
        elif args.case in {"clean-file", "dirty-file", "shared-file", "mixed-cow", "sparse-file"}:
            path = Path(owned_dir.name) / "mapping.bin"
            with path.open("w+b") as stream:
                stream.truncate(64 * 1024 * 1024 if args.case == "sparse-file" else size)
            stream = path.open("r+b")
            files.append(stream)
            access = {
                "clean-file": mmap.ACCESS_READ,
                "dirty-file": mmap.ACCESS_WRITE,
                "shared-file": mmap.ACCESS_WRITE,
                "mixed-cow": mmap.ACCESS_COPY,
                "sparse-file": mmap.ACCESS_WRITE,
            }[args.case]
            mapping = mmap.mmap(stream.fileno(), 64 * 1024 * 1024 if args.case == "sparse-file" else size, access=access)
            if args.case == "clean-file":
                for offset in range(0, len(mapping), PAGE):
                    _ = mapping[offset]
            elif args.case == "sparse-file":
                touch(mapping, PAGE * 512)
            else:
                touch(mapping)
            mappings.append(mapping)
        else:
            mapping = mmap.mmap(-1, size, access=mmap.ACCESS_WRITE)
            touch(mapping)
            if args.case == "thp":
                try:
                    libc = ctypes.CDLL(None, use_errno=True)
                    address = ctypes.addressof(ctypes.c_char.from_buffer(mapping))
                    libc.madvise(ctypes.c_void_p(address), ctypes.c_size_t(len(mapping)), MADV_HUGEPAGE)
                except (AttributeError, OSError, TypeError):
                    pass
            mappings.append(mapping)

        initial = checksum(mappings[0])
        Path(args.ready).write_text(
            f"pid={os.getpid()}\ncase={args.case}\npage_size={PAGE}\n"
            f"swap_total_kib={swap_total_kib()}\ninitial_checksum={initial}\n",
            encoding="utf-8",
        )
        print(f"pid={os.getpid()} case={args.case} initial_checksum={initial}", flush=True)
        time.sleep(max(0.0, args.seconds))
        final = checksum(mappings[0])
        print(f"final_checksum={final}", flush=True)
        return 0 if final == initial else 2
    finally:
        for mapping in mappings:
            mapping.close()
        for stream in files:
            stream.close()
        owned_dir.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
