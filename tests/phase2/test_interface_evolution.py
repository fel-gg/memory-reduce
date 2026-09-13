import unittest

try:
    from .interface_evolution import (
        InterfaceError,
        InterfaceSpec,
        NegotiationStatus,
        StageCapability,
        StageStatus,
        negotiate,
        stage_readiness,
    )
except ImportError:
    from interface_evolution import (
        InterfaceError,
        InterfaceSpec,
        NegotiationStatus,
        StageCapability,
        StageStatus,
        negotiate,
        stage_readiness,
    )


def spec(**kwargs):
    defaults = dict(
        major=2,
        minor=0,
        required_fields=frozenset({"session", "status"}),
        optional_fields=frozenset({"diagnostic"}),
        semantic_fields=frozenset({"session", "status"}),
        capabilities=frozenset({"working_set", "pageout"}),
    )
    defaults.update(kwargs)
    return InterfaceSpec(**defaults)


class InterfaceEvolutionTests(unittest.TestCase):
    def test_unknown_optional_field_is_ignored(self):
        result = negotiate(spec(), spec(optional_fields=frozenset({"diagnostic", "new_hint"})))
        self.assertEqual(result.status, NegotiationStatus.ACCEPT_WITH_IGNORED_OPTIONAL)
        self.assertEqual(result.ignored_optional, frozenset({"new_hint"}))

    def test_unknown_semantic_field_fails_before_mutation(self):
        result = negotiate(
            spec(),
            spec(
                optional_fields=frozenset({"diagnostic", "new_result"}),
                semantic_fields=frozenset({"session", "status", "new_result"}),
            ),
        )
        self.assertEqual(result.status, NegotiationStatus.REJECT_SEMANTIC_CHANGE)
        self.assertEqual(stage_readiness(result, StageCapability("pageout", frozenset({"pageout"}))), StageStatus.REJECTED)

    def test_major_version_mismatch_is_not_silent_downgrade(self):
        result = negotiate(spec(), spec(major=3))
        self.assertEqual(result.status, NegotiationStatus.REJECT_VERSION)

    def test_missing_required_field_is_rejected(self):
        result = negotiate(spec(), spec(required_fields=frozenset({"session", "status", "identity"})))
        self.assertEqual(result.status, NegotiationStatus.REJECT_REQUIRED_FIELD)

    def test_capability_subset_keeps_independent_stage_usable(self):
        result = negotiate(spec(capabilities=frozenset({"working_set"})), spec())
        self.assertEqual(result.status, NegotiationStatus.ACCEPT)
        self.assertEqual(stage_readiness(result, StageCapability("working", frozenset({"working_set"}))), StageStatus.READY)
        self.assertEqual(stage_readiness(result, StageCapability("pageout", frozenset({"pageout"}))), StageStatus.UNSUPPORTED)

    def test_invalid_spec_rejects_field_overlap(self):
        with self.assertRaises(InterfaceError):
            spec(required_fields=frozenset({"session"}), optional_fields=frozenset({"session"}))

    def test_semantic_fields_must_be_declared(self):
        with self.assertRaises(InterfaceError):
            spec(semantic_fields=frozenset({"not_declared"}))


if __name__ == "__main__":
    unittest.main()
