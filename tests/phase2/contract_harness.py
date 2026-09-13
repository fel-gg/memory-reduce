"""Small ordered-event adapter used to test Phase 2 execution boundaries."""
from __future__ import annotations

from dataclasses import dataclass, field
from enum import StrEnum


class StageStatus(StrEnum):
    DONE = "done"
    PARTIAL = "partial"
    UNSUPPORTED = "unsupported"
    PERMISSION_DENIED = "permission_denied"
    CANCELLED = "cancelled"
    TIMEOUT = "timeout"
    FAILED = "failed"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class StageRequest:
    session_id: str
    stage_id: str
    target_ids: tuple[str, ...]


@dataclass(frozen=True)
class StageScenario:
    probe: str = "supported"
    ready: bool = True
    action: str = "done"
    mutated: bool = True
    result_present: bool = True
    session_id: str | None = None


@dataclass
class StageResult:
    status: StageStatus
    mutated: bool
    terminal: bool
    reason: str
    events: list[str]
    mutator_calls: list[tuple[str, ...]]


@dataclass
class ContractAdapter:
    events: list[str] = field(default_factory=list)
    mutator_calls: list[tuple[str, ...]] = field(default_factory=list)

    def _event(self, value: str) -> None:
        self.events.append(value)

    def execute(self, request: StageRequest, scenario: StageScenario) -> StageResult:
        start = len(self.events)
        self._event("probe.start")
        if not request.session_id or scenario.session_id not in (None, request.session_id):
            self._event("probe.wrong-session")
            return self._result(StageStatus.UNKNOWN, False, False, "wrong_session", start)
        if scenario.probe == "denied":
            self._event("probe.permission-denied")
            return self._result(StageStatus.PERMISSION_DENIED, False, True, "permission_denied", start)
        if scenario.probe == "unsupported":
            self._event("probe.unsupported")
            return self._result(StageStatus.UNSUPPORTED, False, True, "unsupported", start)
        if scenario.probe != "supported":
            self._event("probe.failed")
            return self._result(StageStatus.FAILED, False, True, "probe_failed", start)

        self._event("ready.wait")
        if not scenario.ready:
            self._event("ready.missing")
            return self._result(StageStatus.UNKNOWN, False, False, "ready_missing", start)

        self._event("action.start")
        if scenario.action == "cancelled":
            self._event("action.cancelled")
            return self._result(StageStatus.CANCELLED, False, True, "cancelled_before_mutation", start)
        if scenario.action == "timeout":
            self._event("action.timeout")
            return self._result(StageStatus.TIMEOUT, False, False, "timeout_unknown_terminal", start)
        if scenario.action not in {"done", "partial", "failed"}:
            self._event("action.failed")
            return self._result(StageStatus.FAILED, False, True, "action_failed", start)

        if scenario.mutated:
            self.mutator_calls.append(request.target_ids)
            self._event("action.mutated")
        if not scenario.result_present:
            self._event("result.missing")
            status = StageStatus.UNKNOWN if scenario.mutated else StageStatus.FAILED
            return self._result(status, scenario.mutated, not scenario.mutated, "result_missing_after_action", start)

        self._event("result.present")
        status = StageStatus.PARTIAL if scenario.action == "partial" else StageStatus.DONE
        self._event("stage.terminal")
        return self._result(status, scenario.mutated, True, status.value, start)

    def _result(self, status: StageStatus, mutated: bool, terminal: bool, reason: str, start: int) -> StageResult:
        return StageResult(status, mutated, terminal, reason, self.events[start:], list(self.mutator_calls))
