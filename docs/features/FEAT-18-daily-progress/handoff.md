# Handoff: FEAT-18 — Progress per day
Branch: feat/FEAT-18-daily-progress · PR: https://github.com/codeforests/number-ninja/pull/28 · Updated: 2026-11-20 by verify
Stage done: verify (accepted, code `b576412`)
Next: merge on Ken's go, then release APK (CI workflow_dispatch on main) — no further stage.

## What the next stage needs
- verify.md has the evidence and three nits (not blocking).
- `parent_layout_test.dart` `open()` now sets the size after `openParent` (before, every parent layout case ran at 1280×800). FEAT-19 (responsive parent pages) should rebase on this: its small-size cases will now really run small.

## Left to CI or later
- APK build in CI. Tablet look by Ken after release.

## Pending for Ken
- Merge PR #28, then the APK release.
