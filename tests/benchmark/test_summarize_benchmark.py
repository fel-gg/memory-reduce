import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import summarize_benchmark


class SummarizeBenchmarkTests(unittest.TestCase):
    def test_retained_samples_keep_nulls_out_of_numeric_summary(self):
        with tempfile.TemporaryDirectory(prefix="reduce-memory-summary-test-") as root:
            root_path = Path(root)
            report = root_path / "raw.json"
            output = root_path / "summary.json"
            report.write_text(json.dumps({
                "seed": 7,
                "source": {"sha256": "source"},
                "trials": [
                    {
                        "label": "baseline", "status": "completed", "exit_code": 0,
                        "elapsed_ms": 10, "peak_rss_bytes": 100,
                        "process_tree_peak_rss_bytes": 120,
                        "process_tree_cpu_seconds_delta": 1.5,
                        "available_bytes_before": 1000, "available_bytes_after": 900,
                        "available_bytes_after_delay": {"3": 950, "15": None},
                        "cpu_seconds_delta": 1, "swap_bytes_delta": None,
                        "faults_delta": None,
                    },
                    {
                        "label": "baseline", "status": "completed", "exit_code": 0,
                        "elapsed_ms": 12, "peak_rss_bytes": 110,
                        "process_tree_peak_rss_bytes": 130,
                        "process_tree_cpu_seconds_delta": 2.5,
                        "available_bytes_before": 1000, "available_bytes_after": 920,
                        "available_bytes_after_delay": {"3": None, "15": 980},
                        "cpu_seconds_delta": 2, "swap_bytes_delta": None,
                        "faults_delta": None,
                    },
                ],
            }), encoding="utf-8")
            self.assertEqual(summarize_benchmark.main.__module__, "summarize_benchmark")
            with mock.patch("sys.argv", ["summarize_benchmark", str(report), "--output", str(output)]):
                self.assertEqual(summarize_benchmark.main(), 0)
            summary = json.loads(output.read_text(encoding="utf-8"))
            retained = summary["successful_groups"]["baseline"]["available_delta_after_delay_bytes"]
            self.assertEqual(summary["successful_groups"]["baseline"]["process_tree_peak_rss_bytes"]["median"], 125.0)
            self.assertEqual(summary["successful_groups"]["baseline"]["process_tree_cpu_seconds_delta"]["median"], 2.0)
            self.assertEqual(retained["3"]["median"], -50)
            self.assertEqual(retained["15"]["median"], -20)


if __name__ == "__main__":
    unittest.main()
