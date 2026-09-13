import unittest

try:
    from .scope_overlap import (
        MemberIdentity,
        ScopePlanError,
        ScopeStatus,
        classify_members,
        full_scope_safe,
    )
except ImportError:  # unittest discover -s tests/phase2
    from scope_overlap import (
        MemberIdentity,
        ScopePlanError,
        ScopeStatus,
        classify_members,
        full_scope_safe,
    )


class ScopeOverlapTests(unittest.TestCase):
    def test_child_scope_is_inside_parent(self):
        members = (MemberIdentity(10, "a", "/user.slice/app"),)
        result = classify_members("/user.slice", members)
        self.assertEqual(result[0].status, ScopeStatus.ELIGIBLE)
        self.assertTrue(full_scope_safe(result))

    def test_protected_descendant_blocks_full_scope(self):
        members = (MemberIdentity(10, "a", "/user.slice/app", protected=True),)
        result = classify_members("/user.slice", members)
        self.assertEqual(result[0].status, ScopeStatus.PROTECTED)
        self.assertFalse(full_scope_safe(result))

    def test_user_exclusion_is_not_eligible(self):
        result = classify_members("/user.slice", (MemberIdentity(10, "a", "/user.slice", excluded=True),))
        self.assertEqual(result[0].status, ScopeStatus.EXCLUDED)
        self.assertFalse(full_scope_safe(result))

    def test_shared_charge_is_overlap_not_double_counted(self):
        members = (
            MemberIdentity(10, "a", "/user.slice", shared_charge_keys=("map-1",)),
            MemberIdentity(20, "b", "/user.slice/app", shared_charge_keys=("map-1",)),
        )
        result = classify_members("/user.slice", members)
        self.assertEqual([item.status for item in result], [ScopeStatus.OVERLAP, ScopeStatus.OVERLAP])
        self.assertEqual(result[0].overlap_keys, ("map-1",))
        self.assertFalse(full_scope_safe(result))

    def test_unknown_membership_defers(self):
        result = classify_members("/user.slice", (MemberIdentity(10, "a", None),))
        self.assertEqual(result[0].status, ScopeStatus.UNKNOWN)
        self.assertFalse(full_scope_safe(result))

    def test_outside_member_does_not_make_scope_unsafe(self):
        result = classify_members("/user.slice", (MemberIdentity(10, "a", "/system.slice"),))
        self.assertEqual(result[0].status, ScopeStatus.OUTSIDE)
        self.assertTrue(full_scope_safe(result))

    def test_duplicate_identity_is_rejected(self):
        members = (MemberIdentity(10, "a", "/user.slice"), MemberIdentity(10, "a", "/user.slice/app"))
        with self.assertRaises(ScopePlanError):
            classify_members("/user.slice", members)

    def test_scope_must_be_absolute(self):
        with self.assertRaises(ScopePlanError):
            classify_members("user.slice", (MemberIdentity(10, "a", "/user.slice"),))


if __name__ == "__main__":
    unittest.main()
