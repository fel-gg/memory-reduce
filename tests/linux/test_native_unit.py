#!/usr/bin/env python3
"""Unit tests for deterministic Linux native-helper decisions."""

import importlib.machinery
import importlib.util
import errno
import pathlib
import sys
import unittest
from unittest import mock


HELPER_PATH = pathlib.Path(__file__).resolve().parents[2] / "linux" / "native" / "reduce-memory-native"
LOADER = importlib.machinery.SourceFileLoader("reduce_memory_native", str(HELPER_PATH))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[LOADER.name] = MODULE
LOADER.exec_module(MODULE)


class RemainingRangesTests(unittest.TestCase):
    def test_partial_syscall_keeps_only_unprocessed_suffix(self) -> None:
        ranges = [(0, 1000, 100), (1, 2000, 200), (2, 3000, 300)]

        remaining, touched = MODULE.remaining_ranges(ranges, 150)

        self.assertEqual(touched, {0, 1})
        self.assertEqual(remaining, [(1, 2050, 150), (2, 3000, 300)])

    def test_zero_progress_keeps_every_range_untouched(self) -> None:
        ranges = [(4, 4096, 512), (5, 8192, 1024)]

        remaining, touched = MODULE.remaining_ranges(ranges, 0)

        self.assertEqual(touched, set())
        self.assertEqual(remaining, ranges)


class ProcessIdentityTests(unittest.TestCase):
    def test_pageout_opens_pidfd_before_reading_mappings(self) -> None:
        order: list[str] = []
        mapping = MODULE.Mapping(4096, 8192, "r--p", "fixture", rss_kb=4)

        with mock.patch.object(MODULE, "pidfd_open", side_effect=lambda _pid: order.append("pidfd") or 9), \
             mock.patch.object(MODULE, "process_starttime", side_effect=lambda _pid: order.append("identity") or 77), \
             mock.patch.object(MODULE, "mapping_identity", return_value=((4096, 8192),)), \
             mock.patch.object(MODULE, "parse_smaps", side_effect=lambda _pid, _minimum: order.append("smaps") or [mapping]), \
             mock.patch.object(MODULE, "process_madvise_pageout", return_value=4096), \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77)

        self.assertEqual(order[0], "pidfd")
        self.assertEqual(result[-1], "done")

    def test_identity_change_before_mutation_is_rejected(self) -> None:
        with mock.patch.object(MODULE, "pidfd_open", return_value=9), \
             mock.patch.object(MODULE, "process_starttime", return_value=88), \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77)

        self.assertEqual(result[2], 0)
        self.assertEqual(result[-1], "identity_changed")

    def test_partial_batch_preserves_last_errno_and_advised_bytes(self) -> None:
        mapping = MODULE.Mapping(4096, 8192, "r--p", "fixture", rss_kb=4)
        calls = []

        def advise(_pidfd, ranges):
            calls.append(len(ranges))
            if len(ranges) > 1:
                raise OSError(errno.EAGAIN, "partial batch")
            raise OSError(errno.EPERM, "scalar denied")

        with mock.patch.object(MODULE, "pidfd_open", return_value=9), \
             mock.patch.object(MODULE, "process_starttime", return_value=77), \
             mock.patch.object(MODULE, "mapping_identity", return_value=((4096, 8192),)), \
             mock.patch.object(MODULE, "parse_smaps", return_value=[mapping, mapping]), \
             mock.patch.object(MODULE, "process_madvise_pageout", side_effect=advise), \
             mock.patch.object(MODULE, "parse_status", return_value=(1000, 4, 1, "fixture")), \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77)

        self.assertEqual(result[2], 0)
        self.assertEqual(result[5], errno.EPERM)
        self.assertEqual(result[-1], "done")
        self.assertEqual(calls, [2, 1])

    def test_identity_unavailable_during_final_cleanup_never_reads_unset_mapping(self) -> None:
        with mock.patch.object(MODULE, "pidfd_open", return_value=9), \
             mock.patch.object(MODULE, "process_starttime", side_effect=[None, 77]), \
             mock.patch.object(MODULE, "mapping_identity") as mapping, \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77)

        mapping.assert_not_called()
        self.assertEqual(result[2], 0)
        self.assertEqual(result[-1], "identity_changed")


class CgroupReclaimTests(unittest.TestCase):
    def test_reclaim_writer_rejects_arbitrary_path(self) -> None:
        arguments = mock.Mock(protocol=2, session="fixture", bytes=1048576,
                              swappiness="default", path="/tmp/not-a-reclaim-file")
        with mock.patch.object(MODULE.os, "open") as opener, mock.patch("builtins.print"):
            exit_code = MODULE.command_reclaim(arguments)

        self.assertEqual(exit_code, 2)
        opener.assert_not_called()

    def test_eagain_is_partial_and_never_retried(self) -> None:
        arguments = mock.Mock(protocol=2, session="fixture", bytes=1048576,
                              swappiness="default", path="/fixture/memory.reclaim")
        with mock.patch.object(MODULE.os, "open", return_value=8), \
             mock.patch.object(MODULE.os, "write", side_effect=OSError(errno.EAGAIN, "partial")) as writer, \
             mock.patch.object(MODULE.os, "close"):
            with mock.patch("builtins.print"):
                exit_code = MODULE.command_reclaim(arguments)

        self.assertEqual(exit_code, 0)
        self.assertEqual(writer.call_count, 1)

    def test_wrong_protocol_is_rejected_before_open(self) -> None:
        arguments = mock.Mock(protocol=1, session="fixture", bytes=1048576,
                              swappiness="default", path="/fixture/memory.reclaim")
        with mock.patch.object(MODULE.os, "open") as opener, mock.patch("builtins.print"):
            exit_code = MODULE.command_reclaim(arguments)

        self.assertEqual(exit_code, 2)
        opener.assert_not_called()

    def test_swappiness_outside_kernel_range_is_rejected_before_open(self) -> None:
        for value in ("-1", "201", "999999999999999999999"):
            arguments = mock.Mock(protocol=2, session="fixture", bytes=1048576,
                                  swappiness=value, path="/fixture/memory.reclaim")
            with self.subTest(swappiness=value), mock.patch.object(MODULE.os, "open") as opener, mock.patch("builtins.print"):
                exit_code = MODULE.command_reclaim(arguments)
            self.assertEqual(exit_code, 2)
            opener.assert_not_called()


class RssMeasurementTests(unittest.TestCase):
    def test_failed_after_read_is_unknown_not_full_release(self) -> None:
        samples = [MODULE.RssMeasurement(101, 262144, None, "exited", True)]

        summary = MODULE.summarize_rss_measurements(samples)

        self.assertEqual(summary.delta_kb, 0)
        self.assertEqual(summary.measured_targets, 0)
        self.assertEqual(summary.unmeasured_targets, 1)
        self.assertEqual(summary.exited_targets, 1)

    def test_rss_growth_remains_a_signed_negative_reduction(self) -> None:
        samples = [MODULE.RssMeasurement(102, 262144, 294912, "measured", True)]

        summary = MODULE.summarize_rss_measurements(samples)

        self.assertEqual(summary.delta_kb, -32768)
        self.assertEqual(summary.measured_targets, 1)

    def test_success_without_change_is_measured_zero(self) -> None:
        samples = [MODULE.RssMeasurement(103, 262144, 262144, "measured", True)]

        summary = MODULE.summarize_rss_measurements(samples)

        self.assertEqual(summary.delta_kb, 0)
        self.assertEqual(summary.measured_targets, 1)
        self.assertEqual(summary.unmeasured_targets, 0)

    def test_unadvised_process_that_exits_is_not_a_measurement(self) -> None:
        samples = [MODULE.RssMeasurement(104, 262144, None, "exited", False)]

        summary = MODULE.summarize_rss_measurements(samples)

        self.assertEqual(summary.measured_targets, 0)
        self.assertEqual(summary.unmeasured_targets, 0)
        self.assertEqual(summary.exited_targets, 0)

    def test_identity_change_is_unknown(self) -> None:
        samples = [MODULE.RssMeasurement(105, 262144, 131072, "identity_mismatch", True)]

        summary = MODULE.summarize_rss_measurements(samples)

        self.assertEqual(summary.delta_kb, 0)
        self.assertEqual(summary.identity_mismatch_targets, 1)
        self.assertEqual(summary.unmeasured_targets, 1)

    def test_permission_change_has_its_own_unknown_counter(self) -> None:
        samples = [MODULE.RssMeasurement(106, 262144, None, "permission_denied", True)]

        summary = MODULE.summarize_rss_measurements(samples)

        self.assertEqual(summary.delta_kb, 0)
        self.assertEqual(summary.unmeasured_targets, 1)
        self.assertEqual(summary.exited_targets, 0)
        self.assertEqual(summary.permission_denied_targets, 1)

    def test_status_permission_error_is_not_reported_as_process_exit(self) -> None:
        with mock.patch("builtins.open", side_effect=PermissionError):
            parsed, status = MODULE.parse_status_detail(106)

        self.assertIsNone(parsed)
        self.assertEqual(status, "permission_denied")

    def test_missing_status_returns_none_instead_of_zero_rss(self) -> None:
        original = MODULE.parse_status
        MODULE.parse_status = lambda _pid: None
        try:
            self.assertIsNone(MODULE.read_rss_kb(999999))
        finally:
            MODULE.parse_status = original


if __name__ == "__main__":
    unittest.main()
