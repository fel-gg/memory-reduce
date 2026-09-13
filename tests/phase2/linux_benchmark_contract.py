"""Offline contract for the Linux mapping/batch benchmark grid.

This module defines the data that a disposable Linux runner must emit.  It is
intentionally independent of a kernel syscall so Windows can validate case
coverage and accounting rules without pretending to have Linux evidence.
"""
from __future__ import annotations

from dataclasses import dataclass
try:
    from .enum_compat import StrEnum
except ImportError:
    from enum_compat import StrEnum


class MappingKind(StrEnum):
    CLEAN_FILE = "clean_file"
    DIRTY_FILE = "dirty_file"
    ANONYMOUS_NO_SWAP = "anonymous_no_swap"
    ANONYMOUS_SWAP = "anonymous_swap"
    SHARED = "shared"
    MIXED_COW = "mixed_cow"
    THP = "thp"
    SPARSE = "sparse"
    MANY_SMALL = "many_small"


class BenchmarkContractError(ValueError):
    pass


@dataclass(frozen=True)
class MappingCase:
    case_id: str
    kind: MappingKind
    page_size: int
    requested_bytes: int
    range_count: int
    swap_state: str
    same_range_key: str


@dataclass(frozen=True)
class MappingMeasurement:
    case_id: str
    requested_bytes: int
    advised_bytes: int
    observed_resident_before: int | None
    observed_resident_after: int | None
    parse_ms: float | None
    plan_ms: float | None
    ffi_ms: float | None
    kernel_ms: float | None
    integrity_ok: bool | None
    status: str


REQUIRED_KINDS = frozenset(MappingKind)


def validate_case(case: MappingCase) -> None:
    if not case.case_id or not case.same_range_key:
        raise BenchmarkContractError("case identity and same-range key are required")
    if case.page_size <= 0 or case.page_size & (case.page_size - 1):
        raise BenchmarkContractError("page_size must be a positive power of two")
    if case.requested_bytes <= 0 or case.requested_bytes % case.page_size:
        raise BenchmarkContractError("requested_bytes must be positive and page-aligned")
    if case.range_count <= 0:
        raise BenchmarkContractError("range_count must be positive")
    if not case.swap_state:
        raise BenchmarkContractError("swap_state is required, including no_swap")


def validate_measurement(case: MappingCase, measurement: MappingMeasurement) -> None:
    validate_case(case)
    if measurement.case_id != case.case_id:
        raise BenchmarkContractError("measurement case does not match fixture")
    if measurement.requested_bytes != case.requested_bytes:
        raise BenchmarkContractError("measurement changed requested range")
    if measurement.advised_bytes < 0 or measurement.advised_bytes > case.requested_bytes:
        raise BenchmarkContractError("advised_bytes is outside the requested range")
    for value in (
        measurement.observed_resident_before,
        measurement.observed_resident_after,
    ):
        if value is not None and value < 0:
            raise BenchmarkContractError("resident bytes cannot be negative")
    for value in (
        measurement.parse_ms,
        measurement.plan_ms,
        measurement.ffi_ms,
        measurement.kernel_ms,
    ):
        if value is not None and value < 0:
            raise BenchmarkContractError("timing values cannot be negative")
    if measurement.status == "complete" and (
        measurement.integrity_ok is not True
        or any(value is None for value in (measurement.parse_ms, measurement.plan_ms, measurement.ffi_ms, measurement.kernel_ms))
    ):
        raise BenchmarkContractError("complete measurement requires timing and integrity evidence")
    if measurement.status in {"failed", "unsupported", "denied", "unknown"} and measurement.integrity_ok is True:
        raise BenchmarkContractError("non-complete measurement cannot claim integrity success")


def validate_grid(cases: tuple[MappingCase, ...]) -> None:
    if not cases:
        raise BenchmarkContractError("benchmark grid cannot be empty")
    for case in cases:
        validate_case(case)
    ids = [case.case_id for case in cases]
    if len(ids) != len(set(ids)):
        raise BenchmarkContractError("case_id must be unique")
    kinds = {case.kind for case in cases}
    missing = REQUIRED_KINDS - kinds
    if missing:
        raise BenchmarkContractError("benchmark grid is missing: " + ",".join(sorted(missing)))


def same_range_comparison(left: MappingCase, right: MappingCase) -> bool:
    """Whether two cases are a valid same-range comparison pair."""
    return (
        left.same_range_key == right.same_range_key
        and left.page_size == right.page_size
        and left.requested_bytes == right.requested_bytes
        and left.range_count == right.range_count
    )
