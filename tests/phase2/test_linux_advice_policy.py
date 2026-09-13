import unittest

try:
    from .linux_advice_policy import (
        AdviceKind,
        AdvicePolicyError,
        AdviceResult,
        compare_strategies,
        evaluate_advice,
    )
except ImportError:  # unittest discover -s tests/phase2
    from linux_advice_policy import (
        AdviceKind,
        AdvicePolicyError,
        AdviceResult,
        compare_strategies,
        evaluate_advice,
    )


class LinuxAdvicePolicyTests(unittest.TestCase):
    def test_cold_never_gets_release_credit(self):
        result = evaluate_advice(AdviceResult(AdviceKind.COLD, "complete", 4096, 4096, -4096, True, "usable"))
        self.assertEqual(result.released_bytes_credit, 0)
        self.assertEqual(result.reason, "hint_only_no_release_credit")

    def test_pageout_credit_is_advice_coverage_not_resident_delta(self):
        result = evaluate_advice(AdviceResult(AdviceKind.PAGEOUT, "complete", 8192, 4096, 0, True, "usable"))
        self.assertEqual(result.released_bytes_credit, 4096)

    def test_identity_change_defers_without_credit(self):
        result = evaluate_advice(AdviceResult(AdviceKind.PAGEOUT, "complete", 4096, 4096, -4096, False, "usable"))
        self.assertEqual((result.status, result.released_bytes_credit), ("deferred", 0))

    def test_unusable_pageout_capability_has_no_credit(self):
        result = evaluate_advice(AdviceResult(AdviceKind.PAGEOUT, "complete", 4096, 4096, -4096, True, "denied"))
        self.assertEqual(result.status, "unsupported")
        self.assertEqual(result.released_bytes_credit, 0)

    def test_pageout_error_has_no_credit(self):
        result = evaluate_advice(AdviceResult(AdviceKind.PAGEOUT, "error", 4096, 4096, None, True, "usable"))
        self.assertEqual(result.released_bytes_credit, 0)

    def test_negative_or_oversized_accounting_is_rejected(self):
        with self.assertRaises(AdvicePolicyError):
            evaluate_advice(AdviceResult(AdviceKind.PAGEOUT, "complete", 4096, -1, None, True, "usable"))
        with self.assertRaises(AdvicePolicyError):
            evaluate_advice(AdviceResult(AdviceKind.PAGEOUT, "complete", 4096, 8192, None, True, "usable"))

    def test_comparison_requires_same_range(self):
        cold = AdviceResult(AdviceKind.COLD, "complete", 4096, 4096, 0, True, "usable")
        pageout = AdviceResult(AdviceKind.PAGEOUT, "complete", 8192, 8192, 0, True, "usable")
        with self.assertRaises(AdvicePolicyError):
            compare_strategies(cold, pageout)

    def test_same_range_comparison_preserves_distinct_credits(self):
        cold = AdviceResult(AdviceKind.COLD, "complete", 4096, 4096, -4096, True, "usable")
        pageout = AdviceResult(AdviceKind.PAGEOUT, "complete", 4096, 4096, -4096, True, "usable")
        cold_result, pageout_result = compare_strategies(cold, pageout)
        self.assertEqual(cold_result.released_bytes_credit, 0)
        self.assertEqual(pageout_result.released_bytes_credit, 4096)


if __name__ == "__main__":
    unittest.main()
