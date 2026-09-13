import sys
import os
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent))
import run_benchmark


class _CompletedProcess:
    pid = 4242
    returncode = 0

    def poll(self):
        return self.returncode

    def communicate(self):
        return "", ""


class _LiveThenCompleted(_CompletedProcess):
    def __init__(self):
        self._polls = 0

    def poll(self):
        self._polls += 1
        return None if self._polls == 1 else self.returncode


class RunTrialTimingTests(unittest.TestCase):
    def test_process_tree_contains_current_process_identity(self):
        pids, status = run_benchmark.process_tree_pids(os.getpid())
        self.assertEqual(status, "complete")
        self.assertIn(os.getpid(), pids)
        snapshot = run_benchmark.process_tree_snapshot(os.getpid())
        self.assertIn(os.getpid(), snapshot["identities"])

    def test_delayed_observation_does_not_inflate_action_metrics(self):
        process = _CompletedProcess()
        with mock.patch.object(run_benchmark.subprocess, "Popen", return_value=process), \
             mock.patch.object(run_benchmark, "available_bytes", side_effect=[100, 90, 80]), \
             mock.patch.object(run_benchmark, "rss_bytes", return_value=None), \
             mock.patch.object(run_benchmark, "fault_counts", return_value=None), \
             mock.patch.object(run_benchmark, "cpu_seconds", return_value=None), \
             mock.patch.object(run_benchmark, "io_bytes", return_value=None), \
             mock.patch.object(run_benchmark, "swap_bytes", return_value=None), \
             mock.patch.object(run_benchmark.time, "perf_counter", side_effect=[0.0, 0.02, 0.03, 0.08]), \
             mock.patch.object(run_benchmark.time, "sleep") as sleep:
            trial = run_benchmark.run_trial("probe", "fixture-command", 5, [0.05])

        self.assertEqual(trial["status"], "completed")
        self.assertEqual(trial["exit_code"], 0)
        self.assertEqual(trial["elapsed_ms"], 20.0)
        self.assertEqual(trial["observation_elapsed_ms"], 80.0)
        self.assertEqual(trial["available_bytes_before"], 100)
        self.assertEqual(trial["available_bytes_after"], 90)
        self.assertEqual(trial["available_bytes_after_delay"], {"0.05": 80})
        self.assertIn("process_tree_status", trial)
        sleep.assert_called_once()
        self.assertAlmostEqual(sleep.call_args.args[0], 0.04, places=12)

    def test_terminal_sample_never_reads_reused_pid(self):
        process = _LiveThenCompleted()
        live_tree = {
            "pids": [4242], "status": "complete", "rss_bytes": 200,
            "cpu_seconds": 1.0, "identities": {4242: "win:birth"},
        }
        with mock.patch.object(run_benchmark.subprocess, "Popen", return_value=process), \
             mock.patch.object(run_benchmark, "available_bytes", side_effect=[100, 90]), \
             mock.patch.object(run_benchmark, "process_tree_snapshot", return_value=live_tree), \
             mock.patch.object(run_benchmark, "rss_bytes", return_value=200), \
             mock.patch.object(run_benchmark, "fault_counts", return_value={"minor": 10, "major": 1}), \
             mock.patch.object(run_benchmark, "cpu_seconds", return_value=1.0), \
             mock.patch.object(run_benchmark, "io_bytes", return_value={"read_bytes": 1, "write_bytes": 2}), \
             mock.patch.object(run_benchmark, "swap_bytes", return_value=0), \
             mock.patch.object(run_benchmark.time, "perf_counter", side_effect=[0.0, 0.02, 0.03, 0.03]), \
             mock.patch.object(run_benchmark.time, "sleep"):
            trial = run_benchmark.run_trial("probe", "fixture-command", 5, [])

        self.assertEqual(trial["process_tree_cpu_seconds_delta"], 0.0)
        self.assertEqual(trial["cpu_seconds_delta"], 0.0)
        self.assertEqual(trial["faults_delta"], {"minor": 0, "major": 0})
        self.assertEqual(trial["io_bytes_delta"], {"read_bytes": 0, "write_bytes": 0})


if __name__ == "__main__":
    unittest.main()
