import unittest

try:
    from .compatibility_harness import MAX_BYTES, MAX_RECORDS, ProtocolError, parse_result
except ImportError:  # Direct discovery with tests/phase2 as the start directory.
    from compatibility_harness import MAX_BYTES, MAX_RECORDS, ProtocolError, parse_result


def fixture(record_count=1, extra=""):
    records = "".join(
        f"record={1000 + i}|0000000000000{i + 1:03X}|131072|65536|3|measured|fixture-{i}.exe\n"
        for i in range(record_count)
    )
    return (
        "protocol=2\n"
        "session=abc123\n"
        "terminal=done\n"
        "mutated=1\n"
        "exit_code=0\n"
        "trimmed=1\n"
        "resident_delta=65536\n"
        f"record_count={record_count}\n"
        f"{records}"
        f"measured={record_count}\n"
        "unmeasured=0\n"
        f"{extra}"
    )


class CompatibilityHarnessTests(unittest.TestCase):
    def test_old_fixture_is_accepted_and_new_optional_metadata_is_preserved(self):
        old = parse_result(fixture(), "abc123")
        self.assertEqual(len(old.records), 1)
        new = parse_result(fixture(extra="strategy_revision=phase2-1\nstage_id=stage-a\n"), "abc123")
        self.assertEqual(new.metadata, (("stage_id", "stage-a"), ("strategy_revision", "phase2-1")))

    def test_wrong_session_unknown_metadata_and_duplicate_key_are_rejected(self):
        with self.assertRaises(ProtocolError):
            parse_result(fixture(), "other")
        with self.assertRaises(ProtocolError):
            parse_result(fixture(extra="future_semantic=1\n"), "abc123")
        with self.assertRaises(ProtocolError):
            parse_result(fixture().replace("trimmed=1\n", "trimmed=1\ntrimmed=2\n"), "abc123")

    def test_truncated_result_and_record_count_mismatch_are_rejected(self):
        with self.assertRaises(ProtocolError):
            parse_result(fixture().split("measured=1")[0], "abc123")
        with self.assertRaises(ProtocolError):
            parse_result(fixture().replace("record_count=1", "record_count=2"), "abc123")

    def test_duplicate_identity_and_numeric_overflow_are_rejected(self):
        duplicate = fixture(record_count=2).replace(
            "record=1001|0000000000000002|", "record=1000|0000000000000001|"
        )
        with self.assertRaises(ProtocolError):
            parse_result(duplicate, "abc123")
        with self.assertRaises(ProtocolError):
            parse_result(fixture().replace("resident_delta=65536", "resident_delta=9223372036854775808"), "abc123")
        with self.assertRaises(ProtocolError):
            parse_result(fixture().replace("protocol=2", "protocol=3"), "abc123")
        with self.assertRaises(ProtocolError):
            parse_result(fixture().replace("trimmed=1", "trimmed=9007199254740992"), "abc123")

    def test_record_and_payload_limits_are_enforced(self):
        with self.assertRaises(ProtocolError):
            parse_result(fixture(record_count=MAX_RECORDS + 1), "abc123")
        with self.assertRaises(ProtocolError):
            parse_result(b"x" * (MAX_BYTES + 1), "abc123")

    def test_partial_unknown_mutation_is_valid_but_measured_requires_mutation(self):
        partial = fixture().replace("terminal=done", "terminal=partial").replace("measured=1", "measured=0").replace("unmeasured=0", "unmeasured=1").replace("mutated=1", "mutated=1").replace("|measured|", "|after_unknown|")
        result = parse_result(partial, "abc123")
        self.assertEqual(result.terminal, "partial")
        self.assertEqual(result.measured, 0)
        invalid = fixture().replace("mutated=1", "mutated=0")
        with self.assertRaises(ProtocolError):
            parse_result(invalid, "abc123")


if __name__ == "__main__":
    unittest.main()
