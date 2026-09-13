import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import workload_memory


class WorkloadFixtureTests(unittest.TestCase):
    def test_runtime_page_size_and_pattern_are_deterministic(self):
        page = workload_memory.runtime_page_size()
        self.assertGreaterEqual(page, 1024)
        self.assertEqual(page & (page - 1), 0)
        self.assertEqual(workload_memory.deterministic_page(page), workload_memory.deterministic_page(page))
        self.assertEqual(len(workload_memory.deterministic_page(page)), page)

    def test_retouch_waits_for_post_action_marker_and_records_checksum(self):
        root = Path(tempfile.mkdtemp(prefix="reduce-memory-fixture-test-"))
        try:
            ready = root / "ready"
            retouch = root / "retouch"
            checksum = root / "checksum"
            command = [
                sys.executable,
                str(Path(workload_memory.__file__).resolve()),
                "--megabytes",
                "2",
                "--seconds",
                "1",
                "--pattern",
                "retouch",
                "--ready-file",
                str(ready),
                "--retouch-file",
                str(retouch),
                "--checksum-file",
                str(checksum),
            ]
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            try:
                self.assertTrue(wait_until(ready.is_file, 2.0))
                self.assertFalse(checksum.exists())
                retouch.write_text("go\n", encoding="utf-8")
                stdout, stderr = process.communicate(timeout=5)
            finally:
                if process.poll() is None:
                    process.kill()
                    process.wait(timeout=5)
            self.assertEqual(process.returncode, 0, stderr)
            self.assertIn("page_size=", stdout)
            values = dict(line.split("=", 1) for line in checksum.read_text(encoding="utf-8").splitlines())
            self.assertNotEqual(values["initial"], values["final"])
        finally:
            for path in root.iterdir():
                path.unlink()
            root.rmdir()

    def test_file_cache_fixture_completes_with_real_backing_data(self):
        with tempfile.TemporaryDirectory(prefix="reduce-memory-file-cache-") as root:
            ready = Path(root) / "ready"
            command = [
                sys.executable,
                str(Path(workload_memory.__file__).resolve()),
                "--megabytes",
                "2",
                "--seconds",
                "0.1",
                "--pattern",
                "file-cache",
                "--ready-file",
                str(ready),
            ]
            result = subprocess.run(command, capture_output=True, text=True, timeout=5, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("page_size=", result.stdout)
            self.assertTrue(ready.is_file())

    def test_remaining_patterns_have_bounded_disposable_runs(self):
        for pattern in ("private", "hot", "new-allocation", "short-lived"):
            with self.subTest(pattern=pattern):
                result = subprocess.run([
                    sys.executable,
                    str(Path(workload_memory.__file__).resolve()),
                    "--megabytes", "1",
                    "--seconds", "0.1",
                    "--pattern", pattern,
                ], capture_output=True, text=True, timeout=5, check=False)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("page_size=", result.stdout)

    def test_unusable_page_size_is_rejected(self):
        with mock.patch.object(workload_memory.os, "sysconf", side_effect=OSError, create=True), \
             mock.patch.object(workload_memory.mmap, "PAGESIZE", 0):
            with self.assertRaises(RuntimeError):
                workload_memory.runtime_page_size()


def wait_until(predicate, timeout):
    import time

    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if predicate():
            return True
        time.sleep(0.02)
    return predicate()


if __name__ == "__main__":
    unittest.main()
