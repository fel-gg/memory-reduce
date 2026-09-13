import unittest

try:
    from .profile_contract import (
        ExperimentRecord,
        FrozenProfile,
        IntegrationStatus,
        ProfileContractError,
        ProfileParameters,
        can_integrate,
        classify_confirmation,
    )
except ImportError:
    from profile_contract import (
        ExperimentRecord,
        FrozenProfile,
        IntegrationStatus,
        ProfileContractError,
        ProfileParameters,
        can_integrate,
        classify_confirmation,
    )


class ProfileContractTests(unittest.TestCase):
    def setUp(self):
        self.parameters = ProfileParameters(32, 65536, 64, 8, 1)
        self.profile = FrozenProfile("normal", "rev-7", "a" * 64, self.parameters)
        self.record = ExperimentRecord("exp-7", "rev-7", 91, True, frozenset({"gain", "latency", "faults", "integrity"}), "b" * 64)

    def test_parameter_bounds_are_frozen_and_checked(self):
        with self.assertRaises((AttributeError, TypeError)):
            self.profile.revision = "rev-8"  # type: ignore[misc]
        with self.assertRaises(ProfileContractError):
            ProfileParameters(32, 1024, 64, 8, 1)

    def test_profile_requires_artifact_hash(self):
        with self.assertRaises(ProfileContractError):
            FrozenProfile("normal", "rev-7", "bad", self.parameters)

    def test_confirmation_requires_holdout_and_raw_digest(self):
        with self.assertRaises(ProfileContractError):
            ExperimentRecord("exp", "rev-7", 1, False, frozenset({"gain"}), "b" * 64)
        with self.assertRaises(ProfileContractError):
            ExperimentRecord("exp", "rev-7", 1, True, frozenset({"gain"}), "short")

    def test_accepted_confirmation_is_recomputable(self):
        status = classify_confirmation(
            gain_delta_bytes=4096,
            cost_within_budget=True,
            record=self.record,
            expected_revision="rev-7",
            minimum_gain_bytes=1024,
        )
        self.assertIs(status, IntegrationStatus.ACCEPT)
        self.assertTrue(can_integrate(status, preserve_user_overrides=True))

    def test_missing_or_small_confirmation_is_inconclusive(self):
        self.assertIs(
            classify_confirmation(gain_delta_bytes=None, cost_within_budget=True, record=self.record, expected_revision="rev-7", minimum_gain_bytes=1),
            IntegrationStatus.INCONCLUSIVE,
        )
        self.assertIs(
            classify_confirmation(gain_delta_bytes=1, cost_within_budget=True, record=self.record, expected_revision="rev-7", minimum_gain_bytes=1024),
            IntegrationStatus.INCONCLUSIVE,
        )

    def test_budget_failure_and_revision_mismatch_reject(self):
        self.assertIs(
            classify_confirmation(gain_delta_bytes=100000, cost_within_budget=False, record=self.record, expected_revision="rev-7", minimum_gain_bytes=1),
            IntegrationStatus.REJECT,
        )
        self.assertIs(
            classify_confirmation(gain_delta_bytes=100000, cost_within_budget=True, record=self.record, expected_revision="rev-8", minimum_gain_bytes=1),
            IntegrationStatus.REJECT,
        )

    def test_integration_requires_user_override_preservation(self):
        self.assertFalse(can_integrate(IntegrationStatus.ACCEPT, preserve_user_overrides=False))
        self.assertFalse(can_integrate(IntegrationStatus.INCONCLUSIVE, preserve_user_overrides=True))


if __name__ == "__main__":
    unittest.main()
