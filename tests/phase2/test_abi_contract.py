from __future__ import annotations

import unittest

from abi_contract import (
    AbiError,
    INT64_MAX,
    INT64_MIN,
    UINT32_MAX,
    UINT64_MAX,
    WINDOWS_X64,
    WINDOWS_X86,
    checked_add,
    contract_for,
    page_aligned_range,
    signed_delta,
    validate_address_range,
    validate_count,
    validate_page_size,
)


class AbiContractTests(unittest.TestCase):
    def test_known_contracts_and_unknown_architecture(self) -> None:
        self.assertEqual(contract_for("windows-x86"), WINDOWS_X86)
        self.assertEqual(contract_for("windows-x64"), WINDOWS_X64)
        with self.assertRaises(AbiError):
            contract_for("arm64-guess")

    def test_address_addition_rejects_overflow_before_call(self) -> None:
        self.assertEqual(checked_add(UINT32_MAX - 3, 3, UINT32_MAX), UINT32_MAX)
        with self.assertRaises(AbiError):
            checked_add(UINT32_MAX, 1, UINT32_MAX)
        with self.assertRaises(AbiError):
            validate_address_range(UINT32_MAX - 1, 4, WINDOWS_X86)
        self.assertEqual(validate_address_range(0x1000, 0x1000, WINDOWS_X64), (0x1000, 0x2000))

    def test_count_and_page_size_bounds(self) -> None:
        self.assertEqual(validate_count(16_384, 16_384, label="records"), 16_384)
        with self.assertRaises(AbiError):
            validate_count(16_385, 16_384, label="records")
        self.assertEqual(validate_page_size(4096), 4096)
        with self.assertRaises(AbiError):
            validate_page_size(3000)
        with self.assertRaises(AbiError):
            validate_page_size(0)

    def test_signed_delta_preserves_growth_and_rejects_wrap(self) -> None:
        self.assertEqual(signed_delta(256, 128), 128)
        self.assertEqual(signed_delta(128, 256), -128)
        self.assertEqual(signed_delta(0, INT64_MAX), -INT64_MAX)
        self.assertEqual(signed_delta(0, 1 << 63), INT64_MIN)
        with self.assertRaises(AbiError):
            signed_delta(0, (1 << 63) + 1)
        with self.assertRaises(AbiError):
            signed_delta(UINT64_MAX, 0)
        self.assertLess(INT64_MIN, 0)

    def test_page_aligned_range_is_checked_against_pointer_width(self) -> None:
        self.assertEqual(page_aligned_range(0x1000, 0x2000, 4096, WINDOWS_X86), (0x1000, 0x3000))
        with self.assertRaises(AbiError):
            page_aligned_range(0x1001, 0x1FFF, 4096, WINDOWS_X64)


if __name__ == "__main__":
    unittest.main()
