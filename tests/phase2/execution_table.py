"""Test-only target table and bounded execution-group contract for O2.3/O2.4."""
from __future__ import annotations

from dataclasses import dataclass
try:
    from .enum_compat import StrEnum
except ImportError:
    from enum_compat import StrEnum


class ExecutionTableError(ValueError):
    pass


class TargetDisposition(StrEnum):
    ELIGIBLE = "eligible"
    ATTEMPTED = "attempted"
    DEFERRED = "deferred"
    UNAVAILABLE = "unavailable"


@dataclass(frozen=True)
class TargetRecord:
    identity: str
    snapshot_id: str
    query_bytes: int

    def __post_init__(self) -> None:
        if not self.identity or not self.snapshot_id:
            raise ExecutionTableError("target identity and snapshot are required")
        if self.query_bytes < 0:
            raise ExecutionTableError("query bytes cannot be negative")


@dataclass(frozen=True)
class TargetOutcome:
    identity: str
    disposition: TargetDisposition
    mutated: bool
    reason: str


@dataclass(frozen=True)
class TargetTable:
    session_id: str
    snapshot_id: str
    records: tuple[TargetRecord, ...]
    max_open_handles: int = 32

    def __post_init__(self) -> None:
        if not self.session_id or not self.snapshot_id:
            raise ExecutionTableError("session and snapshot are required")
        if not self.records:
            raise ExecutionTableError("target table cannot be empty")
        if self.max_open_handles <= 0:
            raise ExecutionTableError("handle quota must be positive")
        if any(record.snapshot_id != self.snapshot_id for record in self.records):
            raise ExecutionTableError("record belongs to a different snapshot")
        identities = [record.identity for record in self.records]
        if len(set(identities)) != len(identities):
            raise ExecutionTableError("duplicate target identity")

    def record(self, identity: str) -> TargetRecord:
        for record in self.records:
            if record.identity == identity:
                return record
        raise ExecutionTableError(f"target is outside immutable snapshot: {identity}")


def group_targets(table: TargetTable, group_size: int) -> tuple[tuple[str, ...], ...]:
    """Chunk all planned targets without changing policy order or stopping early."""
    if group_size <= 0 or group_size > table.max_open_handles:
        raise ExecutionTableError("group size exceeds the handle quota")
    identities = tuple(record.identity for record in table.records)
    return tuple(identities[index:index + group_size] for index in range(0, len(identities), group_size))


def attempt_target(
    table: TargetTable,
    identity: str,
    *,
    live_identity: str | None,
    query_status: str,
    cancelled: bool = False,
    action_status: str = "success",
) -> TargetOutcome:
    """Revalidate one snapshot record immediately before mutation."""
    table.record(identity)
    if live_identity != identity:
        return TargetOutcome(identity, TargetDisposition.DEFERRED, False, "stale_identity")
    if query_status != "ok":
        return TargetOutcome(identity, TargetDisposition.UNAVAILABLE, False, f"query_{query_status}")
    if cancelled:
        return TargetOutcome(identity, TargetDisposition.DEFERRED, False, "cancelled_before_action")
    if action_status != "success":
        return TargetOutcome(identity, TargetDisposition.ATTEMPTED, False, f"action_{action_status}")
    return TargetOutcome(identity, TargetDisposition.ATTEMPTED, True, "mutated")


def bounded_progress(outcomes: tuple[TargetOutcome, ...], max_items: int) -> tuple[str, ...]:
    """Return a bounded UI payload while retaining the complete ledger elsewhere."""
    if max_items <= 0:
        raise ExecutionTableError("progress budget must be positive")
    lines = tuple(f"{outcome.identity}|{outcome.disposition.value}|{outcome.reason}" for outcome in outcomes)
    if len(lines) <= max_items:
        return lines
    return lines[:max_items - 1] + (f"summary|remaining={len(lines) - (max_items - 1)}",)
