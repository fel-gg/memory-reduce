import unittest

try:
    from .reclaim_plan import ExecutionLedger, ExecutionPlan, LedgerStatus, PlanError, StagePlan
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from reclaim_plan import ExecutionLedger, ExecutionPlan, LedgerStatus, PlanError, StagePlan


class ReclaimPlanTests(unittest.TestCase):
    def setUp(self):
        self.plan = ExecutionPlan(
            session_id="session-a",
            profile_revision="profile-1",
            scope_id="fixture-scope",
            snapshot_identity="snapshot-1",
            capabilities=("working_set", "pageout"),
            stages=(
                StagePlan("stage-a", ("target-a",), "working_set"),
                StagePlan("stage-b", ("target-b",), "pageout"),
            ),
        )

    def test_plan_is_frozen_and_stage_lookup_is_scoped(self):
        with self.assertRaises((AttributeError, TypeError)):
            self.plan.scope_id = "other"  # type: ignore[misc]
        self.assertEqual(self.plan.stage("stage-a").target_ids, ("target-a",))
        with self.assertRaises(PlanError):
            self.plan.stage("not-planned")

    def test_invalid_plan_rejects_duplicate_identities(self):
        with self.assertRaises(PlanError):
            StagePlan("stage-a", ("target-a", "target-a"), "working_set")
        with self.assertRaises(PlanError):
            ExecutionPlan("s", "p", "scope", "snap", (self.plan.stages[0], self.plan.stages[0]))

    def test_unknown_mutation_is_recorded_once_without_replay(self):
        ledger = ExecutionLedger(self.plan)
        entry = ledger.record("stage-a", LedgerStatus.UNKNOWN, mutated=True,
                              reason="result_missing_after_mutation", session_id="session-a")
        self.assertTrue(entry.mutated)
        self.assertEqual(ledger.next_unrecorded(), (self.plan.stages[1],))
        with self.assertRaises(PlanError):
            ledger.record("stage-a", LedgerStatus.DONE, mutated=False,
                          reason="replay", session_id="session-a")

    def test_independent_stage_can_continue_after_partial(self):
        ledger = ExecutionLedger(self.plan)
        ledger.record("stage-a", LedgerStatus.PARTIAL, mutated=True,
                      reason="partial_suffix", session_id="session-a")
        ledger.record("stage-b", LedgerStatus.DONE, mutated=True,
                      reason="complete", session_id="session-a")
        self.assertEqual(ledger.next_unrecorded(), ())

    def test_wrong_session_and_unplanned_stage_are_rejected(self):
        ledger = ExecutionLedger(self.plan)
        with self.assertRaises(PlanError):
            ledger.record("stage-a", LedgerStatus.ATTEMPTED, mutated=False,
                          reason="attempt", session_id="session-b")
        with self.assertRaises(PlanError):
            ledger.record("stage-c", LedgerStatus.ATTEMPTED, mutated=False,
                          reason="attempt", session_id="session-a")


if __name__ == "__main__":
    unittest.main()
