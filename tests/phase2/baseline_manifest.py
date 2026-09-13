"""Reproducible, non-overwriting Phase 2 baseline manifest helper.

This test-only helper stages a named set of files into a fresh output
directory, records their hashes and basic environment facts, and verifies
that the staged baseline has not changed.  It never selects a product
baseline by itself; G03 still owns that decision.
"""
from __future__ import annotations

import hashlib
import json
import os
import platform
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path


class BaselineError(ValueError):
    """The baseline is missing, mutable, or otherwise not verifiable."""


@dataclass(frozen=True)
class BaselineInput:
    role: str
    path: Path


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def _safe_role(role: str) -> str:
    if not role or any(char not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-" for char in role):
        raise BaselineError(f"invalid baseline role: {role!r}")
    return role


def _record(role: str, path: Path) -> dict[str, object]:
    if not path.is_file():
        raise BaselineError(f"baseline input is missing: {path}")
    return {"role": role, "path": str(path.resolve()), "bytes": path.stat().st_size, "sha256": sha256_file(path)}


def create_baseline(output_dir: Path, inputs: tuple[BaselineInput, ...], *, source_commit: str, config_role: str = "config") -> Path:
    """Create a fresh staged baseline and return its manifest path."""
    output_dir = output_dir.resolve()
    if output_dir.exists():
        if any(output_dir.iterdir()):
            raise BaselineError(f"refusing to overwrite non-empty baseline: {output_dir}")
    else:
        output_dir.mkdir(parents=True)
    if not source_commit or any(char not in "0123456789abcdefABCDEF" for char in source_commit):
        raise BaselineError("source_commit must be a hexadecimal identity")
    if not inputs:
        raise BaselineError("baseline requires at least one input")
    roles = [_safe_role(item.role) for item in inputs]
    if len(set(roles)) != len(roles):
        raise BaselineError("baseline roles must be unique")
    if config_role not in roles:
        raise BaselineError("baseline must identify its test config")

    staged: list[dict[str, object]] = []
    for item, role in zip(inputs, roles):
        source = item.path.resolve()
        if not source.is_file():
            raise BaselineError(f"baseline input is missing: {source}")
        destination = output_dir / "files" / role
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            raise BaselineError(f"refusing to overwrite staged input: {destination}")
        shutil.copy2(source, destination)
        staged.append(_record(role, destination))

    manifest = {
        "schema_version": 1,
        "source_commit": source_commit.lower(),
        "config_role": config_role,
        "environment": {
            "python": sys.version,
            "platform": platform.platform(),
            "system": platform.system(),
            "release": platform.release(),
            "machine": platform.machine(),
            "processor": platform.processor() or "unknown",
            "ram_bytes": None,
            "swap": "unknown",
            "cgroup": "unknown",
        },
        "inputs": staged,
    }
    manifest_path = output_dir / "BASELINE-MANIFEST.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return manifest_path


def verify_baseline(manifest_path: Path) -> dict[str, object]:
    """Verify every staged input still has the recorded bytes and hash."""
    manifest_path = manifest_path.resolve()
    if not manifest_path.is_file():
        raise BaselineError(f"manifest is missing: {manifest_path}")
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        raise BaselineError("manifest is not valid JSON") from error
    if manifest.get("schema_version") != 1 or not isinstance(manifest.get("inputs"), list):
        raise BaselineError("unsupported baseline manifest")
    roles: set[str] = set()
    for item in manifest["inputs"]:
        if not isinstance(item, dict) or not all(key in item for key in ("role", "path", "bytes", "sha256")):
            raise BaselineError("malformed baseline input record")
        role = _safe_role(str(item["role"]))
        if role in roles:
            raise BaselineError("duplicate baseline role")
        roles.add(role)
        path = Path(str(item["path"]))
        if not path.is_file():
            raise BaselineError(f"staged baseline input is missing: {path}")
        if path.stat().st_size != int(item["bytes"]) or sha256_file(path) != str(item["sha256"]).upper():
            raise BaselineError(f"baseline input changed: {role}")
    if manifest.get("config_role") not in roles:
        raise BaselineError("config role is not present in baseline inputs")
    return manifest
