import unittest

try:
    from .trial_config import TrialArm, TrialConfigError, TrialMatrix
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from trial_config import TrialArm, TrialConfigError, TrialMatrix


def arm(label, command):
    return TrialArm(label, command, "private-32m", 7, 0.2, (3.0, 15.0, 60.0), "reset-a", "teardown-a", 30.0)


class TrialConfigTests(unittest.TestCase):
    def test_fair_three_arm_matrix_is_accepted(self):
        TrialMatrix((arm("baseline", "baseline.exe"), arm("candidate", "candidate.exe"), arm("noop", "noop.exe"))).validate()

    def test_setup_reset_observer_or_timeout_mismatch_is_rejected(self):
        altered = TrialArm("candidate", "candidate.exe", "private-32m", 8, 0.2, (3.0, 15.0, 60.0), "reset-a", "teardown-a", 30.0)
        with self.assertRaises(TrialConfigError):
            TrialMatrix((arm("baseline", "baseline.exe"), altered, arm("noop", "noop.exe"))).validate()

    def test_sleep_placeholder_cannot_be_product_baseline_or_candidate(self):
        with self.assertRaises(TrialConfigError):
            TrialMatrix((arm("baseline", "sleep"), arm("candidate", "candidate.exe"), arm("noop", "noop.exe"))).validate()

    def test_missing_or_duplicate_arm_is_rejected(self):
        with self.assertRaises(TrialConfigError):
            TrialMatrix((arm("baseline", "baseline.exe"), arm("candidate", "candidate.exe"))).validate()
        with self.assertRaises(TrialConfigError):
            TrialMatrix((arm("baseline", "baseline.exe"), arm("candidate", "candidate.exe"), arm("candidate", "other.exe"))).validate()

    def test_unsorted_observer_offsets_are_rejected(self):
        bad = TrialArm("noop", "noop.exe", "private-32m", 7, 0.2, (15.0, 3.0), "reset-a", "teardown-a", 30.0)
        with self.assertRaises(TrialConfigError):
            TrialMatrix((arm("baseline", "baseline.exe"), arm("candidate", "candidate.exe"), bad)).validate()


if __name__ == "__main__":
    unittest.main()
