#!/usr/bin/env python3
"""Summarize a raw benchmark report without inferring memory improvement."""
from __future__ import annotations
import argparse, json, random, statistics
from pathlib import Path

def median_ci95(values: list[float], seed: int) -> dict[str, float] | None:
    """Deterministic percentile bootstrap for the median; never an improvement claim."""
    if not values:
        return None
    if len(values) == 1:
        value = float(values[0])
        return {"lower": value, "upper": value}
    rng = random.Random(seed)
    medians = [statistics.median(rng.choices(values, k=len(values))) for _ in range(2000)]
    medians.sort()
    return {"lower": medians[int(0.025 * (len(medians) - 1))],
            "upper": medians[int(0.975 * (len(medians) - 1))]}

def numeric_summary(values: list[float], seed: int) -> dict[str, object] | None:
    if not values:
        return None
    return {"median": statistics.median(values), "min": min(values),
            "max": max(values), "median_ci95": median_ci95(values, seed)}

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    data = json.loads(args.report.read_text(encoding="utf-8"))
    groups: dict[str, list[dict]] = {}
    for trial in data.get("trials", []):
        if trial.get("status") == "completed" and trial.get("exit_code") == 0:
            groups.setdefault(str(trial.get("label")), []).append(trial)
    summary = {}
    for label, trials in groups.items():
        durations = [float(t["elapsed_ms"]) for t in trials]
        rss = [int(t["peak_rss_bytes"]) for t in trials if t.get("peak_rss_bytes") is not None]
        tree_rss = [int(t["process_tree_peak_rss_bytes"]) for t in trials
                    if t.get("process_tree_peak_rss_bytes") is not None]
        tree_cpu = [float(t["process_tree_cpu_seconds_delta"]) for t in trials
                     if t.get("process_tree_cpu_seconds_delta") is not None]
        available = [int(t["available_bytes_after"]) - int(t["available_bytes_before"])
                     for t in trials if t.get("available_bytes_before") is not None and t.get("available_bytes_after") is not None]
        retained: dict[str, list[int]] = {}
        for trial in trials:
            before = trial.get("available_bytes_before")
            delayed = trial.get("available_bytes_after_delay")
            if before is None or not isinstance(delayed, dict):
                continue
            for offset, value in delayed.items():
                if value is not None:
                    retained.setdefault(str(offset), []).append(int(value) - int(before))
        cpu = [float(t["cpu_seconds_delta"]) for t in trials if t.get("cpu_seconds_delta") is not None]
        swap = [float(t["swap_bytes_delta"]) for t in trials if t.get("swap_bytes_delta") is not None]
        minor_faults = [float(t["faults_delta"]["minor"]) for t in trials
                        if isinstance(t.get("faults_delta"), dict) and t["faults_delta"].get("minor") is not None]
        major_faults = [float(t["faults_delta"]["major"]) for t in trials
                        if isinstance(t.get("faults_delta"), dict) and t["faults_delta"].get("major") is not None]
        summary[label] = {"samples": len(trials),
                          "elapsed_ms": {"median": statistics.median(durations), "min": min(durations), "max": max(durations),
                                         "median_ci95": median_ci95(durations, 1009)},
                          "peak_rss_bytes": {"median": statistics.median(rss), "min": min(rss), "max": max(rss),
                                             "median_ci95": median_ci95([float(v) for v in rss], 1011)} if rss else None,
                          "process_tree_peak_rss_bytes": numeric_summary([float(v) for v in tree_rss], 1022),
                          "process_tree_cpu_seconds_delta": numeric_summary(tree_cpu, 1024),
                          "available_delta_bytes": {"median": statistics.median(available), "min": min(available), "max": max(available),
                                                     "median_ci95": median_ci95([float(v) for v in available], 1013)} if available else None,
                          "available_delta_after_delay_bytes": {
                              offset: numeric_summary(values, 1023 + index)
                              for index, (offset, values) in enumerate(sorted(retained.items()))
                          },
                          "cpu_seconds_delta": numeric_summary(cpu, 1015),
                          "swap_bytes_delta": numeric_summary(swap, 1017),
                          "faults_delta": {"minor": numeric_summary(minor_faults, 1019),
                                           "major": numeric_summary(major_faults, 1021)}}
    output = {"schema_version": 2, "source_report": str(args.report.resolve()),
              "source_seed": data.get("seed"), "source_sha256": data.get("source", {}).get("sha256"),
              "successful_groups": summary,
              "no_op_variation": summary.get("noop", {}).get("available_delta_bytes")}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    print(f"Benchmark summary written: {args.output}")
    return 0

if __name__ == "__main__": raise SystemExit(main())
