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

    def test_exact_boundary_marks_only_fully_consumed_ranges(self) -> None:
        ranges = [(0, 4096, 4096), (1, 8192, 4096)]

        remaining, touched = MODULE.remaining_ranges(ranges, 4096)

        self.assertEqual(touched, {0})
        self.assertEqual(remaining, [(1, 8192, 4096)])

    def test_over_advice_never_creates_negative_suffix(self) -> None:
        ranges = [(0, 4096, 4096), (1, 8192, 4096)]

        remaining, touched = MODULE.remaining_ranges(ranges, 16384)

        self.assertEqual(touched, {0, 1})
        self.assertEqual(remaining, [])

    def test_mid_chunk_suffix_preserves_parent_identity(self) -> None:
        ranges = [(9, 4096, 8192), (10, 16384, 4096)]

        remaining, touched = MODULE.remaining_ranges(ranges, 4096)

        self.assertEqual(touched, {9})
        self.assertEqual(remaining, [(9, 8192, 4096), (10, 16384, 4096)])

    def test_execution_guard_prioritizes_cancellation_and_deadline(self) -> None:
        with mock.patch.object(MODULE.time, "monotonic", return_value=10.0):
            self.assertEqual(MODULE.execution_guard_status(9.0), "deadline")
            self.assertEqual(
                MODULE.execution_guard_status(9.0, cancel_check=lambda: True),
                "cancelled",
            )
            self.assertIsNone(MODULE.execution_guard_status(11.0, cancel_check=lambda: False))

    def test_range_bytes_never_counts_negative_residual(self) -> None:
        self.assertEqual(
            MODULE.range_bytes([(0, 4096, 4096), (1, 8192, -4096), (2, 12288, 2048)]),
            6144,
        )

    def test_cancel_file_marker_is_read_only_and_optional(self) -> None:
        self.assertFalse(MODULE.cancel_file_requested(None))
        with mock.patch.object(MODULE.Path, "is_file", return_value=True) as marker:
            self.assertTrue(MODULE.cancel_file_requested("/tmp/owned.cancel"))
        marker.assert_called_once_with()


class ProcessIdentityTests(unittest.TestCase):
    def test_snapshot_identity_reconciliation_is_conservative(self) -> None:
        mapping = ((4096, 8192),)
        cases = (
            (77, 77, mapping, mapping, "stable"),
            (77, 88, mapping, mapping, "identity_changed"),
            (77, None, mapping, mapping, "identity_changed"),
            (77, 77, mapping, ((4096, 12288),), "mapping_changed"),
            (77, 77, None, mapping, "mapping_changed"),
            (77, 77, mapping, None, "mapping_changed"),
        )
        for expected, observed, before, after, expected_status in cases:
            with self.subTest(expected=expected, observed=observed, expected_status=expected_status):
                self.assertEqual(
                    MODULE.snapshot_identity_status(expected, observed, before, after),
                    expected_status,
                )

    def test_capability_probe_distinguishes_unknown_architecture(self) -> None:
        with mock.patch.object(MODULE.platform, "system", return_value="Linux"), \
             mock.patch.object(MODULE.platform, "machine", return_value="mystery-isa"), \
             mock.patch.object(MODULE, "LIBC") as libc:
            status, probe_errno, reason = MODULE.syscall_capability()

        self.assertEqual((status, probe_errno, reason), ("unsupported", errno.ENOSYS, "unknown_architecture"))
        libc.syscall.assert_not_called()

    def test_capability_probe_distinguishes_permission_or_seccomp(self) -> None:
        libc = mock.Mock()

        def denied(*args):
            syscall_number = int(getattr(args[0], "value", args[0]))
            MODULE.ctypes.set_errno(errno.EINVAL if syscall_number == MODULE.SYS_PIDFD_OPEN else errno.EPERM)
            return -1

        libc.syscall.side_effect = denied
        with mock.patch.object(MODULE.platform, "system", return_value="Linux"), \
             mock.patch.object(MODULE.platform, "machine", return_value="x86_64"), \
             mock.patch.object(MODULE, "LIBC", libc):
            status, probe_errno, reason = MODULE.syscall_capability()
            compatibility = MODULE.syscall_supported()

        self.assertEqual((status, probe_errno, reason), ("permission_denied", errno.EPERM, "permission_or_seccomp"))
        self.assertEqual(compatibility, (False, errno.EPERM))

    def test_capability_probe_reports_missing_syscall(self) -> None:
        libc = mock.Mock()

        def missing(*_args):
            MODULE.ctypes.set_errno(errno.EINVAL)
            if int(getattr(_args[0], "value", _args[0])) == MODULE.SYS_PROCESS_MADVISE:
                MODULE.ctypes.set_errno(errno.ENOSYS)
            return -1

        libc.syscall.side_effect = missing
        with mock.patch.object(MODULE.platform, "system", return_value="Linux"), \
             mock.patch.object(MODULE.platform, "machine", return_value="x86_64"), \
             mock.patch.object(MODULE, "LIBC", libc):
            status, probe_errno, reason = MODULE.syscall_capability()

        self.assertEqual((status, probe_errno, reason), ("unsupported", errno.ENOSYS, "syscall_missing"))

    def test_pidfd_probe_distinguishes_missing_syscall(self) -> None:
        libc = mock.Mock()

        def missing(*_args):
            MODULE.ctypes.set_errno(errno.ENOSYS)
            return -1

        libc.syscall.side_effect = missing
        with mock.patch.object(MODULE.platform, "system", return_value="Linux"), \
             mock.patch.object(MODULE.platform, "machine", return_value="x86_64"), \
             mock.patch.object(MODULE, "LIBC", libc), \
             mock.patch.object(MODULE.os, "pidfd_open", create=True, side_effect=OSError(errno.ENOSYS, "missing")):
            status, probe_errno, reason = MODULE.pidfd_capability()

        self.assertEqual((status, probe_errno, reason), ("unsupported", errno.ENOSYS, "pidfd_syscall_missing"))

    def test_command_check_emits_capability_reason(self) -> None:
        with mock.patch.object(MODULE, "syscall_capability", return_value=("permission_denied", errno.EPERM, "permission_or_seccomp")), \
             mock.patch("builtins.print") as printer:
            exit_code = MODULE.command_check()

        self.assertEqual(exit_code, 4)
        output = "\n".join(str(call.args[0]) for call in printer.call_args_list)
        self.assertIn("native_status=permission_denied", output)
        self.assertIn("capability_reason=permission_or_seccomp", output)

    def test_pageout_capability_denial_stops_before_snapshot(self) -> None:
        arguments = mock.Mock(protocol=2, session="fixture")
        with mock.patch.object(MODULE, "syscall_capability", return_value=("permission_denied", errno.EPERM, "permission_or_seccomp")), \
             mock.patch.object(MODULE, "snapshot_processes") as snapshot, \
             mock.patch("builtins.print"):
            exit_code = MODULE.command_pageout(arguments)

        self.assertEqual(exit_code, 4)
        snapshot.assert_not_called()


class MappingMetadataTests(unittest.TestCase):
    def test_iovec_batches_respect_bytes_and_count(self) -> None:
        chunks = [
            (1, 0x1000, 0x2000, 0),
            (1, 0x3000, 0x2000, 0x2000),
            (2, 0x8000, 0x1000, 0),
            (2, 0x9000, 0x1000, 0x1000),
        ]

        batches = MODULE.build_iovec_batches(chunks, 0x5000, 2)

        self.assertEqual(batches, [chunks[:2], chunks[2:]])
        for batch in batches:
            self.assertLessEqual(len(batch), 2)
            self.assertLessEqual(sum(item[2] for item in batch), 0x5000)

    def test_iovec_batches_reject_invalid_limits_or_oversized_chunk(self) -> None:
        with self.assertRaises(ValueError):
            MODULE.build_iovec_batches([(1, 0x1000, 0x4000, 0)], 0x2000, 1)
        with self.assertRaises(ValueError):
            MODULE.build_iovec_batches([], 0, 1)
        with self.assertRaises(ValueError):
            MODULE.build_iovec_batches([], 0x1000, 0)

    def test_chunk_mapping_range_covers_input_without_gap_or_overlap(self) -> None:
        chunks = MODULE.chunk_mapping_range(7, 0x1000, 0x9000, 0x1000, 0x4000)

        self.assertEqual(chunks, [
            (7, 0x1000, 0x4000, 0),
            (7, 0x5000, 0x4000, 0x4000),
            (7, 0x9000, 0x1000, 0x8000),
        ])
        self.assertEqual(sum(chunk[2] for chunk in chunks), 0x9000)
        for previous, current in zip(chunks, chunks[1:]):
            self.assertEqual(previous[1] + previous[2], current[1])

    def test_chunk_mapping_range_rejects_non_page_budget_or_range(self) -> None:
        for args in (
            (7, 0x1001, 0x2000, 0x1000, 0x2000),
            (7, 0x1000, 0x2000, 0x1000, 0x2100),
            (7, 0x1000, 0x2000, 0x1000, 0),
        ):
            with self.subTest(args=args), self.assertRaises(ValueError):
                MODULE.chunk_mapping_range(*args)

    def test_mapping_exclusion_reason_preserves_special_page_policy(self) -> None:
        base = MODULE.Mapping(4096, 8192, "r--p", "/fixture", rss_kb=8)
        cases = (
            (MODULE.Mapping(**{**base.__dict__, "rss_kb": 3}), "below_threshold"),
            (MODULE.Mapping(**{**base.__dict__, "locked_kb": 1}), "locked"),
            (MODULE.Mapping(**{**base.__dict__, "vm_flags": frozenset({"ht"})}), "special_vmflags"),
            (MODULE.Mapping(**{**base.__dict__, "vm_flags": frozenset({"hg"}), "anon_huge_pages_kb": 4096}), None),
            (MODULE.Mapping(**{**base.__dict__, "path": "/dev/dri/card0"}), "device"),
            (MODULE.Mapping(**{**base.__dict__, "path": "[stack]"}), "special_path"),
            (MODULE.Mapping(**{**base.__dict__, "perms": "---p"}), "not_readable"),
        )
        for mapping, expected in cases:
            with self.subTest(expected=expected):
                self.assertEqual(MODULE.mapping_exclusion_reason(mapping, 4), expected)

    def test_mapping_range_validation_rejects_unsafe_shapes(self) -> None:
        cases = (
            (4096, 8192, 4096, "valid"),
            (4097, 8192, 4096, "unaligned"),
            (8192, 4096, 4096, "invalid_bounds"),
            (0, (1 << 64) + 4096, 4096, "address_overflow"),
            (4096, 8192, 3000, "invalid_page_size"),
            (4096, 8192, None, "invalid_page_size"),
        )
        for start, end, page_size, expected in cases:
            with self.subTest(start=start, end=end, expected=expected):
                self.assertEqual(MODULE.validate_mapping_range(start, end, page_size), expected)

    def test_invalid_mapping_range_stops_before_advice(self) -> None:
        mapping = MODULE.Mapping(4097, 8192, "r--p", "fixture", rss_kb=4)
        with mock.patch.object(MODULE, "pidfd_open", return_value=9), \
             mock.patch.object(MODULE, "process_starttime", return_value=77), \
             mock.patch.object(MODULE, "mapping_identity", return_value=((4097, 8192),)), \
             mock.patch.object(MODULE, "parse_smaps", return_value=[mapping]), \
             mock.patch.object(MODULE, "process_madvise_pageout") as advise, \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77)

        self.assertEqual(result[-1], "invalid_range")
        self.assertEqual(result[2], 0)
        advise.assert_not_called()

    def test_cancel_boundary_records_residual_ranges_without_advice(self) -> None:
        mappings = [
            MODULE.Mapping(4096, 8192, "r--p", "fixture", rss_kb=4),
            MODULE.Mapping(8192, 12288, "r--p", "fixture", rss_kb=4),
        ]
        with mock.patch.object(MODULE, "pidfd_open", return_value=9), \
             mock.patch.object(MODULE, "process_starttime", return_value=77), \
             mock.patch.object(MODULE, "mapping_identity", return_value=((4096, 8192), (8192, 12288))), \
             mock.patch.object(MODULE, "parse_smaps", return_value=mappings), \
             mock.patch.object(MODULE, "process_madvise_pageout") as advise, \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77, cancel_check=lambda: True)

        self.assertEqual(result[-1], "cancelled")
        self.assertEqual(result[-2], 8192)
        self.assertEqual(result[2], 0)
        advise.assert_not_called()

    def test_mapping_change_at_batch_boundary_defers_without_advice(self) -> None:
        mapping = MODULE.Mapping(4096, 8192, "r--p", "fixture", rss_kb=4)
        stable = ((4096, 8192),)
        changed = ((4096, 12288),)
        with mock.patch.object(MODULE, "pidfd_open", return_value=9), \
             mock.patch.object(MODULE, "process_starttime", return_value=77), \
             mock.patch.object(MODULE, "mapping_identity", side_effect=[stable, stable, changed, changed]), \
             mock.patch.object(MODULE, "parse_smaps", return_value=[mapping]), \
             mock.patch.object(MODULE, "process_madvise_pageout") as advise, \
             mock.patch.object(MODULE.os, "close"):
            result = MODULE.pageout_process(123, 4, 77)

        self.assertEqual(result[-1], "mapping_changed")
        self.assertEqual(result[-2], 4096)
        advise.assert_not_called()

    def test_parse_smaps_preserves_optional_mapping_metadata(self) -> None:
        fixture = """00001000-00003000 r--p 00000000 00:00 0 /fixture\n\
Size:                  8 kB\n\
Rss:                   8 kB\n\
Locked:                0 kB\n\
Anonymous:             4 kB\n\
Private_Clean:         1 kB\n\
Private_Dirty:         2 kB\n\
Shared_Clean:          3 kB\n\
Shared_Dirty:          4 kB\n\
Swap:                  5 kB\n\
KernelPageSize:        4 kB\n\
MMUPageSize:           4 kB\n\
AnonHugePages:         0 kB\n\
VmFlags: rd mr\n"""
        with mock.patch("builtins.open", mock.mock_open(read_data=fixture)):
            mappings = MODULE.parse_smaps(123, 4)

        self.assertEqual(len(mappings), 1)
        mapping = mappings[0]
        self.assertEqual(mapping.anonymous_kb, 4)
        self.assertEqual(mapping.private_clean_kb, 1)
        self.assertEqual(mapping.private_dirty_kb, 2)
        self.assertEqual(mapping.shared_clean_kb, 3)
        self.assertEqual(mapping.shared_dirty_kb, 4)
        self.assertEqual(mapping.swap_kb, 5)
        self.assertEqual(mapping.kernel_page_size_kb, 4)
        self.assertEqual(mapping.mmu_page_size_kb, 4)
        self.assertEqual(mapping.anon_huge_pages_kb, 0)

    def test_malformed_or_negative_optional_metadata_is_unknown(self) -> None:
        fixture = """00001000-00003000 r--p 00000000 00:00 0 /fixture\n\
Rss:                   8 kB\n\
Locked:                0 kB\n\
Anonymous:             malformed kB\n\
Swap:                  -1 kB\n\
VmFlags: rd\n"""
        with mock.patch("builtins.open", mock.mock_open(read_data=fixture)):
            mappings = MODULE.parse_smaps(123, 4)

        self.assertEqual(len(mappings), 1)
        self.assertIsNone(mappings[0].anonymous_kb)
        self.assertIsNone(mappings[0].swap_kb)

    def test_selection_reason_is_one_terminal_reason_per_snapshot(self) -> None:
        snapshot = MODULE.ProcessSnapshot(10, 1000, 8192, 4, 1, "fixture", "fixture", 77)
        self.assertEqual(MODULE.selection_reason(snapshot, {10}, 4096, True, 9, 2), "protected")
        self.assertEqual(MODULE.selection_reason(snapshot, set(), 16384, True, 9, 2), "below_threshold")
        self.assertEqual(MODULE.selection_reason(snapshot, set(), 4096, True, 9, 2), "active")
        self.assertEqual(MODULE.selection_reason(snapshot, set(), 4096, True, None, 2), "invalid_identity")
        self.assertEqual(MODULE.selection_reason(snapshot, set(), 4096, True, 5, 2), "eligible")

    def test_zero_activity_and_settle_are_valid_disable_values(self) -> None:
        parser = MODULE.build_parser()
        arguments = parser.parse_args(["pageout", "--pid", "1", "--activity-ms", "0", "--settle-ms", "0"])
        self.assertEqual(arguments.activity_ms, 0)
        self.assertEqual(arguments.settle_ms, 0)
        self.assertEqual(arguments.deadline_ms, 0)

    def test_deadline_is_nonnegative_and_explicit(self) -> None:
        parser = MODULE.build_parser()
        arguments = parser.parse_args(["pageout", "--pid", "1", "--deadline-ms", "25"])
        self.assertEqual(arguments.deadline_ms, 25)
        arguments = parser.parse_args(["pageout", "--pid", "1", "--cancel-file", "/tmp/cancel"])
        self.assertEqual(arguments.cancel_file, "/tmp/cancel")
        with self.assertRaises(SystemExit) as error:
            parser.parse_args(["pageout", "--pid", "1", "--deadline-ms", "-1"])
        self.assertEqual(error.exception.code, 2)

    def test_negative_activity_is_rejected(self) -> None:
        parser = MODULE.build_parser()
        with self.assertRaises(SystemExit) as error:
            parser.parse_args(["pageout", "--pid", "1", "--activity-ms", "-1"])
        self.assertEqual(error.exception.code, 2)

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
        descriptor_stat = mock.Mock(st_dev=1, st_ino=2)
        with mock.patch.object(MODULE, "valid_reclaim_scope", return_value=(True, "fixture", (1, 2))), \
             mock.patch.object(MODULE.os, "open", return_value=8), \
             mock.patch.object(MODULE.os, "fstat", return_value=descriptor_stat), \
             mock.patch.object(MODULE.os, "write", side_effect=OSError(errno.EAGAIN, "partial")) as writer, \
             mock.patch.object(MODULE.os, "close"):
            with mock.patch("builtins.print"):
                exit_code = MODULE.command_reclaim(arguments)

        self.assertEqual(exit_code, 0)
        self.assertEqual(writer.call_count, 1)

    def test_reclaim_scope_rejects_unknown_or_outside_mount(self) -> None:
        with mock.patch.object(MODULE, "cgroup2_mountpoints", return_value=("/sys/fs/cgroup",)), \
             mock.patch.object(MODULE, "reclaim_path_identity", return_value=(1, 2)), \
             mock.patch.object(MODULE.os, "stat", return_value=mock.Mock(st_mode=0)):
            valid, reason, identity = MODULE.valid_reclaim_scope("/tmp/memory.reclaim")

        self.assertFalse(valid)
        self.assertEqual(reason, "outside_cgroup2")
        self.assertEqual(identity, None)

    def test_cgroup2_mountinfo_parser_unescapes_mountpoint(self) -> None:
        mountinfo = "36 29 0:32 / /sys/fs/cgroup\\040v2 rw,nosuid - cgroup2 cgroup rw\n"
        with mock.patch.object(MODULE.platform, "system", return_value="Linux"), \
             mock.patch("builtins.open", mock.mock_open(read_data=mountinfo)), \
             mock.patch.object(MODULE.os.path, "realpath", side_effect=lambda value: value):
            self.assertEqual(MODULE.cgroup2_mountpoints(), ("/sys/fs/cgroup v2",))

    def test_reclaim_writer_rejects_identity_swap_before_write(self) -> None:
        arguments = mock.Mock(protocol=2, session="fixture", bytes=1048576,
                              swappiness="default", path="/fixture/memory.reclaim")
        descriptor_stat = mock.Mock(st_dev=3, st_ino=4)
        with mock.patch.object(MODULE, "valid_reclaim_scope", return_value=(True, "fixture", (1, 2))), \
             mock.patch.object(MODULE.os, "open", return_value=8), \
             mock.patch.object(MODULE.os, "fstat", return_value=descriptor_stat), \
             mock.patch.object(MODULE.os, "write") as writer, \
             mock.patch.object(MODULE.os, "close"), \
             mock.patch("builtins.print") as printer:
            exit_code = MODULE.command_reclaim(arguments)

        self.assertEqual(exit_code, 5)
        writer.assert_not_called()
        output = "\n".join(str(call.args[0]) for call in printer.call_args_list)
        self.assertIn("native_status=scope_changed", output)

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
