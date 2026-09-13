"""Deterministic, read-only scope/capability policy contract for O5.3/O5.4."""
from __future__ import annotations

from dataclasses import dataclass
try:
    from .enum_compat import StrEnum
except ImportError:
    from enum_compat import StrEnum


class CapabilityState(StrEnum):
    USABLE = "usable"
    UNSUPPORTED = "unsupported"
    DENIED = "denied"
    UNKNOWN = "unknown"


class ScopePolicyError(ValueError):
    pass


@dataclass(frozen=True)
class SwapSnapshot:
    host_available_bytes: int | None
    scope_max_bytes: int | None
    ancestor_max_bytes: int | None
    status: str = "known"


@dataclass(frozen=True)
class ScopeCapabilities:
    process: CapabilityState
    cgroup: CapabilityState
    cgroup_scope_safe: bool | None


@dataclass(frozen=True)
class PathDecision:
    path: str
    reason: str
    requires_experiment: bool = False


def effective_swap_allowance(snapshot: SwapSnapshot) -> tuple[int | None, str]:
    """Return the bounded allowance without treating unknown as unlimited."""
    values = (snapshot.host_available_bytes, snapshot.scope_max_bytes, snapshot.ancestor_max_bytes)
    if any(value is not None and value < 0 for value in values):
        raise ScopePolicyError("swap allowance cannot be negative")
    if snapshot.status != "known" or any(value is None for value in values):
        return None, "unknown_allowance"
    return min(values), "known_allowance"


def choose_reclaim_path(capabilities: ScopeCapabilities) -> PathDecision:
    """Choose only a path whose authorization/capability is explicit.

    When both paths are usable, selection remains an experiment decision; this
    function must not silently prefer cgroup and double-request the same domain.
    """
    cgroup = capabilities.cgroup
    if cgroup is CapabilityState.USABLE and capabilities.cgroup_scope_safe is not True:
        # A usable syscall against an unverified/unknown scope is not an
        # authorized cgroup path. Unknown remains deferred; false is denied.
        cgroup = (
            CapabilityState.DENIED
            if capabilities.cgroup_scope_safe is False
            else CapabilityState.UNKNOWN
        )
    if capabilities.process is CapabilityState.USABLE and cgroup is CapabilityState.USABLE:
        return PathDecision("experiment_required", "both_paths_usable", True)
    if capabilities.process is CapabilityState.USABLE:
        return PathDecision("targeted_process", "cgroup_unusable_or_unsafe")
    if cgroup is CapabilityState.USABLE and capabilities.process in {
        CapabilityState.DENIED,
        CapabilityState.UNSUPPORTED,
    }:
        return PathDecision("scoped_cgroup", "process_path_unusable")
    if CapabilityState.UNKNOWN in {capabilities.process, cgroup}:
        return PathDecision("deferred", "capability_or_scope_unknown")
    return PathDecision("unsupported", "no_authorized_path")
