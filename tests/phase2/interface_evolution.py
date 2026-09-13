"""Offline contract for safe worker/backend interface evolution.

The production adapters may use a richer wire format, but this model keeps
the acceptance boundary explicit: optional metadata can be ignored, semantic
changes and missing required capabilities fail before mutation, and an
unsupported stage is reported independently from another usable stage.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class InterfaceError(ValueError):
    """The proposed interface change cannot be safely negotiated."""


class NegotiationStatus(StrEnum):
    ACCEPT = "accept"
    ACCEPT_WITH_IGNORED_OPTIONAL = "accept_with_ignored_optional"
    REJECT_VERSION = "reject_version"
    REJECT_REQUIRED_FIELD = "reject_required_field"
    REJECT_SEMANTIC_CHANGE = "reject_semantic_change"
    REJECT_CAPABILITY = "reject_capability"


@dataclass(frozen=True)
class InterfaceSpec:
    major: int
    minor: int
    required_fields: frozenset[str]
    optional_fields: frozenset[str]
    semantic_fields: frozenset[str]
    capabilities: frozenset[str]

    def __post_init__(self) -> None:
        if self.major < 1 or self.minor < 0:
            raise InterfaceError("interface version must be positive")
        if self.required_fields & self.optional_fields:
            raise InterfaceError("a field cannot be required and optional")
        if self.semantic_fields - (self.required_fields | self.optional_fields):
            raise InterfaceError("semantic fields must be declared fields")


@dataclass(frozen=True)
class Negotiation:
    status: NegotiationStatus
    ignored_optional: frozenset[str] = frozenset()
    shared_capabilities: frozenset[str] = frozenset()
    reason: str = ""


def negotiate(local: InterfaceSpec, peer: InterfaceSpec) -> Negotiation:
    """Negotiate before any mutator call.

    A major-version mismatch is never silently downgraded. A peer may add
    optional non-semantic metadata, but an unknown semantic field is a hard
    stop. Capabilities are intersected only after the structural checks pass.
    """
    if local.major != peer.major:
        return Negotiation(NegotiationStatus.REJECT_VERSION, reason="major_version_mismatch")
    missing = peer.required_fields - (local.required_fields | local.optional_fields)
    if missing:
        return Negotiation(NegotiationStatus.REJECT_REQUIRED_FIELD, reason=f"missing_required:{','.join(sorted(missing))}")
    unknown_semantic = peer.semantic_fields - (local.required_fields | local.optional_fields)
    if unknown_semantic:
        return Negotiation(NegotiationStatus.REJECT_SEMANTIC_CHANGE, reason="unknown_semantic_field")
    ignored = peer.optional_fields - (local.required_fields | local.optional_fields)
    shared = local.capabilities & peer.capabilities
    if peer.capabilities - local.capabilities:
        # A capability may be absent only when the peer does not require it;
        # the caller must inspect the shared set before selecting a stage.
        status = NegotiationStatus.ACCEPT_WITH_IGNORED_OPTIONAL if ignored else NegotiationStatus.ACCEPT
        return Negotiation(status, frozenset(ignored), frozenset(shared), "capability_subset")
    status = NegotiationStatus.ACCEPT_WITH_IGNORED_OPTIONAL if ignored else NegotiationStatus.ACCEPT
    return Negotiation(status, frozenset(ignored), frozenset(shared), "compatible")


class StageStatus(StrEnum):
    READY = "ready"
    UNSUPPORTED = "unsupported"
    REJECTED = "rejected"


@dataclass(frozen=True)
class StageCapability:
    stage_id: str
    required_capabilities: frozenset[str]


def stage_readiness(
    negotiation: Negotiation,
    stage: StageCapability,
) -> StageStatus:
    """Return a preflight status without invoking a mutator."""
    if negotiation.status not in (
        NegotiationStatus.ACCEPT,
        NegotiationStatus.ACCEPT_WITH_IGNORED_OPTIONAL,
    ):
        return StageStatus.REJECTED
    if not stage.required_capabilities <= negotiation.shared_capabilities:
        return StageStatus.UNSUPPORTED
    return StageStatus.READY
