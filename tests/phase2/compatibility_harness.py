"""Strict, test-only compatibility parser for native worker protocol v2.

The production AutoIt parser remains the source of runtime behavior.  This
small independent model makes H0.3 boundary cases executable without
launching a mutator or changing a user's configuration.
"""
from __future__ import annotations

from dataclasses import dataclass

MAX_BYTES = 8 * 1024 * 1024
MAX_RECORDS = 16_384
AUTOIT_EXACT_MAX = 9_007_199_254_740_991
KNOWN_KEYS = {
    "protocol", "session", "terminal", "mutated", "exit_code", "trimmed",
    "resident_delta", "record_count", "measured", "unmeasured",
}
OPTIONAL_KEYS = {
    "strategy_revision", "stage_id", "scope_id", "batch_bytes", "batch_count", "last_errno",
}
RECORD_STATUSES = {"measured", "after_unknown", "identity_changed"}
TERMINAL_STATUSES = {"done", "partial"}


class ProtocolError(ValueError):
    """Input is not safe to commit to the execution ledger."""


@dataclass(frozen=True)
class Record:
    pid: int
    birth_hex: str
    before: int
    after: int
    faults: int
    status: str
    display_name: str


@dataclass(frozen=True)
class ParsedResult:
    protocol: int
    session: str
    terminal: str
    mutated: bool
    exit_code: int
    trimmed: int
    resident_delta: int
    records: tuple[Record, ...]
    measured: int
    unmeasured: int
    metadata: tuple[tuple[str, str], ...]


def _integer(value: str, name: str, minimum: int, maximum: int) -> int:
    if not value or (value.startswith("-") and not value[1:].isdigit()) or (not value.startswith("-") and not value.isdigit()):
        raise ProtocolError(f"invalid integer: {name}")
    parsed = int(value, 10)
    if parsed < minimum or parsed > maximum:
        raise ProtocolError(f"integer out of range: {name}")
    return parsed


def parse_result(payload: str | bytes, expected_session: str) -> ParsedResult:
    raw = payload if isinstance(payload, bytes) else payload.encode("utf-8")
    if len(raw) > MAX_BYTES:
        raise ProtocolError("payload exceeds 8 MiB")
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ProtocolError("payload is not UTF-8") from error
    if not expected_session:
        raise ProtocolError("expected session is required")

    fields: dict[str, str] = {}
    record_lines: list[str] = []
    for line in text.splitlines():
        if not line or "=" not in line:
            raise ProtocolError("truncated or malformed line")
        key, value = line.split("=", 1)
        if key == "record":
            record_lines.append(value)
            continue
        if key not in KNOWN_KEYS and key not in OPTIONAL_KEYS:
            raise ProtocolError(f"unknown metadata: {key}")
        if key in fields:
            raise ProtocolError(f"duplicate key: {key}")
        fields[key] = value

    required = set(KNOWN_KEYS)
    missing = sorted(required - fields.keys())
    if missing:
        raise ProtocolError("missing fields: " + ",".join(missing))
    if _integer(fields["protocol"], "protocol", 0, 2) != 2:
        raise ProtocolError("unsupported protocol")
    if fields["session"] != expected_session:
        raise ProtocolError("wrong session")
    if fields["terminal"] not in TERMINAL_STATUSES:
        raise ProtocolError("unknown terminal status")
    mutated = _integer(fields["mutated"], "mutated", 0, 1)
    exit_code = _integer(fields["exit_code"], "exit_code", -AUTOIT_EXACT_MAX, AUTOIT_EXACT_MAX)
    trimmed = _integer(fields["trimmed"], "trimmed", 0, AUTOIT_EXACT_MAX)
    resident_delta = _integer(fields["resident_delta"], "resident_delta", -AUTOIT_EXACT_MAX, AUTOIT_EXACT_MAX)
    declared_count = _integer(fields.get("record_count", str(len(record_lines))), "record_count", 0, MAX_RECORDS)
    if declared_count != len(record_lines):
        raise ProtocolError("record count mismatch")

    records: list[Record] = []
    identities: set[tuple[int, str]] = set()
    measured_count = 0
    for line in record_lines:
        parts = line.split("|", 6)
        if len(parts) != 7:
            raise ProtocolError("malformed record")
        pid = _integer(parts[0], "record.pid", 0, 0xFFFFFFFF)
        birth = parts[1]
        if len(birth) != 16 or any(char not in "0123456789abcdefABCDEF" for char in birth):
            raise ProtocolError("invalid record identity")
        birth = birth.upper()
        identity = (pid, birth)
        if identity in identities:
            raise ProtocolError("duplicate record identity")
        identities.add(identity)
        before = _integer(parts[2], "record.before", 0, AUTOIT_EXACT_MAX)
        after = _integer(parts[3], "record.after", 0, AUTOIT_EXACT_MAX)
        faults = _integer(parts[4], "record.faults", 0, AUTOIT_EXACT_MAX)
        if parts[5] not in RECORD_STATUSES or not parts[6] or any(ord(char) < 32 for char in parts[6]):
            raise ProtocolError("invalid record status or name")
        if parts[5] == "measured":
            measured_count += 1
        records.append(Record(pid, birth, before, after, faults, parts[5], parts[6]))

    measured = _integer(fields.get("measured", str(measured_count)), "measured", 0, MAX_RECORDS)
    unmeasured = _integer(fields.get("unmeasured", str(len(records) - measured_count)), "unmeasured", 0, MAX_RECORDS)
    if measured != measured_count or measured + unmeasured != len(records):
        raise ProtocolError("measured/unmeasured count mismatch")
    if mutated == 0 and any(record.status == "measured" for record in records):
        raise ProtocolError("measured record requires mutated=1")
    metadata = tuple(sorted((key, fields[key]) for key in OPTIONAL_KEYS if key in fields))
    return ParsedResult(2, expected_session, fields["terminal"], bool(mutated), exit_code,
                        trimmed, resident_delta, tuple(records), measured, unmeasured, metadata)
