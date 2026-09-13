#!/usr/bin/env python3
"""Deterministic private-memory workload for disposable benchmark runners."""
from __future__ import annotations

import argparse
import hashlib
import mmap
import os
from pathlib import Path
import tempfile
import time


def runtime_page_size() -> int:
    """Return the host page size, rejecting unusable values."""
    try:
        value = int(os.sysconf("SC_PAGE_SIZE"))
    except (AttributeError, OSError, ValueError):
        value = int(getattr(mmap, "PAGESIZE", 0))
    if value < 1024 or value > 1024 * 1024 or value & (value - 1):
        raise RuntimeError(f"unsupported runtime page size: {value}")
    return value


def publish_marker(path: str | None, content: str) -> None:
    if not path:
        return
    destination = Path(path)
    temporary = destination.with_name(destination.name + f".tmp-{os.getpid()}")
    temporary.write_text(content, encoding="utf-8")
    os.replace(temporary, destination)


def wait_for_marker(path: str | None, deadline: float) -> bool:
    if not path:
        return False
    marker = Path(path)
    while time.monotonic() < deadline:
        if marker.is_file():
            return True
        time.sleep(min(0.05, max(0.0, deadline - time.monotonic())))
    return marker.is_file()


def deterministic_page(page: int) -> bytes:
    return bytes((offset * 17 + 31) & 0xFF for offset in range(page))


def resident_checksum(payload: bytearray | mmap.mmap, page: int) -> str:
    digest = hashlib.sha256()
    for offset in range(0, len(payload), page):
        digest.update(payload[offset : min(offset + page, len(payload))])
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--megabytes", type=int, default=256)
    parser.add_argument("--seconds", type=float, default=20.0)
    parser.add_argument("--pattern", choices=("private", "file-cache", "retouch", "hot", "new-allocation", "short-lived"), default="private")
    parser.add_argument("--ready-file", help="publish this marker after the initial pages are touched")
    parser.add_argument("--retouch-file", help="wait for this marker before retouching the private payload")
    parser.add_argument("--new-allocation-file", help="wait for this marker before the delayed allocation")
    parser.add_argument("--checksum-file", help="write initial/final SHA-256 checksums for private payloads")
    args = parser.parse_args()
    if not 1 <= args.megabytes <= 16384:
        parser.error("--megabytes must be between 1 and 16384")
    if not 0 <= args.seconds <= 3600:
        parser.error("--seconds must be between 0 and 3600")
    if args.pattern == "short-lived" and args.seconds > 5:
        parser.error("--seconds for short-lived must be <= 5")

    page = runtime_page_size()
    size = args.megabytes * 1024 * 1024
    payload = None
    mapping = None
    backing = None
    if args.pattern == "file-cache":
        backing = tempfile.TemporaryFile()
        page_data = deterministic_page(page)
        remaining = size
        while remaining:
            chunk = page_data[: min(page, remaining)]
            backing.write(chunk)
            remaining -= len(chunk)
        backing.flush()
        os.fsync(backing.fileno())
        backing.seek(0)
        mapping = mmap.mmap(backing.fileno(), size, access=mmap.ACCESS_READ)
        for offset in range(0, size, page):
            _ = mapping[offset]
    else:
        payload = bytearray(size)
        for offset in range(0, len(payload), page):
            payload[offset : min(offset + page, len(payload))] = deterministic_page(page)[: min(page, len(payload) - offset)]
    initial_checksum = resident_checksum(payload, page) if payload is not None and args.checksum_file else None
    publish_marker(args.ready_file, f"pid={os.getpid()}\npage_size={page}\nallocated_bytes={size}\n")
    print(f"pid={os.getpid()} pattern={args.pattern} allocated_bytes={size} page_size={page}", flush=True)
    deadline = time.monotonic() + args.seconds
    retouched = False
    allocated_late = False
    while time.monotonic() < deadline:
        if args.pattern == "retouch" and payload and not retouched:
            if (args.retouch_file and wait_for_marker(args.retouch_file, deadline)) or not args.retouch_file:
                for offset in range(0, len(payload), page * 16):
                    payload[offset] ^= 1
                retouched = True
        elif args.pattern == "hot" and payload:
            # Keep a small, deterministic hot set active without making the
            # whole allocation CPU-bound.
            for offset in range(0, min(len(payload), 4 * 1024 * 1024), page * 64):
                payload[offset] ^= 1
        elif args.pattern == "new-allocation" and payload is not None:
            # Delay the second allocation so reclaim tests can distinguish
            # already-resident pages from newly committed memory.
            should_allocate = wait_for_marker(args.new_allocation_file, deadline) if args.new_allocation_file else time.monotonic() + 0.5 >= deadline
            if should_allocate and not allocated_late:
                payload.extend(bytearray(min(size, 64 * 1024 * 1024)))
                extension_start = len(payload) - min(size, 64 * 1024 * 1024)
                for offset in range(extension_start, len(payload), page):
                    payload[offset : min(offset + page, len(payload))] = deterministic_page(page)[: min(page, len(payload) - offset)]
                allocated_late = True
                args.pattern = "private"
        time.sleep(min(0.25, max(0.0, deadline - time.monotonic())))
    if mapping is not None:
        mapping.close()
    if backing is not None:
        backing.close()
    # Keep allocations live until exit; the benchmark sampler can observe the
    # resident peak without the fixture freeing pages early.
    if payload is not None and args.checksum_file:
        final_checksum = resident_checksum(payload, page)
        Path(args.checksum_file).write_text(
            f"initial={initial_checksum}\nfinal={final_checksum}\npage_size={page}\n",
            encoding="utf-8",
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
