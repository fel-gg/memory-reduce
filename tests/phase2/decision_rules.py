"""Explicit, data-driven screening classifier for Phase 2 candidates."""
from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class Decision(StrEnum):
    ACCEPT = "accept"
    REJECT_COST = "reject_cost"
    INCONCLUSIVE = "inconclusive"
    INVALID = "invalid"


@dataclass(frozen=True)
class DecisionCriteria:
    minimum_useful_gain_bytes: int
    noise_band_bytes: int
    max_latency_regression_ms: float
    max_fault_regression: int
    max_io_regression_bytes: int

    def __post_init__(self) -> None:
        if self.minimum_useful_gain_bytes < 0 or self.noise_band_bytes < 0:
            raise ValueError("gain/noise thresholds must be non-negative")
        if self.max_latency_regression_ms < 0 or self.max_fault_regression < 0 or self.max_io_regression_bytes < 0:
            raise ValueError("cost budgets must be non-negative")


@dataclass(frozen=True)
class ArmObservation:
    retained_gain_bytes: int | None
    latency_ms: float | None
    faults: int | None
    io_bytes: int | None


def classify(
    baseline: ArmObservation,
    candidate: ArmObservation,
    noop: ArmObservation,
    criteria: DecisionCriteria,
) -> Decision:
    """Classify one matched observation; missing mandatory metrics are invalid."""
    observations = (baseline, candidate, noop)
    if any(value is None for arm in observations for value in (arm.retained_gain_bytes, arm.latency_ms, arm.faults, arm.io_bytes)):
        return Decision.INVALID
    assert baseline.retained_gain_bytes is not None and candidate.retained_gain_bytes is not None and noop.retained_gain_bytes is not None
    assert baseline.latency_ms is not None and candidate.latency_ms is not None
    assert baseline.faults is not None and candidate.faults is not None
    assert baseline.io_bytes is not None and candidate.io_bytes is not None
    benefit = candidate.retained_gain_bytes - baseline.retained_gain_bytes
    cost_latency = candidate.latency_ms - baseline.latency_ms
    cost_faults = candidate.faults - baseline.faults
    cost_io = candidate.io_bytes - baseline.io_bytes
    if (cost_latency > criteria.max_latency_regression_ms or
            cost_faults > criteria.max_fault_regression or
            cost_io > criteria.max_io_regression_bytes):
        return Decision.REJECT_COST
    if benefit < criteria.minimum_useful_gain_bytes:
        return Decision.INCONCLUSIVE
    if abs(benefit - noop.retained_gain_bytes) <= criteria.noise_band_bytes:
        return Decision.INCONCLUSIVE
    return Decision.ACCEPT
