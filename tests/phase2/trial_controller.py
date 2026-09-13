"""Disposable Phase 2 trial lifecycle controller.

This module is intentionally test-only. It owns a temporary fixture directory,
launches workload/optimizer commands with bounded output files, records PID
birth identities, and tears down only identities it observed under that
fixture's process tree.
"""
from __future__ import annotations

import os
import shutil
import signal
import subprocess
import tempfile
import time
from dataclasses import dataclass, field
from enum import StrEnum
from pathlib import Path
from typing import Sequence

import sys

BENCHMARK_DIR = Path(__file__).resolve().parents[1] / "benchmark"
if str(BENCHMARK_DIR) not in sys.path:
    sys.path.insert(0, str(BENCHMARK_DIR))
from run_benchmark import process_identity, process_tree_pids  # noqa: E402


class TrialPhase(StrEnum):
    SETUP = "setup"
    READY = "ready"
    ACTION = "action"
    OBSERVE = "observe"
    INTEGRITY = "integrity"
    TEARDOWN = "teardown"
    COMPLETE = "complete"
    INVALID = "invalid"


@dataclass(frozen=True)
class PhaseTimeouts:
    ready: float = 10.0
    action: float = 30.0
    observe: float = 5.0
    teardown: float = 5.0

    def validate(self) -> None:
        if any(value <= 0 or value > 3600 for value in (self.ready, self.action, self.observe, self.teardown)):
            raise ValueError("phase timeouts must be in (0, 3600]")


@dataclass
class TrialResult:
    status: str
    phase: TrialPhase
    reason: str
    events: list[str]
    workload_pid: int | None
    optimizer_pid: int | None
    owned_identities: dict[int, str]
    cleanup_pids: list[int]
    stdout: dict[str, str]
    stderr: dict[str, str]


@dataclass
class _OwnedProcess:
    label: str
    process: subprocess.Popen[bytes]
    output: object
    error: object
    identity: str | None


@dataclass
class TrialController:
    timeouts: PhaseTimeouts = field(default_factory=PhaseTimeouts)
    max_output_bytes: int = 65536
    fixture_prefix: str = "ReduceMemory-phase2-trial-"

    def run(
        self,
        workload_command: Sequence[str],
        optimizer_command: Sequence[str] | None = None,
        *,
        ready_file: str = "ready.marker",
        observe_seconds: float = 0.0,
        require_workload_alive: bool = True,
    ) -> TrialResult:
        self.timeouts.validate()
        if observe_seconds < 0 or observe_seconds > self.timeouts.observe:
            raise ValueError("observe_seconds must be within the observe timeout")
        root = Path(tempfile.mkdtemp(prefix=self.fixture_prefix))
        events: list[str] = []
        owned: dict[int, str] = {}
        cleanup_pids: list[int] = []
        processes: dict[str, _OwnedProcess] = {}
        phase = TrialPhase.SETUP
        reason = "completed"
        status = "completed"
        stdout: dict[str, str] = {}
        stderr: dict[str, str] = {}

        def event(name: str) -> None:
            events.append(f"{phase.value}.{name}")

        def substitute(command: Sequence[str]) -> list[str]:
            # Use POSIX separators inside command strings so a Windows path
            # cannot become a Python ``\\U``/``\\t`` escape in a ``-c``
            # workload.  Filesystem APIs accept these separators on Windows.
            root_token = root.as_posix()
            ready_token = (root / ready_file).as_posix()
            return [value.replace("{root}", root_token).replace("{ready_file}", ready_token)
                    for value in command]

        def launch(label: str, command: Sequence[str]) -> _OwnedProcess:
            out = (root / f"{label}.stdout").open("wb")
            err = (root / f"{label}.stderr").open("wb")
            process = subprocess.Popen(substitute(command), cwd=root, stdout=out, stderr=err)
            identity = process_identity(process.pid)
            if identity is not None:
                owned[process.pid] = identity
            return _OwnedProcess(label, process, out, err, identity)

        def refresh_owned(process: _OwnedProcess) -> None:
            pids, _ = process_tree_pids(process.process.pid)
            for pid in pids:
                identity = process_identity(pid)
                if identity is not None:
                    owned.setdefault(pid, identity)

        def wait_exit(process: _OwnedProcess, timeout: float) -> bool:
            deadline = time.monotonic() + timeout
            while process.process.poll() is None and time.monotonic() < deadline:
                refresh_owned(process)
                time.sleep(0.02)
            return process.process.poll() is not None

        def terminate_owned() -> None:
            events.append(f"{TrialPhase.TEARDOWN.value}.start")
            deadline = time.monotonic() + self.timeouts.teardown
            direct_by_pid = {
                process.process.pid: process
                for process in processes.values()
            }
            for pid, expected in sorted(owned.items(), key=lambda item: item[0], reverse=True):
                if process_identity(pid) != expected:
                    continue
                try:
                    os.kill(pid, signal.SIGTERM)
                    cleanup_pids.append(pid)
                except (OSError, ProcessLookupError):
                    continue
            while time.monotonic() < deadline:
                alive = [pid for pid, expected in owned.items() if process_identity(pid) == expected]
                if not alive:
                    break
                time.sleep(0.02)
            for pid, expected in sorted(owned.items(), key=lambda item: item[0], reverse=True):
                if process_identity(pid) != expected:
                    continue
                try:
                    # Windows exposes SIGTERM but not SIGKILL.  The numeric
                    # kill request maps to TerminateProcess there; on POSIX
                    # it remains the hard-stop fallback after the grace
                    # period.  The birth-identity check above keeps this
                    # bounded to processes owned by this trial.
                    direct = direct_by_pid.get(pid)
                    if direct is not None:
                        direct.process.kill()
                    else:
                        os.kill(pid, getattr(signal, "SIGKILL", 9))
                except (OSError, ProcessLookupError):
                    pass
            events.append(f"{TrialPhase.TEARDOWN.value}.complete")

        workload: _OwnedProcess | None = None
        optimizer: _OwnedProcess | None = None
        try:
            event("start")
            phase = TrialPhase.READY
            workload = launch("workload", workload_command)
            ready_path = root / ready_file
            deadline = time.monotonic() + self.timeouts.ready
            event("wait")
            while not ready_path.is_file() and time.monotonic() < deadline:
                if workload.process.poll() is not None:
                    status, reason, phase = "invalid", "workload_exit_before_ready", TrialPhase.INVALID
                    break
                refresh_owned(workload)
                time.sleep(0.02)
            if phase is TrialPhase.INVALID or not ready_path.is_file():
                if phase is not TrialPhase.INVALID:
                    status, reason, phase = "invalid", "ready_timeout", TrialPhase.INVALID
            else:
                event("observed")
                phase = TrialPhase.ACTION
                if optimizer_command is not None:
                    optimizer = launch("optimizer", optimizer_command)
                    event("start")
                    if not wait_exit(optimizer, self.timeouts.action):
                        status, reason, phase = "invalid", "optimizer_timeout", TrialPhase.INVALID
                    elif optimizer.process.returncode != 0:
                        status, reason, phase = "invalid", f"optimizer_exit_{optimizer.process.returncode}", TrialPhase.INVALID
                    else:
                        event("terminal")
                if phase is not TrialPhase.INVALID:
                    phase = TrialPhase.OBSERVE
                    event("start")
                    observe_deadline = time.monotonic() + observe_seconds
                    while time.monotonic() < observe_deadline:
                        if require_workload_alive and workload.process.poll() is not None:
                            status, reason, phase = "invalid", "workload_exit_during_observe", TrialPhase.INVALID
                            break
                        refresh_owned(workload)
                        time.sleep(0.02)
                    if phase is not TrialPhase.INVALID:
                        event("complete")
                        phase = TrialPhase.INTEGRITY
                        event("pass")
                        phase = TrialPhase.COMPLETE
                        event("pass")
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            status, reason, phase = "invalid", f"controller_error:{type(error).__name__}", TrialPhase.INVALID
        finally:
            terminate_owned()
            for process in (optimizer, workload):
                if process is None:
                    continue
                # Reap the direct child as well as terminating it.  This is
                # required on both POSIX (no zombie) and Windows (release the
                # process handle) and keeps the harness warning-free.
                try:
                    process.process.wait(timeout=self.timeouts.teardown)
                except subprocess.TimeoutExpired:
                    try:
                        process.process.kill()
                    except OSError:
                        pass
                    try:
                        process.process.wait(timeout=1)
                    except subprocess.TimeoutExpired:
                        pass
                process.output.flush(); process.error.flush()
                process.output.close(); process.error.close()
                stdout[process.label] = self._tail(root / f"{process.label}.stdout")
                stderr[process.label] = self._tail(root / f"{process.label}.stderr")
            shutil.rmtree(root, ignore_errors=False)

        return TrialResult(status, phase, reason, events, workload.process.pid if workload else None,
                           optimizer.process.pid if optimizer else None, owned, cleanup_pids, stdout, stderr)

    def _tail(self, path: Path) -> str:
        with path.open("rb") as stream:
            stream.seek(0, os.SEEK_END)
            size = stream.tell()
            stream.seek(max(0, size - self.max_output_bytes), os.SEEK_SET)
            return stream.read(self.max_output_bytes).decode("utf-8", errors="replace")
