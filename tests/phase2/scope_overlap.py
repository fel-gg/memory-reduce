"""Pure scope-membership and overlap ledger for Linux reclaim planning.

The planner is deliberately conservative: unknown membership, shared charge,
or a protected descendant never becomes an eligible full-scope mutation.  This
module is a contract/fixture layer; it does not read or write cgroups.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class ScopeStatus(StrEnum):
    ELIGIBLE = "eligible"
    PROTECTED = "protected"
    EXCLUDED = "excluded"
    OVERLAP = "overlap"
    UNKNOWN = "unknown"
    OUTSIDE = "outside"


class ScopePlanError(ValueError):
    pass


@dataclass(frozen=True)
class MemberIdentity:
    pid: int
    birth: str
    cgroup_path: str | None
    protected: bool = False
    excluded: bool = False
    shared_charge_keys: tuple[str, ...] = ()


@dataclass(frozen=True)
class ScopeDisposition:
    identity: tuple[int, str]
    status: ScopeStatus
    reason: str
    overlap_keys: tuple[str, ...] = ()


def _inside_scope(path: str | None, scope: str) -> bool:
    if not path or not scope or not scope.startswith("/"):
        return False
    normalized_scope = scope.rstrip("/") or "/"
    normalized_path = path.rstrip("/") or "/"
    return normalized_path == normalized_scope or normalized_path.startswith(normalized_scope + "/")


def validate_members(members: tuple[MemberIdentity, ...]) -> None:
    seen: set[tuple[int, str]] = set()
    for member in members:
        if member.pid <= 0 or not member.birth:
            raise ScopePlanError("member identity requires positive pid and birth")
        identity = (member.pid, member.birth)
        if identity in seen:
            raise ScopePlanError("duplicate pid/birth identity")
        seen.add(identity)
        if any(not key for key in member.shared_charge_keys):
            raise ScopePlanError("shared charge keys must be non-empty")


def classify_members(scope: str, members: tuple[MemberIdentity, ...]) -> tuple[ScopeDisposition, ...]:
    if not scope.startswith("/"):
        raise ScopePlanError("scope must be an absolute cgroup path")
    validate_members(members)
    key_counts: dict[str, int] = {}
    for member in members:
        if _inside_scope(member.cgroup_path, scope):
            for key in member.shared_charge_keys:
                key_counts[key] = key_counts.get(key, 0) + 1
    dispositions: list[ScopeDisposition] = []
    for member in members:
        identity = (member.pid, member.birth)
        if member.cgroup_path is None:
            dispositions.append(ScopeDisposition(identity, ScopeStatus.UNKNOWN, "membership_unreadable"))
            continue
        if not _inside_scope(member.cgroup_path, scope):
            dispositions.append(ScopeDisposition(identity, ScopeStatus.OUTSIDE, "outside_scope"))
            continue
        overlaps = tuple(sorted(key for key in member.shared_charge_keys if key_counts[key] > 1))
        if member.protected:
            dispositions.append(ScopeDisposition(identity, ScopeStatus.PROTECTED, "protected_member", overlaps))
        elif member.excluded:
            dispositions.append(ScopeDisposition(identity, ScopeStatus.EXCLUDED, "user_exclusion", overlaps))
        elif overlaps:
            dispositions.append(ScopeDisposition(identity, ScopeStatus.OVERLAP, "shared_charge", overlaps))
        else:
            dispositions.append(ScopeDisposition(identity, ScopeStatus.ELIGIBLE, "eligible", ()))
    return tuple(dispositions)


def full_scope_safe(dispositions: tuple[ScopeDisposition, ...]) -> bool:
    """Full-scope mutation is safe only when every in-scope member is eligible."""
    return bool(dispositions) and all(
        item.status in {ScopeStatus.ELIGIBLE, ScopeStatus.OUTSIDE} for item in dispositions
    )
