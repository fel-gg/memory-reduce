import unittest

try:
    from .parity_fixture import (
        ExecutionProfile,
        ParityFixtureError,
        ProfileOutcome,
        SelectionSnapshot,
        equivalent_target_snapshot,
        validate_profile_parity,
    )
except ImportError:  # unittest discover -s tests/phase2 imports files as top-level modules
    from parity_fixture import (
        ExecutionProfile,
        ParityFixtureError,
        ProfileOutcome,
        SelectionSnapshot,
        equivalent_target_snapshot,
        validate_profile_parity,
    )


class ParityFixtureTests(unittest.TestCase):
    def setUp(self):
        self.snapshot = SelectionSnapshot(
            session_id="s-1",
            selected_ids=("pid:10", "pid:20"),
            protected_ids=("pid:30",),
            excluded_ids=("pid:40",),
        )

    def test_normal_and_aggressive_preserve_snapshot(self):
        outcomes = (
            ProfileOutcome(ExecutionProfile.NORMAL, "s-1", ("pid:10", "pid:20"), ("pid:10",), "done"),
            ProfileOutcome(ExecutionProfile.AGGRESSIVE, "s-1", ("pid:10", "pid:20"), ("pid:10", "pid:20"), "done"),
        )
        validate_profile_parity(self.snapshot, outcomes)
        self.assertTrue(equivalent_target_snapshot(*outcomes))

    def test_fallback_requires_reason_and_degraded_status(self):
        outcome = ProfileOutcome(
            ExecutionProfile.FALLBACK, "s-1", ("pid:10",), (), "unsupported", "native_unavailable"
        )
        validate_profile_parity(self.snapshot, (outcome,))

    def test_fallback_without_reason_is_rejected(self):
        outcome = ProfileOutcome(ExecutionProfile.FALLBACK, "s-1", ("pid:10",), (), "partial")
        with self.assertRaises(ParityFixtureError):
            validate_profile_parity(self.snapshot, (outcome,))

    def test_outside_snapshot_is_rejected(self):
        outcome = ProfileOutcome(ExecutionProfile.NORMAL, "s-1", ("pid:99",), (), "done")
        with self.assertRaises(ParityFixtureError):
            validate_profile_parity(self.snapshot, (outcome,))

    def test_denied_status_cannot_claim_mutation(self):
        outcome = ProfileOutcome(ExecutionProfile.AGGRESSIVE, "s-1", ("pid:10",), ("pid:10",), "permission_denied")
        with self.assertRaises(ParityFixtureError):
            validate_profile_parity(self.snapshot, (outcome,))

    def test_overlapping_snapshot_sets_are_rejected(self):
        invalid = SelectionSnapshot("s-1", ("pid:10",), protected_ids=("pid:10",))
        with self.assertRaises(ParityFixtureError):
            validate_profile_parity(invalid, ())


if __name__ == "__main__":
    unittest.main()
