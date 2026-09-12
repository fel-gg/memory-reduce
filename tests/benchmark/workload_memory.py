#!/usr/bin/env python3
"""Deterministic private-memory workload for disposable benchmark runners."""
from __future__ import annotations

import argparse
import os
import time


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--megabytes", type=int, default=256)
    parser.add_argument("--seconds", type=float, default=20.0)
    args = parser.parse_args()
    if not 1 <= args.megabytes <= 16384:
        parser.error("--megabytes must be between 1 and 16384")
    if not 0 <= args.seconds <= 3600:
        parser.error("--seconds must be between 0 and 3600")

    page = 4096
    payload = bytearray(args.megabytes * 1024 * 1024)
    for offset in range(0, len(payload), page):
        payload[offset] = (offset // page) & 0xFF
    print(f"pid={os.getpid()} allocated_bytes={len(payload)}", flush=True)
    deadline = time.monotonic() + args.seconds
    while time.monotonic() < deadline:
        time.sleep(min(0.25, max(0.0, deadline - time.monotonic())))
    # Keep the allocation live until process exit; the benchmark sampler can
    # observe its peak RSS without the fixture freeing pages early.
    if payload and payload[0] == 255:
        print("unreachable", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
