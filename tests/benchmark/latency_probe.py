#!/usr/bin/env python3
"""Bounded command-latency probe for active-workload benchmark fixtures."""
from __future__ import annotations

import argparse
import json
import os
import shlex
import statistics
import subprocess
import time
from pathlib import Path


def percentile(values: list[float], fraction: float) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    index = (len(ordered) - 1) * fraction
    low = int(index)
    high = min(low + 1, len(ordered) - 1)
    return ordered[low] + (ordered[high] - ordered[low]) * (index - low)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--command", required=True)
    parser.add_argument("--iterations", type=int, default=20)
    parser.add_argument("--timeout", type=float, default=10.0)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if not 1 <= args.iterations <= 1000:
        parser.error("--iterations must be between 1 and 1000")
    if not 0 < args.timeout <= 3600:
        parser.error("--timeout must be in (0, 3600]")

    samples: list[float] = []
    failures: list[dict[str, object]] = []
    argv = shlex.split(args.command, posix=(os.name != "nt"))
    for iteration in range(1, args.iterations + 1):
        started = time.perf_counter()
        try:
            completed = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                       text=True, timeout=args.timeout, check=False)
            elapsed = (time.perf_counter() - started) * 1000
            if completed.returncode == 0:
                samples.append(round(elapsed, 3))
            else:
                failures.append({"iteration": iteration, "status": "exit",
                                 "exit_code": completed.returncode,
                                 "elapsed_ms": round(elapsed, 3),
                                 "stderr": completed.stderr[-4096:]})
        except subprocess.TimeoutExpired:
            failures.append({"iteration": iteration, "status": "timeout",
                             "timeout_seconds": args.timeout})

    report = {
        "schema_version": 1,
        "command": args.command,
        "iterations": args.iterations,
        "timeout_seconds": args.timeout,
        "samples_ms": samples,
        "failures": failures,
        "summary_ms": {
            "count": len(samples),
            "median_p50": statistics.median(samples) if samples else None,
            "p95": percentile(samples, 0.95),
            "p99": percentile(samples, 0.99),
            "min": min(samples) if samples else None,
            "max": max(samples) if samples else None,
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Latency report written: {args.output}")
    return 0 if len(samples) == args.iterations else 1


if __name__ == "__main__":
    raise SystemExit(main())
