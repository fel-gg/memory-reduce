"""Immutable Phase 2 reclaim plan and conservative execution ledger.

This is a test-only contract model.  It deliberately does not call a
platform mutator; production adapters must map to it only after the Phase 1
gate and adapter acceptance are closed.
"""
from __future__ import annotations

from dataclasses import dataclass, field
try:
    from .enum_compat import StrEnum
except ImportError:
    from enum_compat import StrEnum


class PlanError(ValueError):
    """The request would violate the frozen session/plan contract."""


class LedgerStatus(StrEnum):
    ATTEMPTED = "attempted"
    DONE = "done"
    PARTIAL = "partial"
    DEFERRED = "deferred"
    UNKNOWN = "unknown"


@dataclass(frozen=True)
class StagePlan:
    stage_id: str
    target_ids: tuple[str, ...]
    capability: str

    def __post_init__(self) -> None:
        if not self.stage_id or not self.capability:
            raise PlanError("stage_id and capability are required")
        if not self.target_ids or any(not target for target in self.target_ids):
            raise PlanError("a stage must have non-empty target identities")
        if len(set(self.target_ids)) != len(self.target_ids):
            raise PlanError("duplicate target identity in stage")


@dataclass(frozen=True)
class ExecutionPlan:
    session_id: str
    profile_revision: str
    scope_id: str
    snapshot_identity: str
    stages: tuple[StagePlan, ...]
    capabilities: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        required = (self.session_id, self.profile_revision, self.scope_id, self.snapshot_identity)
        if any(not value for value in required):
            raise PlanError("session, profile, scope, and snapshot identity are required")
        if not self.stages:
            raise PlanError("execution plan must contain at least one stage")
        stage_ids = [stage.stage_id for stage in self.stages]
        if len(set(stage_ids)) != len(stage_ids):
            raise PlanError("duplicate stage identity in plan")
        if len(set(self.capabilities)) != len(self.capabilities):
            raise PlanError("duplicate capability in plan")

    def stage(self, stage_id: str) -> StagePlan:
        for stage in self.stages:
            if stage.stage_id == stage_id:
                return stage
        raise PlanError(f"stage is outside immutable plan: {stage_id}")


@dataclass(frozen=True)
class LedgerEntry:
    session_id: str
    stage_id: str
    status: LedgerStatus
    mutated: bool
    reason: str


@dataclass
class ExecutionLedger:
    """One entry per planned stage; terminal/unknown entries cannot replay."""

    plan: ExecutionPlan
    entries: dict[str, LedgerEntry] = field(default_factory=dict)

    def record(
        self,
        stage_id: str,
        status: LedgerStatus,
        *,
        mutated: bool,
        reason: str,
        session_id: str,
    ) -> LedgerEntry:
        stage = self.plan.stage(stage_id)
        if session_id != self.plan.session_id:
            raise PlanError("stage session does not match plan session")
        if not reason:
            raise PlanError("ledger reason is required")
        if stage_id in self.entries:
            raise PlanError(f"stage already recorded; replay is forbidden: {stage_id}")
        entry = LedgerEntry(session_id, stage.stage_id, status, bool(mutated), reason)
        self.entries[stage_id] = entry
        return entry

    def next_unrecorded(self) -> tuple[StagePlan, ...]:
        return tuple(stage for stage in self.plan.stages if stage.stage_id not in self.entries)
