"""Offline frozen-profile and confirmation contract for O6.1/O6.5/O6.6."""
from __future__ import annotations

from dataclasses import dataclass
try:
    from .enum_compat import StrEnum
except ImportError:
    from enum_compat import StrEnum


class ProfileContractError(ValueError):
    pass


@dataclass(frozen=True)
class ProfileParameters:
    min_process_mb: int
    batch_bytes: int
    batch_iovecs: int
    group_size: int
    recovery_passes: int

    def __post_init__(self) -> None:
        if not 0 <= self.min_process_mb <= 4096:
            raise ProfileContractError("minimum process size is out of range")
        if not 4096 <= self.batch_bytes <= 64 * 1024 * 1024:
            raise ProfileContractError("batch bytes are out of range")
        if not 1 <= self.batch_iovecs <= 1024 or not 1 <= self.group_size <= 1024:
            raise ProfileContractError("batch/group count is out of range")
        if not 0 <= self.recovery_passes <= 1:
            raise ProfileContractError("recovery must be bounded to one pass")


@dataclass(frozen=True)
class FrozenProfile:
    profile_id: str
    revision: str
    artifact_sha256: str
    parameters: ProfileParameters

    def __post_init__(self) -> None:
        if not self.profile_id or not self.revision:
            raise ProfileContractError("profile identity and revision are required")
        if len(self.artifact_sha256) != 64 or any(char not in "0123456789abcdefABCDEF" for char in self.artifact_sha256):
            raise ProfileContractError("artifact hash must be SHA-256")


@dataclass(frozen=True)
class ExperimentRecord:
    experiment_id: str
    profile_revision: str
    seed: int
    holdout: bool
    mandatory_metrics: frozenset[str]
    raw_digest: str

    def __post_init__(self) -> None:
        if not self.experiment_id or not self.profile_revision or self.seed < 0:
            raise ProfileContractError("experiment identity/seed is invalid")
        if not self.holdout:
            raise ProfileContractError("confirmation record must use a holdout seed")
        if not self.mandatory_metrics:
            raise ProfileContractError("mandatory metrics are required")
        if len(self.raw_digest) != 64:
            raise ProfileContractError("raw evidence digest is required")


class IntegrationStatus(StrEnum):
    ACCEPT = "accept"
    REJECT = "reject"
    INCONCLUSIVE = "inconclusive"


def classify_confirmation(
    *,
    gain_delta_bytes: int | None,
    cost_within_budget: bool | None,
    record: ExperimentRecord,
    expected_revision: str,
    minimum_gain_bytes: int,
) -> IntegrationStatus:
    if record.profile_revision != expected_revision or minimum_gain_bytes < 0:
        return IntegrationStatus.REJECT
    if gain_delta_bytes is None or cost_within_budget is None:
        return IntegrationStatus.INCONCLUSIVE
    if not cost_within_budget:
        return IntegrationStatus.REJECT
    return IntegrationStatus.ACCEPT if gain_delta_bytes >= minimum_gain_bytes else IntegrationStatus.INCONCLUSIVE


def can_integrate(status: IntegrationStatus, *, preserve_user_overrides: bool) -> bool:
    return status is IntegrationStatus.ACCEPT and preserve_user_overrides
