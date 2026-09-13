import unittest

try:
    from .linux_benchmark_contract import (
        BenchmarkContractError,
        MappingCase,
        MappingKind,
        MappingMeasurement,
        same_range_comparison,
        validate_grid,
        validate_measurement,
    )
except ImportError:  # unittest discover -s tests/phase2
    from linux_benchmark_contract import (
        BenchmarkContractError,
        MappingCase,
        MappingKind,
        MappingMeasurement,
        same_range_comparison,
        validate_grid,
        validate_measurement,
    )


def case(kind, suffix=None, **kwargs):
    suffix = suffix or kind.value
    return MappingCase(
        case_id=f"L08-{suffix}",
        kind=kind,
        page_size=4096,
        requested_bytes=4096 * 16,
        range_count=kwargs.get("range_count", 1),
        swap_state=kwargs.get("swap_state", "no_swap"),
        same_range_key=kwargs.get("same_range_key", f"range-{suffix}"),
    )


class LinuxBenchmarkContractTests(unittest.TestCase):
    def test_required_grid_is_accepted(self):
        validate_grid(tuple(case(kind) for kind in MappingKind))

    def test_missing_mapping_kind_is_rejected(self):
        with self.assertRaises(BenchmarkContractError):
            validate_grid(tuple(case(kind) for kind in MappingKind if kind is not MappingKind.THP))

    def test_invalid_page_alignment_is_rejected(self):
        invalid = case(MappingKind.CLEAN_FILE)
        invalid = MappingCase(**{**invalid.__dict__, "requested_bytes": 4097})
        with self.assertRaises(BenchmarkContractError):
            validate_measurement(invalid, MappingMeasurement(invalid.case_id, 4097, 0, None, None, None, None, None, None, None, "unknown"))

    def test_complete_measurement_requires_all_dimensions(self):
        fixture = case(MappingKind.DIRTY_FILE)
        incomplete = MappingMeasurement(fixture.case_id, fixture.requested_bytes, fixture.requested_bytes, 1, 0, 1.0, None, 1.0, 1.0, True, "complete")
        with self.assertRaises(BenchmarkContractError):
            validate_measurement(fixture, incomplete)

    def test_complete_measurement_is_accepted(self):
        fixture = case(MappingKind.ANONYMOUS_NO_SWAP)
        measurement = MappingMeasurement(fixture.case_id, fixture.requested_bytes, fixture.requested_bytes, 65536, 8192, 1.0, 2.0, 0.5, 3.0, True, "complete")
        validate_measurement(fixture, measurement)

    def test_advised_bytes_cannot_exceed_request(self):
        fixture = case(MappingKind.SPARSE)
        measurement = MappingMeasurement(fixture.case_id, fixture.requested_bytes, fixture.requested_bytes + 4096, None, None, None, None, None, None, None, "unknown")
        with self.assertRaises(BenchmarkContractError):
            validate_measurement(fixture, measurement)

    def test_failure_does_not_claim_integrity_success(self):
        fixture = case(MappingKind.SHARED)
        measurement = MappingMeasurement(fixture.case_id, fixture.requested_bytes, 0, None, None, None, None, None, None, True, "denied")
        with self.assertRaises(BenchmarkContractError):
            validate_measurement(fixture, measurement)

    def test_same_range_pair_requires_all_shape_dimensions(self):
        left = case(MappingKind.CLEAN_FILE, "pair", range_count=4)
        right = case(MappingKind.DIRTY_FILE, "pair", range_count=4)
        self.assertTrue(same_range_comparison(left, right))
        different = case(MappingKind.DIRTY_FILE, "pair", range_count=5)
        self.assertFalse(same_range_comparison(left, different))


if __name__ == "__main__":
    unittest.main()
