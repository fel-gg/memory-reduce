"""Offline O3 stage inventory/ablation contract; no OS mutator is called."""
from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class StageContractError(ValueError):
    pass


@dataclass(frozen=True)
class StageSpec:
    stage_id: str
    capability: str
    physical_endpoint: str
    global_stage: bool = False
    prerequisites: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        if not self.stage_id or not self.capability or not self.physical_endpoint:
            raise StageContractError("stage identity, capability, and endpoint are required")
        if len(set(self.prerequisites)) != len(self.prerequisites):
            raise StageContractError("duplicate prerequisite")


@dataclass(frozen=True)
class StageInventory:
    stages: tuple[StageSpec, ...]

    def __post_init__(self) -> None:
        ids = [stage.stage_id for stage in self.stages]
        if not self.stages or len(set(ids)) != len(ids):
            raise StageContractError("stage inventory must contain unique stages")
        known = set(ids)
        if any(set(stage.prerequisites) - known for stage in self.stages):
            raise StageContractError("stage prerequisite is not in inventory")

    def get(self, stage_id: str) -> StageSpec:
        for stage in self.stages:
            if stage.stage_id == stage_id:
                return stage
        raise StageContractError(f"unknown stage: {stage_id}")


@dataclass(frozen=True)
class AblationArm:
    arm_id: str
    enabled_stage_ids: tuple[str, ...]


def validate_ablation(inventory: StageInventory, arm: AblationArm, *, baseline: AblationArm) -> None:
    """Require a one-stage difference and preserve prerequisite ordering."""
    if not arm.arm_id or len(set(arm.enabled_stage_ids)) != len(arm.enabled_stage_ids):
        raise StageContractError("ablation arm identity/stage list is invalid")
    enabled = set(arm.enabled_stage_ids)
    baseline_enabled = set(baseline.enabled_stage_ids)
    if enabled - {stage.stage_id for stage in inventory.stages}:
        raise StageContractError("ablation enables an unknown stage")
    if arm.arm_id == baseline.arm_id:
        if enabled != baseline_enabled:
            raise StageContractError("baseline arm changed its stage set")
    elif len(enabled ^ baseline_enabled) != 1:
        raise StageContractError("ablation must differ by exactly one stage")
    for stage_id in enabled:
        stage = inventory.get(stage_id)
        if not set(stage.prerequisites) <= enabled:
            raise StageContractError(f"stage prerequisite disabled: {stage_id}")


def stage_invocations(inventory: StageInventory, enabled_stage_ids: tuple[str, ...]) -> tuple[str, ...]:
    """Return the invocation order and reject duplicate global-stage execution."""
    enabled = set(enabled_stage_ids)
    if len(enabled) != len(enabled_stage_ids):
        raise StageContractError("duplicate stage invocation")
    ordered: list[str] = []
    for stage in inventory.stages:
        if stage.stage_id in enabled:
            if not set(stage.prerequisites) <= enabled:
                raise StageContractError(f"stage prerequisite disabled: {stage.stage_id}")
            ordered.append(stage.stage_id)
    return tuple(ordered)


@dataclass(frozen=True)
class CacheObservation:
    before_policy: str
    after_policy: str | None
    status: str


def validate_cache_postcondition(observation: CacheObservation) -> str:
    if observation.status not in {"success", "denied", "unsupported", "failed"}:
        raise StageContractError("unknown cache status")
    if observation.status == "success" and observation.after_policy is None:
        return "unverifiable"
    if observation.after_policy is not None and observation.after_policy != observation.before_policy:
        raise StageContractError("cache policy changed permanently")
    return "verified" if observation.after_policy == observation.before_policy else "unavailable"


class BenefitStatus(StrEnum):
    KEEP = "keep"
    NO_CHANGE = "evaluated_no_change"
    INCONCLUSIVE = "inconclusive"


@dataclass(frozen=True)
class StageMeasurement:
    stage_id: str
    endpoint: str
    retained_gain_bytes: int | None
    cost_ms: float | None


def select_stage_measurements(measurements: tuple[StageMeasurement, ...], min_gain: int, max_cost_ms: float) -> dict[str, BenefitStatus]:
    if min_gain < 0 or max_cost_ms < 0:
        raise StageContractError("selection thresholds must be non-negative")
    result: dict[str, BenefitStatus] = {}
    endpoints: dict[str, StageMeasurement] = {}
    for item in measurements:
        if not item.stage_id or not item.endpoint or item.stage_id in result:
            raise StageContractError("duplicate or empty stage measurement")
        if item.retained_gain_bytes is None or item.cost_ms is None:
            result[item.stage_id] = BenefitStatus.INCONCLUSIVE
            continue
        if item.retained_gain_bytes < min_gain or item.cost_ms > max_cost_ms:
            result[item.stage_id] = BenefitStatus.NO_CHANGE
            continue
        prior = endpoints.get(item.endpoint)
        if prior is not None and prior.retained_gain_bytes is not None:
            # Two stages reaching the same endpoint cannot both claim the full
            # physical delta; keep the first measured attribution explicit.
            result[item.stage_id] = BenefitStatus.NO_CHANGE
            continue
        endpoints[item.endpoint] = item
        result[item.stage_id] = BenefitStatus.KEEP
    return result
