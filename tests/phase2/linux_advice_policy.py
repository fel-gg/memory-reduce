"""Conservative contract for O4.9/O4.10 advice strategy experiments."""
from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class AdviceKind(StrEnum):
    PAGEOUT = "pageout"
    COLD = "cold"


class AdvicePolicyError(ValueError):
    pass


@dataclass(frozen=True)
class AdviceResult:
    kind: AdviceKind
    status: str
    requested_bytes: int
    advised_bytes: int
    observed_resident_delta: int | None
    identity_unchanged: bool
    capability: str


@dataclass(frozen=True)
class StrategyResult:
    strategy: str
    released_bytes_credit: int
    status: str
    reason: str


def evaluate_advice(result: AdviceResult) -> StrategyResult:
    if result.requested_bytes <= 0 or result.advised_bytes < 0 or result.advised_bytes > result.requested_bytes:
        raise AdvicePolicyError("advice byte accounting is outside request")
    if not result.identity_unchanged:
        return StrategyResult(result.kind.value, 0, "deferred", "identity_changed")
    if result.kind is AdviceKind.COLD:
        # MADV_COLD is a hint; the kernel can leave pages resident. It never
        # proves released RAM even when the observed delta is negative.
        return StrategyResult("cold", 0, result.status, "hint_only_no_release_credit")
    if result.capability != "usable":
        return StrategyResult("pageout", 0, "unsupported", "pageout_capability_unusable")
    if result.status not in {"complete", "partial", "zero_progress"}:
        return StrategyResult("pageout", 0, result.status, "pageout_not_completed")
    return StrategyResult("pageout", result.advised_bytes, result.status, "advice_coverage_only")


def compare_strategies(cold: AdviceResult, pageout: AdviceResult) -> tuple[StrategyResult, StrategyResult]:
    if cold.requested_bytes != pageout.requested_bytes:
        raise AdvicePolicyError("strategy comparison changed requested range")
    return evaluate_advice(cold), evaluate_advice(pageout)
