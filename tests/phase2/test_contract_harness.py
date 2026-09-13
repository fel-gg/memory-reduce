import unittest

try:
    from .contract_harness import ContractAdapter, StageRequest, StageScenario, StageStatus
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from contract_harness import ContractAdapter, StageRequest, StageScenario, StageStatus


class ContractHarnessTests(unittest.TestCase):
    def setUp(self):
        self.request = StageRequest("session-a", "stage-a", ("target-a",))

    def test_denied_and_unsupported_do_not_call_mutator(self):
        adapter = ContractAdapter()
        denied = adapter.execute(self.request, StageScenario(probe="denied"))
        unsupported = adapter.execute(self.request, StageScenario(probe="unsupported"))
        self.assertEqual(denied.status, StageStatus.PERMISSION_DENIED)
        self.assertEqual(unsupported.status, StageStatus.UNSUPPORTED)
        self.assertEqual(adapter.mutator_calls, [])

    def test_missing_ready_never_mutates(self):
        adapter = ContractAdapter()
        result = adapter.execute(self.request, StageScenario(ready=False))
        self.assertEqual(result.status, StageStatus.UNKNOWN)
        self.assertFalse(result.mutated)
        self.assertEqual(adapter.mutator_calls, [])
        self.assertEqual(result.events, ["probe.start", "ready.wait", "ready.missing"])

    def test_missing_result_after_mutation_is_unknown_without_replay(self):
        adapter = ContractAdapter()
        result = adapter.execute(self.request, StageScenario(result_present=False))
        self.assertEqual(result.status, StageStatus.UNKNOWN)
        self.assertTrue(result.mutated)
        self.assertEqual(len(adapter.mutator_calls), 1)
        self.assertEqual(result.events[-2:], ["action.mutated", "result.missing"])

    def test_wrong_session_and_timeout_remain_nonterminal(self):
        adapter = ContractAdapter()
        wrong = adapter.execute(self.request, StageScenario(session_id="session-b"))
        timeout = adapter.execute(self.request, StageScenario(action="timeout"))
        self.assertEqual(wrong.reason, "wrong_session")
        self.assertFalse(wrong.terminal)
        self.assertEqual(timeout.status, StageStatus.TIMEOUT)
        self.assertFalse(timeout.terminal)
        self.assertEqual(adapter.mutator_calls, [])

    def test_partial_stage_does_not_prevent_independent_stage(self):
        adapter = ContractAdapter()
        partial = adapter.execute(self.request, StageScenario(action="partial"))
        next_request = StageRequest("session-a", "stage-b", ("target-b",))
        complete = adapter.execute(next_request, StageScenario())
        self.assertEqual(partial.status, StageStatus.PARTIAL)
        self.assertEqual(complete.status, StageStatus.DONE)
        self.assertEqual(adapter.mutator_calls, [("target-a",), ("target-b",)])


if __name__ == "__main__":
    unittest.main()
