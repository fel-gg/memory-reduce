#!/usr/bin/env python3
"""Reproducible, non-destructive Phase 1 benchmark harness."""
from __future__ import annotations
import argparse, ctypes, hashlib, json, os, platform, random, shlex, subprocess, sys, time
from datetime import datetime, timezone
from pathlib import Path

def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

def rss_bytes(pid: int) -> int | None:
    """Best-effort resident-size sample; unavailable is recorded as null."""
    try:
        if os.name == "nt":
            class Counters(ctypes.Structure):
                _fields_ = [("cb", ctypes.c_ulong), ("pages", ctypes.c_ulong),
                            ("peak", ctypes.c_size_t), ("rss", ctypes.c_size_t),
                            ("quota_peak_paged", ctypes.c_size_t),
                            ("quota_paged", ctypes.c_size_t),
                            ("quota_peak_nonpaged", ctypes.c_size_t),
                            ("quota_nonpaged", ctypes.c_size_t),
                            ("pagefile", ctypes.c_size_t),
                            ("peak_pagefile", ctypes.c_size_t),
                            ("private_usage", ctypes.c_size_t)]
            kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
            psapi = ctypes.WinDLL("psapi", use_last_error=True)
            kernel32.OpenProcess.argtypes = [ctypes.c_ulong, ctypes.c_int, ctypes.c_ulong]
            kernel32.OpenProcess.restype = ctypes.c_void_p
            kernel32.CloseHandle.argtypes = [ctypes.c_void_p]
            kernel32.CloseHandle.restype = ctypes.c_int
            psapi.GetProcessMemoryInfo.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_ulong]
            psapi.GetProcessMemoryInfo.restype = ctypes.c_int
            handle = kernel32.OpenProcess(0x0410, False, pid)
            if not handle: return None
            counters = Counters(); counters.cb = ctypes.sizeof(counters)
            ok = psapi.GetProcessMemoryInfo(handle, ctypes.byref(counters), counters.cb)
            kernel32.CloseHandle(handle)
            return int(counters.rss) if ok else None
        status = Path(f"/proc/{pid}/status")
        for line in status.read_text(encoding="ascii").splitlines():
            if line.startswith("VmRSS:"):
                return int(line.split()[1]) * 1024
    except (OSError, ValueError, AttributeError):
        return None
    return None

def available_bytes() -> int | None:
    try:
        if os.name == "nt":
            class Status(ctypes.Structure):
                _fields_ = [("length", ctypes.c_ulong), ("memory_load", ctypes.c_ulong),
                            ("total_phys", ctypes.c_ulonglong), ("avail_phys", ctypes.c_ulonglong),
                            ("total_page", ctypes.c_ulonglong), ("avail_page", ctypes.c_ulonglong),
                            ("total_virtual", ctypes.c_ulonglong), ("avail_virtual", ctypes.c_ulonglong),
                            ("avail_extended", ctypes.c_ulonglong)]
            status = Status(); status.length = ctypes.sizeof(status)
            return int(status.avail_phys) if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)) else None
        for line in Path("/proc/meminfo").read_text(encoding="ascii").splitlines():
            if line.startswith("MemAvailable:"):
                return int(line.split()[1]) * 1024
    except (OSError, ValueError, AttributeError):
        return None
    return None

def fault_counts(pid: int) -> dict[str, int] | None:
    """Return Linux minor/major faults; unavailable is explicitly unknown."""
    if os.name == "nt":
        return None
    try:
        stat = Path(f"/proc/{pid}/stat").read_text(encoding="ascii")
        fields = stat[stat.rfind(")") + 2 :].split()
        if len(fields) < 13:
            return None
        return {"minor": int(fields[7]), "major": int(fields[9])}
    except (OSError, ValueError, IndexError):
        return None

def cpu_seconds(pid: int) -> float | None:
    """Return Linux user+system CPU seconds for a live child process."""
    if os.name == "nt":
        class FileTime(ctypes.Structure):
            _fields_ = [("low", ctypes.c_ulong), ("high", ctypes.c_ulong)]
        kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
        kernel32.OpenProcess.argtypes = [ctypes.c_ulong, ctypes.c_int, ctypes.c_ulong]
        kernel32.OpenProcess.restype = ctypes.c_void_p
        kernel32.GetProcessTimes.argtypes = [ctypes.c_void_p, ctypes.POINTER(FileTime),
                                             ctypes.POINTER(FileTime), ctypes.POINTER(FileTime), ctypes.POINTER(FileTime)]
        kernel32.GetProcessTimes.restype = ctypes.c_int
        kernel32.CloseHandle.argtypes = [ctypes.c_void_p]
        kernel32.CloseHandle.restype = ctypes.c_int
        handle = kernel32.OpenProcess(0x1000, False, pid)
        if not handle:
            return None
        creation, exit_time, kernel_time, user_time = (FileTime(), FileTime(), FileTime(), FileTime())
        try:
            if not kernel32.GetProcessTimes(handle, ctypes.byref(creation), ctypes.byref(exit_time),
                                            ctypes.byref(kernel_time), ctypes.byref(user_time)):
                return None
            kernel_ticks = (int(kernel_time.high) << 32) | int(kernel_time.low)
            user_ticks = (int(user_time.high) << 32) | int(user_time.low)
            return (kernel_ticks + user_ticks) / 10_000_000.0
        finally:
            kernel32.CloseHandle(handle)

def io_bytes(pid: int) -> dict[str, int] | None:
    """Return kernel-accounted read/write bytes for a Linux child."""
    if os.name == "nt":
        return None
    try:
        values: dict[str, int] = {}
        for line in Path(f"/proc/{pid}/io").read_text(encoding="ascii").splitlines():
            key, _, value = line.partition(":")
            if key in {"read_bytes", "write_bytes"}:
                values[key] = int(value.strip())
        return values if len(values) == 2 else None
    except (OSError, ValueError):
        return None

def swap_bytes(pid: int) -> int | None:
    """Return VmSwap in bytes for a Linux child."""
    if os.name == "nt":
        return None
    try:
        for line in Path(f"/proc/{pid}/status").read_text(encoding="ascii").splitlines():
            if line.startswith("VmSwap:"):
                return int(line.split()[1]) * 1024
    except (OSError, ValueError, IndexError):
        return None
    return None
    try:
        stat = Path(f"/proc/{pid}/stat").read_text(encoding="ascii")
        fields = stat[stat.rfind(")") + 2 :].split()
        if len(fields) < 13:
            return None
        ticks = os.sysconf("SC_CLK_TCK")
        return (int(fields[11]) + int(fields[12])) / float(ticks)
    except (OSError, ValueError, IndexError, TypeError):
        return None
def run_trial(label: str, command: str, timeout: float, after_seconds: list[float]) -> dict[str, object]:
    started = time.perf_counter()
    peak_rss = None
    before_available = available_bytes()
    faults_before = None
    faults_after = None
    last_faults = None
    cpu_before = None
    cpu_after = None
    last_cpu = None
    io_before = None
    io_after = None
    last_io = None
    swap_before = None
    swap_after = None
    last_swap = None
    try:
        process = subprocess.Popen(shlex.split(command, posix=(os.name != "nt")),
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        faults_before = fault_counts(process.pid)
        cpu_before = cpu_seconds(process.pid)
        io_before = io_bytes(process.pid)
        swap_before = swap_bytes(process.pid)
        while process.poll() is None:
            sample = rss_bytes(process.pid)
            if sample is not None: peak_rss = max(peak_rss or 0, sample)
            current_faults = fault_counts(process.pid)
            if current_faults is not None: last_faults = current_faults
            current_cpu = cpu_seconds(process.pid)
            if current_cpu is not None: last_cpu = current_cpu
            current_io = io_bytes(process.pid)
            if current_io is not None: last_io = current_io
            current_swap = swap_bytes(process.pid)
            if current_swap is not None: last_swap = current_swap
            if time.perf_counter() - started >= timeout:
                process.kill(); process.communicate(); raise subprocess.TimeoutExpired(command, timeout)
            time.sleep(0.05)
        stdout, stderr = process.communicate()
        sample = rss_bytes(process.pid)
        if sample is not None: peak_rss = max(peak_rss or 0, sample)
        faults_after = fault_counts(process.pid) or last_faults
        cpu_after = cpu_seconds(process.pid) or last_cpu
        io_after = io_bytes(process.pid) or last_io
        swap_after = swap_bytes(process.pid)
        if swap_after is None: swap_after = last_swap
        status, exit_code = "completed", process.returncode
    except subprocess.TimeoutExpired as error:
        status, exit_code = "timeout", None
        stdout, stderr = "", ""
    delayed_available = {}
    for delay in after_seconds:
        time.sleep(delay)
        sample = available_bytes()
        delayed_available[str(delay)] = sample
    return {"label": label, "command": command, "status": status,
            "exit_code": exit_code,
            "elapsed_ms": round((time.perf_counter() - started) * 1000, 3),
            "available_bytes_before": before_available,
            "available_bytes_after": available_bytes(),
            "available_bytes_after_delay": delayed_available,
            "peak_rss_bytes": peak_rss,
            "faults_before": faults_before,
            "faults_after": faults_after,
            "faults_delta": ({key: faults_after[key] - faults_before[key] for key in faults_before}
                              if faults_before is not None and faults_after is not None else None),
            "cpu_seconds_before": cpu_before,
            "cpu_seconds_after": cpu_after,
            "cpu_seconds_delta": (cpu_after - cpu_before
                                   if cpu_before is not None and cpu_after is not None else None),
            "io_bytes_before": io_before,
            "io_bytes_after": io_after,
            "io_bytes_delta": ({key: io_after[key] - io_before[key] for key in io_before}
                                if io_before is not None and io_after is not None else None),
            "swap_bytes_before": swap_before,
            "swap_bytes_after": swap_after,
            "swap_bytes_delta": (swap_after - swap_before
                                  if swap_before is not None and swap_after is not None else None),
            "stdout": stdout[-65536:], "stderr": stderr[-65536:]}

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", required=True); parser.add_argument("--candidate", required=True)
    parser.add_argument("--noop", required=True); parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True); parser.add_argument("--repeat", type=int, default=5)
    parser.add_argument("--seed", type=int, default=0); parser.add_argument("--timeout", type=float, default=120.0)
    parser.add_argument("--after-seconds", default="", help="comma-separated post-trial delays, e.g. 3,15,60")
    args = parser.parse_args()
    if not 1 <= args.repeat <= 100: parser.error("--repeat must be between 1 and 100")
    if not 0 < args.timeout <= 3600: parser.error("--timeout must be in (0, 3600]")
    if not args.source.is_file(): parser.error(f"source file not found: {args.source}")
    try:
        after_seconds = [float(value) for value in args.after_seconds.split(",") if value.strip()]
    except ValueError: parser.error("--after-seconds must be comma-separated numbers")
    if any(value < 0 or value > 3600 for value in after_seconds): parser.error("post-trial delays must be 0..3600 seconds")
    commands = {"baseline": args.baseline, "candidate": args.candidate, "noop": args.noop}
    order = list(commands); trials = []
    for repetition in range(args.repeat):
        random.Random(args.seed + repetition).shuffle(order)
        for label in order:
            trial = run_trial(label, commands[label], args.timeout, after_seconds)
            trial.update(repetition=repetition + 1, order_index=len(trials)); trials.append(trial)
    report = {"schema_version": 1, "captured_at_utc": datetime.now(timezone.utc).isoformat(),
              "seed": args.seed, "repeat": args.repeat, "timeout_seconds": args.timeout,
              "after_seconds": after_seconds,
              "environment": {"python": sys.version, "platform": platform.platform(),
                              "system": platform.system(), "release": platform.release(),
                              "machine": platform.machine(), "processor": platform.processor(), "pid": os.getpid()},
              "source": {"path": str(args.source.resolve()), "sha256": sha256_file(args.source)},
              "commands": commands, "trials": trials}
    args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Benchmark report written: {args.output}")
    return 0 if all(t["status"] == "completed" and t["exit_code"] == 0 for t in trials) else 1

if __name__ == "__main__": raise SystemExit(main())
