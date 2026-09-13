import sys
import time
import unittest

try:
    from .trial_controller import PhaseTimeouts, TrialController, TrialPhase, process_identity
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from trial_controller import PhaseTimeouts, TrialController, TrialPhase, process_identity


class TrialControllerTests(unittest.TestCase):
    def _workload(self, body):
        return [sys.executable, "-c", body]

    def test_complete_lifecycle_has_ordered_events_and_bounded_output(self):
        controller = TrialController(timeouts=PhaseTimeouts(ready=2, action=2, observe=1, teardown=1))
        workload = self._workload(
            "from pathlib import Path; import time; "
            "Path('{ready_file}').write_text('ready'); print('workload-ready', flush=True); time.sleep(2)"
        )
        optimizer = self._workload("print('optimizer-done', flush=True)")
        result = controller.run(workload, optimizer, observe_seconds=0.1)
        self.assertEqual(result.status, "completed")
        self.assertEqual(result.phase, TrialPhase.COMPLETE)
        self.assertEqual(result.reason, "completed")
        self.assertIn("ready.observed", result.events)
        self.assertIn("action.terminal", result.events)
        self.assertIn("observe.complete", result.events)
        self.assertIn("integrity.pass", result.events)
        self.assertEqual(result.stdout["workload"].strip(), "workload-ready")
        self.assertEqual(result.stdout["optimizer"].strip(), "optimizer-done")
        self.assertIn("teardown.start", result.events)
        self.assertIn("teardown.complete", result.events)
        self.assertTrue(result.owned_identities)

    def test_ready_timeout_is_invalid_and_does_not_start_optimizer(self):
        controller = TrialController(timeouts=PhaseTimeouts(ready=0.2, action=1, observe=1, teardown=1))
        workload = self._workload("import time; print('no-ready', flush=True); time.sleep(1)")
        result = controller.run(workload, self._workload("raise SystemExit(9)"))
        self.assertEqual(result.status, "invalid")
        self.assertEqual(result.phase, TrialPhase.INVALID)
        self.assertEqual(result.reason, "ready_timeout")
        self.assertIsNone(result.optimizer_pid)
        self.assertNotIn("action.start", result.events)

    def test_optimizer_timeout_is_invalid_and_owned_fixture_is_cleaned(self):
        controller = TrialController(timeouts=PhaseTimeouts(ready=1, action=0.2, observe=1, teardown=1))
        workload = self._workload(
            "from pathlib import Path; import time; Path('{ready_file}').write_text('ready'); time.sleep(2)"
        )
        optimizer = self._workload("import time; time.sleep(2)")
        result = controller.run(workload, optimizer)
        self.assertEqual(result.status, "invalid")
        self.assertEqual(result.phase, TrialPhase.INVALID)
        self.assertEqual(result.reason, "optimizer_timeout")
        self.assertIn("teardown.complete", result.events)
        for pid, identity in result.owned_identities.items():
            deadline = time.monotonic() + 2
            while process_identity(pid) == identity and time.monotonic() < deadline:
                time.sleep(0.02)
            self.assertNotEqual(process_identity(pid), identity, f"owned process survived: pid={pid}")


if __name__ == "__main__":
    unittest.main()
