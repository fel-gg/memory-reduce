"""Fairness validator for baseline/candidate/no-op benchmark arms."""
from __future__ import annotations

from dataclasses import dataclass


class TrialConfigError(ValueError):
    pass


@dataclass(frozen=True)
class TrialArm:
    label: str
    command: str
    workload: str
    seed: int
    warmup_seconds: float
    observers: tuple[float, ...]
    reset_id: str
    teardown_id: str
    timeout_seconds: float


@dataclass(frozen=True)
class TrialMatrix:
    arms: tuple[TrialArm, ...]

    def validate(self) -> None:
        required = {"baseline", "candidate", "noop"}
        labels = {arm.label for arm in self.arms}
        if labels != required or len(self.arms) != len(required):
            raise TrialConfigError("exactly baseline, candidate, and noop arms are required")
        if any(arm.seed < 0 or arm.warmup_seconds < 0 or arm.timeout_seconds <= 0 for arm in self.arms):
            raise TrialConfigError("seed/warmup/timeout values are invalid")
        if any(tuple(sorted(arm.observers)) != arm.observers or any(delay < 0 for delay in arm.observers) for arm in self.arms):
            raise TrialConfigError("observers must be sorted non-negative offsets")
        reference = next(arm for arm in self.arms if arm.label == "baseline")
        for arm in self.arms:
            if (arm.workload, arm.seed, arm.warmup_seconds, arm.observers,
                    arm.reset_id, arm.teardown_id, arm.timeout_seconds) != (
                    reference.workload, reference.seed, reference.warmup_seconds,
                    reference.observers, reference.reset_id, reference.teardown_id,
                    reference.timeout_seconds):
                raise TrialConfigError(f"arm setup differs from baseline: {arm.label}")
        for arm in self.arms:
            lowered = arm.command.lower().replace(" ", "")
            if arm.label in {"baseline", "candidate"} and lowered in {"sleep", "timeout", "start-sleep", "sleep.exe"}:
                raise TrialConfigError(f"placeholder sleep command is not a product arm: {arm.label}")
        if reference.command == next(arm for arm in self.arms if arm.label == "candidate").command:
            raise TrialConfigError("candidate must have a distinct assigned action")
