import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import latency_probe


class LatencyProbeTests(unittest.TestCase):
    def test_percentile_is_deterministic_and_interpolated(self):
        values = [10.0, 20.0, 30.0, 40.0]
        self.assertEqual(latency_probe.percentile(values, 0.5), 25.0)
        self.assertEqual(latency_probe.percentile(values, 0.0), 10.0)
        self.assertEqual(latency_probe.percentile(values, 1.0), 40.0)
        self.assertIsNone(latency_probe.percentile([], 0.95))

    def test_failed_iteration_is_reported_and_fails_process(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "latency.json"
            command = f'"{sys.executable}" -c "import sys; sys.exit(7)"'
            completed = subprocess.run(
                [sys.executable, str(Path(latency_probe.__file__)), "--command", command,
                 "--iterations", "1", "--timeout", "2", "--output", str(output)],
                check=False,
            )
            self.assertEqual(completed.returncode, 1)
            report = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(report["summary_ms"]["count"], 0)
            self.assertEqual(report["failures"][0]["exit_code"], 7)


if __name__ == "__main__":
    unittest.main()
