# Handoff: FEAT-19 — Phone layout
Branch: claude/project-thread-tnfd5g · PR: #29 · Updated: 2026-11-20 by verify
Stage done: verify (accepted, code `27eff7b`)
Next: Ken merges PR #29, then a release APK (workflow_dispatch on main).

## What the next stage needs
- PR #28 (FEAT-18) fixes the same `openParent` size bug differently (`34efbdb`): the second to merge rebases `parent_harness.dart`, `parent_layout_test.dart` and code-map Gotchas.
- Everything is behind `compact(size)` (shorter side < 600 dp); tablet paths are the old code.

## Left to CI or later
- APK build (CI on PR #29). Real-phone check by Ken.

## Pending for Ken
- Merge PR #29; try the APK on a phone (portrait and landscape) and on the tablet.
