import unittest

try:
    from .decision_rules import ArmObservation, Decision, DecisionCriteria, classify
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from decision_rules import ArmObservation, Decision, DecisionCriteria, classify


class DecisionRuleTests(unittest.TestCase):
    def setUp(self):
        self.criteria = DecisionCriteria(100, 20, 10, 5, 1024)
        self.baseline = ArmObservation(100, 20, 10, 100)
        self.noop = ArmObservation(105, 20, 10, 100)

    def test_useful_gain_inside_budget_is_accepted(self):
        candidate = ArmObservation(300, 25, 11, 500)
        self.assertEqual(classify(self.baseline, candidate, self.noop, self.criteria), Decision.ACCEPT)

    def test_cost_budget_rejects_even_when_gain_is_large(self):
        candidate = ArmObservation(1000, 31, 10, 100)
        self.assertEqual(classify(self.baseline, candidate, self.noop, self.criteria), Decision.REJECT_COST)

    def test_noise_or_small_gain_is_inconclusive(self):
        self.assertEqual(classify(self.baseline, ArmObservation(180, 20, 10, 100), self.noop, self.criteria), Decision.INCONCLUSIVE)
        self.assertEqual(classify(self.baseline, ArmObservation(310, 20, 10, 100), ArmObservation(210, 20, 10, 100), self.criteria), Decision.INCONCLUSIVE)

    def test_missing_mandatory_metric_is_invalid(self):
        candidate = ArmObservation(None, 20, 10, 100)
        self.assertEqual(classify(self.baseline, candidate, self.noop, self.criteria), Decision.INVALID)

    def test_negative_thresholds_are_rejected(self):
        with self.assertRaises(ValueError):
            DecisionCriteria(-1, 0, 0, 0, 0)


if __name__ == "__main__":
    unittest.main()
