import unittest

try:
    from .execution_table import (
        ExecutionTableError,
        TargetDisposition,
        TargetRecord,
        TargetTable,
        attempt_target,
        bounded_progress,
        group_targets,
    )
except ImportError:
    from execution_table import (
        ExecutionTableError,
        TargetDisposition,
        TargetRecord,
        TargetTable,
        attempt_target,
        bounded_progress,
        group_targets,
    )


class ExecutionTableTests(unittest.TestCase):
    def setUp(self):
        self.table = TargetTable(
            "session-1",
            "snapshot-1",
            tuple(TargetRecord(f"pid:{number}", "snapshot-1", number * 1024) for number in (10, 20, 30, 40, 50)),
            max_open_handles=3,
        )

    def test_snapshot_and_records_are_immutable(self):
        with self.assertRaises((AttributeError, TypeError)):
            self.table.snapshot_id = "other"  # type: ignore[misc]
        with self.assertRaises(ExecutionTableError):
            self.table.record("pid:999")

    def test_duplicate_or_cross_snapshot_records_are_rejected(self):
        with self.assertRaises(ExecutionTableError):
            TargetTable("s", "snap", (TargetRecord("a", "snap", 1), TargetRecord("a", "snap", 2)))
        with self.assertRaises(ExecutionTableError):
            TargetTable("s", "snap", (TargetRecord("a", "other", 1),))

    def test_grouping_visits_every_target_in_policy_order(self):
        self.assertEqual(group_targets(self.table, 2), (("pid:10", "pid:20"), ("pid:30", "pid:40"), ("pid:50",)))

    def test_group_size_respects_handle_quota(self):
        with self.assertRaises(ExecutionTableError):
            group_targets(self.table, 4)
        with self.assertRaises(ExecutionTableError):
            group_targets(self.table, 0)

    def test_stale_identity_is_deferred_without_mutation(self):
        result = attempt_target(self.table, "pid:10", live_identity="pid:10:reused", query_status="ok")
        self.assertEqual(result.disposition, TargetDisposition.DEFERRED)
        self.assertFalse(result.mutated)
        self.assertEqual(result.reason, "stale_identity")

    def test_query_denied_is_unavailable_without_mutation(self):
        result = attempt_target(self.table, "pid:20", live_identity="pid:20", query_status="denied")
        self.assertEqual(result.disposition, TargetDisposition.UNAVAILABLE)
        self.assertFalse(result.mutated)

    def test_cancel_before_action_does_not_mutate(self):
        result = attempt_target(self.table, "pid:30", live_identity="pid:30", query_status="ok", cancelled=True)
        self.assertEqual(result.disposition, TargetDisposition.DEFERRED)
        self.assertFalse(result.mutated)

    def test_action_failure_is_attempted_but_not_mutated(self):
        result = attempt_target(self.table, "pid:40", live_identity="pid:40", query_status="ok", action_status="timeout")
        self.assertEqual(result.disposition, TargetDisposition.ATTEMPTED)
        self.assertFalse(result.mutated)
        self.assertEqual(result.reason, "action_timeout")

    def test_success_is_recorded_as_one_mutation(self):
        result = attempt_target(self.table, "pid:50", live_identity="pid:50", query_status="ok")
        self.assertEqual(result.disposition, TargetDisposition.ATTEMPTED)
        self.assertTrue(result.mutated)

    def test_progress_payload_is_bounded_without_losing_ledger_outcomes(self):
        outcomes = tuple(
            attempt_target(self.table, record.identity, live_identity=record.identity, query_status="ok")
            for record in self.table.records
        )
        payload = bounded_progress(outcomes, 3)
        self.assertEqual(len(payload), 3)
        self.assertIn("remaining=3", payload[-1])
        self.assertEqual(len(outcomes), 5)

    def test_progress_budget_must_be_positive(self):
        with self.assertRaises(ExecutionTableError):
            bounded_progress((), 0)


if __name__ == "__main__":
    unittest.main()
