# Handoff: FEAT-19 — Phone layout
Branch: claude/project-thread-tnfd5g · PR: (see STATE) · Updated: 2026-11-20 by build
Stage done: build (T1–T2 of 2)
Next: verify — kickoff: "Verify FEAT-19 on branch claude/project-thread-tnfd5g. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Branch name is the thread's branch, not feat/FEAT-19-…, because this session may push only there.
- Everything is behind `compact(size)` (shorter side < 600 dp); tablet paths are the old code.
- Shared test helper change: `expectNoOverlap` clips to the nearest Scrollable; `expectInView` added; Roboto loader moved to `test/ui/roboto.dart`.
- `openParent` used to reset the view to 2560 × 1600: `parent_layout_test` now really runs at the six sizes (it passes).

## Left to CI or later
- APK build (no Android SDK here). Real-phone check by Ken.

## Pending for Ken
- Try the test APK on a phone (portrait and landscape) and on the tablet.
