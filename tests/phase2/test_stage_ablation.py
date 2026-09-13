import unittest

try:
    from .stage_ablation import (
        AblationArm,
        BenefitStatus,
        CacheObservation,
        StageContractError,
        StageInventory,
        StageMeasurement,
        StageSpec,
        select_stage_measurements,
        stage_invocations,
        validate_ablation,
        validate_cache_postcondition,
    )
except ImportError:
    from stage_ablation import (
        AblationArm,
        BenefitStatus,
        CacheObservation,
        StageContractError,
        StageInventory,
        StageMeasurement,
        StageSpec,
        select_stage_measurements,
        stage_invocations,
        validate_ablation,
        validate_cache_postcondition,
    )


class StageAblationTests(unittest.TestCase):
    def setUp(self):
        self.inventory = StageInventory((
            StageSpec("process", "working_set", "resident"),
            StageSpec("file_cache", "file_cache", "standby", prerequisites=("process",)),
            StageSpec("global_existing", "global_api", "standby", global_stage=True, prerequisites=("process",)),
        ))
        self.baseline = AblationArm("baseline", ("process",))

    def test_inventory_requires_known_prerequisites(self):
        with self.assertRaises(StageContractError):
            StageInventory((StageSpec("bad", "cap", "endpoint", prerequisites=("missing",)),))

    def test_one_difference_ablation_is_accepted(self):
        validate_ablation(self.inventory, AblationArm("process-file", ("process", "file_cache")), baseline=self.baseline)

    def test_multi_difference_or_missing_prerequisite_is_rejected(self):
        with self.assertRaises(StageContractError):
            validate_ablation(self.inventory, AblationArm("too-many", ("process", "file_cache", "global_existing")), baseline=self.baseline)
        with self.assertRaises(StageContractError):
            validate_ablation(self.inventory, AblationArm("missing", ("file_cache",)), baseline=self.baseline)

    def test_invocation_order_and_duplicate_global_stage(self):
        self.assertEqual(stage_invocations(self.inventory, ("process", "global_existing")), ("process", "global_existing"))
        with self.assertRaises(StageContractError):
            stage_invocations(self.inventory, ("process", "process"))

    def test_cache_policy_change_is_never_accepted(self):
        self.assertEqual(validate_cache_postcondition(CacheObservation("off", "off", "success")), "verified")
        with self.assertRaises(StageContractError):
            validate_cache_postcondition(CacheObservation("off", "on", "success"))

    def test_unavailable_cache_postcondition_limits_claim(self):
        self.assertEqual(validate_cache_postcondition(CacheObservation("off", None, "denied")), "unavailable")

    def test_stage_measurements_do_not_double_count_same_endpoint(self):
        result = select_stage_measurements((
            StageMeasurement("process", "resident", 100, 2),
            StageMeasurement("file_cache", "standby", 50, 4),
            StageMeasurement("global_existing", "standby", 70, 3),
        ), 10, 10)
        self.assertEqual(result["process"], BenefitStatus.KEEP)
        self.assertEqual(result["file_cache"], BenefitStatus.KEEP)
        self.assertEqual(result["global_existing"], BenefitStatus.NO_CHANGE)

    def test_missing_measurement_is_inconclusive(self):
        result = select_stage_measurements((StageMeasurement("process", "resident", None, 1),), 10, 10)
        self.assertEqual(result["process"], BenefitStatus.INCONCLUSIVE)

    def test_measurement_thresholds_are_bounded(self):
        with self.assertRaises(StageContractError):
            select_stage_measurements((), -1, 1)
        with self.assertRaises(StageContractError):
            select_stage_measurements((), 1, -1)


if __name__ == "__main__":
    unittest.main()
