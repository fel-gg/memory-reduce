import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[2]
WORKFLOW = ROOT / ".github" / "workflows" / "release.yml"


class ReleaseWorkflowContractTests(unittest.TestCase):
    def test_windows_release_is_built_before_publish(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("build-windows:", text)
        self.assertIn("needs: build-windows", text)
        self.assertIn("actions/upload-artifact@v4", text)
        self.assertIn("actions/download-artifact@v4", text)
        self.assertIn("fresh-windows/*.exe", text)

    def test_release_does_not_archive_tracked_windows_executables(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertNotIn("windows/ReduceMemory_x64.exe \\", text)
        self.assertNotIn("windows/ReduceMemory.exe \\", text)
        self.assertNotIn("windows/ReduceMemoryWorker_x64.exe \\", text)
        self.assertNotIn("windows/ReduceMemoryWorker.exe \\", text)

    def test_release_has_bounded_jobs_and_toolchain_downloads(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("timeout-minutes: 30", text)
        self.assertIn("timeout-minutes: 15", text)
        self.assertGreaterEqual(text.count("-TimeoutSec 120"), 2)
        self.assertIn('tags:', text)
        self.assertIn('"v*"', text)


if __name__ == "__main__":
    unittest.main()
