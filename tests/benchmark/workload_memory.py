#!/usr/bin/env python3
"""Deterministic private-memory workload for disposable benchmark runners."""
from __future__ import annotations

import argparse
import mmap
import os
import tempfile
import time


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--megabytes", type=int, default=256)
    parser.add_argument("--seconds", type=float, default=20.0)
    parser.add_argument("--pattern", choices=("private", "file-cache", "retouch", "hot", "new-allocation", "short-lived"), default="private")
    args = parser.parse_args()
    if not 1 <= args.megabytes <= 16384:
        parser.error("--megabytes must be between 1 and 16384")
    if not 0 <= args.seconds <= 3600:
        parser.error("--seconds must be between 0 and 3600")
    if args.pattern == "short-lived" and args.seconds > 5:
        parser.error("--seconds for short-lived must be <= 5")

    page = 4096
    size = args.megabytes * 1024 * 1024
    payload = None
    mapping = None
    backing = None
    if args.pattern == "file-cache":
        backing = tempfile.TemporaryFile()
        backing.truncate(size)
        mapping = mmap.mmap(backing.fileno(), size, access=mmap.ACCESS_READ)
        for offset in range(0, size, page):
            _ = mapping[offset]
    else:
        payload = bytearray(size)
        for offset in range(0, len(payload), page):
            payload[offset] = (offset // page) & 0xFF
        if args.pattern == "retouch":
            # Touch once before the observation window, then remain idle.
            for offset in range(0, len(payload), page * 16):
                payload[offset] ^= 1
    print(f"pid={os.getpid()} pattern={args.pattern} allocated_bytes={size}", flush=True)
    deadline = time.monotonic() + args.seconds
    while time.monotonic() < deadline:
        if args.pattern == "hot" and payload:
            # Keep a small, deterministic hot set active without making the
            # whole allocation CPU-bound.
            for offset in range(0, min(len(payload), 4 * 1024 * 1024), page * 64):
                payload[offset] ^= 1
        elif args.pattern == "new-allocation" and payload is not None:
            # Delay the second allocation so reclaim tests can distinguish
            # already-resident pages from newly committed memory.
            if payload is not None and time.monotonic() + 0.5 >= deadline:
                payload.extend(bytearray(min(size, 64 * 1024 * 1024)))
                for offset in range(len(payload) - min(size, 64 * 1024 * 1024), len(payload), page):
                    payload[offset] = 7
                args.pattern = "private"
        time.sleep(min(0.25, max(0.0, deadline - time.monotonic())))
    if mapping is not None:
        mapping.close()
    if backing is not None:
        backing.close()
    # Keep allocations live until exit; the benchmark sampler can observe the
    # resident peak without the fixture freeing pages early.
    if payload and payload[0] == 255:
        print("unreachable", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
