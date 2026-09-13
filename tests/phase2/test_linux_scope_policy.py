import unittest

try:
    from .linux_scope_policy import (
        CapabilityState,
        ScopeCapabilities,
        ScopePolicyError,
        SwapSnapshot,
        choose_reclaim_path,
        effective_swap_allowance,
    )
except ImportError:  # unittest discover -s tests/phase2
    from linux_scope_policy import (
        CapabilityState,
        ScopeCapabilities,
        ScopePolicyError,
        SwapSnapshot,
        choose_reclaim_path,
        effective_swap_allowance,
    )


class LinuxScopePolicyTests(unittest.TestCase):
    def test_effective_allowance_is_bounded_by_all_domains(self):
        self.assertEqual(effective_swap_allowance(SwapSnapshot(100, 80, 60)), (60, "known_allowance"))

    def test_unknown_allowance_is_not_unlimited(self):
        self.assertEqual(effective_swap_allowance(SwapSnapshot(100, None, 60)), (None, "unknown_allowance"))

    def test_negative_allowance_is_rejected(self):
        with self.assertRaises(ScopePolicyError):
            effective_swap_allowance(SwapSnapshot(-1, 1, 1))

    def test_both_paths_require_experiment(self):
        decision = choose_reclaim_path(ScopeCapabilities(CapabilityState.USABLE, CapabilityState.USABLE, True))
        self.assertEqual(decision.path, "experiment_required")
        self.assertTrue(decision.requires_experiment)

    def test_unsafe_cgroup_does_not_override_process_path(self):
        decision = choose_reclaim_path(ScopeCapabilities(CapabilityState.USABLE, CapabilityState.USABLE, False))
        self.assertEqual(decision.path, "targeted_process")

    def test_unknown_cgroup_scope_defers_when_process_is_unusable(self):
        decision = choose_reclaim_path(ScopeCapabilities(CapabilityState.DENIED, CapabilityState.USABLE, None))
        self.assertEqual(decision.path, "deferred")

    def test_denied_process_can_use_safe_cgroup(self):
        decision = choose_reclaim_path(ScopeCapabilities(CapabilityState.DENIED, CapabilityState.USABLE, True))
        self.assertEqual(decision.path, "scoped_cgroup")

    def test_unknown_capability_defers(self):
        decision = choose_reclaim_path(ScopeCapabilities(CapabilityState.UNKNOWN, CapabilityState.DENIED, True))
        self.assertEqual(decision.path, "deferred")

    def test_no_authorized_path_is_unsupported(self):
        decision = choose_reclaim_path(ScopeCapabilities(CapabilityState.DENIED, CapabilityState.UNSUPPORTED, False))
        self.assertEqual(decision.path, "unsupported")


if __name__ == "__main__":
    unittest.main()
