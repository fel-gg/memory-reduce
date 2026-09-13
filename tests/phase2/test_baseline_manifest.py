import tempfile
import unittest
from pathlib import Path

try:
    from .baseline_manifest import BaselineError, BaselineInput, create_baseline, verify_baseline
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from baseline_manifest import BaselineError, BaselineInput, create_baseline, verify_baseline


class BaselineManifestTests(unittest.TestCase):
    def test_create_and_verify_staged_baseline(self):
        with tempfile.TemporaryDirectory(prefix="reduce-memory-baseline-test-") as temp:
            root = Path(temp)
            source = root / "source.au3"
            artifact = root / "ReduceMemory.exe"
            config = root / "ReduceMemory.ini"
            source.write_text("source", encoding="utf-8")
            artifact.write_bytes(b"artifact")
            config.write_text("OptimizeMode=0\n", encoding="utf-8")
            manifest = create_baseline(
                root / "baseline",
                (BaselineInput("source", source), BaselineInput("artifact_x86", artifact), BaselineInput("config", config)),
                source_commit="ABC123",
            )
            data = verify_baseline(manifest)
            self.assertEqual(data["source_commit"], "abc123")
            self.assertEqual(len(data["inputs"]), 3)

    def test_mutation_and_missing_file_are_detected(self):
        with tempfile.TemporaryDirectory(prefix="reduce-memory-baseline-test-") as temp:
            root = Path(temp)
            source = root / "source.au3"
            config = root / "ReduceMemory.ini"
            source.write_text("source", encoding="utf-8")
            config.write_text("config", encoding="utf-8")
            manifest = create_baseline(root / "baseline", (BaselineInput("source", source), BaselineInput("config", config)), source_commit="a1")
            staged = root / "baseline" / "files" / "source"
            staged.write_text("changed", encoding="utf-8")
            with self.assertRaises(BaselineError):
                verify_baseline(manifest)
            staged.unlink()
            with self.assertRaises(BaselineError):
                verify_baseline(manifest)

    def test_non_empty_output_and_invalid_roles_cannot_overwrite(self):
        with tempfile.TemporaryDirectory(prefix="reduce-memory-baseline-test-") as temp:
            root = Path(temp)
            source = root / "source"
            config = root / "config"
            source.write_text("source", encoding="utf-8")
            config.write_text("config", encoding="utf-8")
            target = root / "baseline"
            target.mkdir()
            (target / "keep").write_text("user", encoding="utf-8")
            with self.assertRaises(BaselineError):
                create_baseline(target, (BaselineInput("source", source), BaselineInput("config", config)), source_commit="a1")
            with self.assertRaises(BaselineError):
                create_baseline(root / "other", (BaselineInput("bad role", source), BaselineInput("config", config)), source_commit="a1")

    def test_duplicate_roles_and_missing_config_are_rejected(self):
        with tempfile.TemporaryDirectory(prefix="reduce-memory-baseline-test-") as temp:
            root = Path(temp)
            source = root / "source"
            source.write_text("source", encoding="utf-8")
            with self.assertRaises(BaselineError):
                create_baseline(root / "duplicate", (BaselineInput("source", source), BaselineInput("source", source)), source_commit="a1")
            with self.assertRaises(BaselineError):
                create_baseline(root / "no-config", (BaselineInput("source", source),), source_commit="a1")


if __name__ == "__main__":
    unittest.main()
