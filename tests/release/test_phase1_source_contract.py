import pathlib
import re
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCE = ROOT / "src" / "ReduceMemory.au3"


class Phase1SourceContractTests(unittest.TestCase):
    """Cheap regression guards for the high-risk Phase 1 paths.

    Runtime Windows tests remain authoritative; these checks prevent a later
    refactor from silently replacing the handle-relative temp deletion and
    bounded native-worker protections with the old unsafe primitives.
    """

    @classmethod
    def setUpClass(cls):
        cls.text = SOURCE.read_text(encoding="utf-8-sig")

    def test_temp_tree_uses_handle_delete_and_reparse_guard(self):
        match = re.search(
            r"Func RM_DeleteTempTree \(.*?^EndFunc",
            self.text,
            re.MULTILINE | re.DOTALL,
        )
        self.assertIsNotNone(match, "RM_DeleteTempTree disappeared")
        body = match.group(0)
        self.assertIn("RM_DeleteTempObjectByHandle", body)
        self.assertIn("RM_IsReparsePoint", body)
        self.assertNotRegex(body, r"\b(?:FileDelete|DirRemove)\s*\(")

    def test_native_worker_is_job_owned_and_suspended_before_assignment(self):
        match = re.search(
            r"Func RM_RunOwnedNativeWorker \(.*?^EndFunc",
            self.text,
            re.MULTILINE | re.DOTALL,
        )
        self.assertIsNotNone(match, "RM_RunOwnedNativeWorker disappeared")
        body = match.group(0)
        self.assertIn("CREATE_SUSPENDED", body)
        self.assertIn("AssignProcessToJobObject", body)
        self.assertIn("ResumeThread", body)
        self.assertIn("0xFFFFFFFF", body)

    def test_optimization_entrypoints_take_single_writer_lock(self):
        for marker in ("/RMAGGRESSIVE", "/RMSMOOTH", "/RMEMERGENCY"):
            start = self.text.find('If $CMDLINE [ 1 ] = "' + marker + '"')
            self.assertGreaterEqual(start, 0, marker)
            end = self.text.find("EndIf", start)
            self.assertGreater(end, start, marker)
            branch = self.text[start:end]
            self.assertIn("RM_AcquireOptimizationLock", branch, marker)


if __name__ == "__main__":
    unittest.main()
