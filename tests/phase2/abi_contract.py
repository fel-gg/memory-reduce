"""Pure ABI and checked-arithmetic helpers for the Phase 2 boundary.

The production adapters still own their platform calls.  These helpers make
the values crossing that boundary explicit and reject an address, length,
count, or signed delta before a native call can be attempted.
"""
from __future__ import annotations

from dataclasses import dataclass


class AbiError(ValueError):
    """A value cannot be represented by the selected ABI contract."""


UINT32_MAX = (1 << 32) - 1
UINT64_MAX = (1 << 64) - 1
INT64_MIN = -(1 << 63)
INT64_MAX = (1 << 63) - 1


@dataclass(frozen=True)
class AbiContract:
    name: str
    pointer_bits: int
    size_t_bits: int
    ssize_t_bits: int
    endian: str = "little"

    @property
    def pointer_max(self) -> int:
        return (1 << self.pointer_bits) - 1

    @property
    def size_t_max(self) -> int:
        return (1 << self.size_t_bits) - 1

    @property
    def ssize_t_min(self) -> int:
        return -(1 << (self.ssize_t_bits - 1))

    @property
    def ssize_t_max(self) -> int:
        return (1 << (self.ssize_t_bits - 1)) - 1


WINDOWS_X86 = AbiContract("windows-x86", 32, 32, 32)
WINDOWS_X64 = AbiContract("windows-x64", 64, 64, 64)
LINUX_X86_64 = AbiContract("linux-x86_64", 64, 64, 64)


def contract_for(name: str) -> AbiContract:
    contracts = {
        WINDOWS_X86.name: WINDOWS_X86,
        WINDOWS_X64.name: WINDOWS_X64,
        LINUX_X86_64.name: LINUX_X86_64,
    }
    try:
        return contracts[name]
    except KeyError as error:
        raise AbiError(f"unsupported architecture contract: {name}") from error


def checked_add(value: int, length: int, maximum: int) -> int:
    """Return value+length only when both form a valid bounded range."""
    if value < 0 or length < 0 or maximum < 0:
        raise AbiError("range operands must be non-negative")
    if value > maximum or length > maximum or value > maximum - length:
        raise AbiError("range addition overflows ABI width")
    return value + length


def validate_address_range(address: int, length: int, contract: AbiContract) -> tuple[int, int]:
    """Validate a half-open [address, address+length) native range."""
    if not isinstance(address, int) or not isinstance(length, int):
        raise AbiError("address and length must be integers")
    end = checked_add(address, length, contract.pointer_max)
    if length == 0:
        raise AbiError("zero-length native range is not actionable")
    return address, end


def validate_count(count: int, maximum: int, *, label: str = "count") -> int:
    if not isinstance(count, int) or count < 0 or count > maximum:
        raise AbiError(f"{label} does not fit its declared bound")
    return count


def signed_delta(before: int, after: int) -> int:
    """Compute before-after without silently wrapping a signed telemetry field."""
    if not 0 <= before <= UINT64_MAX or not 0 <= after <= UINT64_MAX:
        raise AbiError("resident values must fit unsigned 64-bit")
    delta = before - after
    if delta < INT64_MIN or delta > INT64_MAX:
        raise AbiError("resident delta does not fit signed 64-bit")
    return delta


def validate_page_size(page_size: int) -> int:
    if not isinstance(page_size, int) or page_size < 1 or page_size > (1 << 20):
        raise AbiError("runtime page size is outside the supported bound")
    if page_size & (page_size - 1):
        raise AbiError("runtime page size must be a power of two")
    return page_size


def page_aligned_range(address: int, length: int, page_size: int, contract: AbiContract) -> tuple[int, int]:
    validate_page_size(page_size)
    start, end = validate_address_range(address, length, contract)
    if start % page_size or end % page_size:
        raise AbiError("native range is not page aligned")
    return start, end
