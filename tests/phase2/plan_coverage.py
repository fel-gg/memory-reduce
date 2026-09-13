"""Small parser for ensuring the checkpoint represents every Luna plan ID."""
from __future__ import annotations

import re


TASK_HEADING = re.compile(r"^### ([GHO]\d+(?:\.\d+)?)\s", re.MULTILINE)
TABLE_ID = re.compile(r"\|\s*([GHO]\d+(?:\.\d+)?)\s*\|")


def extract_plan_task_ids(plan_text: str) -> frozenset[str]:
    return frozenset(TASK_HEADING.findall(plan_text))


def extract_checkpoint_task_ids(checkpoint_text: str) -> frozenset[str]:
    return frozenset(TABLE_ID.findall(checkpoint_text))


def missing_task_ids(plan_text: str, checkpoint_text: str) -> frozenset[str]:
    return extract_plan_task_ids(plan_text) - extract_checkpoint_task_ids(checkpoint_text)
