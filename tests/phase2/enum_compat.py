"""Small stdlib compatibility shim for the Python versions in CI.

``enum.StrEnum`` was added in Python 3.11, while the Phase 2 Linux matrix
still includes Ubuntu 22.04 with Python 3.10. Keep the same string-facing
semantics on both versions without adding a runtime dependency.
"""
from __future__ import annotations

from enum import Enum

try:
    from enum import StrEnum  # type: ignore[attr-defined]
except ImportError:
    class StrEnum(str, Enum):
        """Python 3.10-compatible subset of stdlib ``StrEnum``."""

        def __str__(self) -> str:
            return self.value
