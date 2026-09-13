import unittest

try:
    from .plan_coverage import (
        extract_checkpoint_task_ids,
        extract_plan_task_ids,
        missing_task_ids,
    )
except ImportError:  # unittest discover -s tests/phase2
    from plan_coverage import (
        extract_checkpoint_task_ids,
        extract_plan_task_ids,
        missing_task_ids,
    )


class PlanCoverageTests(unittest.TestCase):
    def test_extracts_major_and_decimal_task_ids(self):
        text = "### G00 — inventory\n### O4.8 — benchmark\n### H4.2 — handoff"
        self.assertEqual(extract_plan_task_ids(text), {"G00", "O4.8", "H4.2"})

    def test_ignores_numbered_non_task_headings(self):
        text = "### 1.1 context\n### O0.1 — baseline"
        self.assertEqual(extract_plan_task_ids(text), {"O0.1"})

    def test_extracts_checkpoint_table_ids(self):
        text = "| G00 | PASS |\n| O4.8 | PARTIAL |\n| H4.2 | BLOCKED |"
        self.assertEqual(extract_checkpoint_task_ids(text), {"G00", "O4.8", "H4.2"})

    def test_missing_ids_are_explicit(self):
        plan = "### G00 — inventory\n### O1.1 — selection\n### O7.8 — handoff"
        checkpoint = "| G00 | PASS |\n| O1.1 | PARTIAL |"
        self.assertEqual(missing_task_ids(plan, checkpoint), {"O7.8"})

    def test_duplicate_headings_collapse(self):
        self.assertEqual(extract_plan_task_ids("### O1.1 — a\n### O1.1 — b"), {"O1.1"})

    def test_empty_inputs_are_safe(self):
        self.assertEqual(missing_task_ids("", ""), frozenset())


if __name__ == "__main__":
    unittest.main()
