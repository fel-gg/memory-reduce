"""Test-only parity contract for Normal/Aggressive/fallback execution arms.

The fixture deliberately models decisions, not a reclaim implementation.  It
lets the benchmark gate compare execution strategies without allowing a
fallback to silently broaden the target snapshot or turn an unsupported/denied
probe into a successful mutation.
"""
from __future__ import annotations

from dataclasses import dataclass
try:
    from .enum_compat import StrEnum
except ImportError:
    from enum_compat import StrEnum


class ExecutionProfile(StrEnum):
    NORMAL = "normal"
    AGGRESSIVE = "aggressive"
    FALLBACK = "fallback"


class ParityFixtureError(ValueError):
    pass


@dataclass(frozen=True)
class SelectionSnapshot:
    session_id: str
    selected_ids: tuple[str, ...]
    protected_ids: tuple[str, ...] = ()
    excluded_ids: tuple[str, ...] = ()

    def validate(self) -> None:
        if not self.session_id:
            raise ParityFixtureError("session_id is required")
        selected = set(self.selected_ids)
        protected = set(self.protected_ids)
        excluded = set(self.excluded_ids)
        if any(not value for value in selected | protected | excluded):
            raise ParityFixtureError("snapshot identities must be non-empty")
        if selected & protected or selected & excluded or protected & excluded:
            raise ParityFixtureError("selection/protection/exclusion sets overlap")


@dataclass(frozen=True)
class ProfileOutcome:
    profile: ExecutionProfile
    session_id: str
    attempted_ids: tuple[str, ...]
    mutated_ids: tuple[str, ...]
    status: str
    fallback_reason: str | None = None


def validate_profile_parity(
    snapshot: SelectionSnapshot,
    outcomes: tuple[ProfileOutcome, ...],
) -> None:
    """Validate that strategy changes preserve the same bounded target set."""
    snapshot.validate()
    if not outcomes:
        raise ParityFixtureError("at least one profile outcome is required")
    allowed = set(snapshot.selected_ids)
    for outcome in outcomes:
        if outcome.session_id != snapshot.session_id:
            raise ParityFixtureError("outcome session does not match snapshot")
        attempted = set(outcome.attempted_ids)
        mutated = set(outcome.mutated_ids)
        if not attempted <= allowed or not mutated <= attempted:
            raise ParityFixtureError("profile broadened or mutated outside snapshot")
        if outcome.profile is ExecutionProfile.FALLBACK:
            if outcome.status not in {"unsupported", "permission_denied", "partial"}:
                raise ParityFixtureError("fallback requires an explicit degraded status")
            if not outcome.fallback_reason:
                raise ParityFixtureError("fallback reason is required")
        elif outcome.fallback_reason is not None:
            raise ParityFixtureError("normal/aggressive profile cannot carry fallback reason")
        if outcome.status in {"unsupported", "permission_denied", "cancelled", "timeout"} and mutated:
            raise ParityFixtureError("non-success status must not report mutation")


def equivalent_target_snapshot(left: ProfileOutcome, right: ProfileOutcome) -> bool:
    """Return whether two profiles attempted the exact same target identities."""
    return left.session_id == right.session_id and left.attempted_ids == right.attempted_ids
