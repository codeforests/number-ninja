# Handoff: FEAT-05 — Screen-time lock
Branch: feat/FEAT-05-screen-time · PR: none · Updated: 2026-11-15 by design
Stage done: design
Next: build — kickoff: "Build FEAT-05 (from T1) on branch feat/FEAT-05-screen-time. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- Read `design.md` here (all of it, 70 lines); design §4–§5 of `docs/02-design.md` for the tables and the clock rule. No schema change.
- Only child routes count (home, `/play`, `/quiz`, `/result`, `/locked`); PIN entry and `/parent*` don't (§9 row 2026-11-15).
- Keep timers out of the domain: `ScreenTimeClock.flush()` is driven by the controller's `Timer.periodic`; widget tests can drive it with `tester.pump(Duration(seconds: 10))` plus a fake elapsed source and clock.
- `redirectFor` gains the screen-time argument: update its existing tests in `test/features/pin_flow_test.dart` without weakening them.
- Test helpers that build the app (quiz_harness.dart, layout tests) need a `screenTimeProvider` override with a large allowance so existing tests don't lock.
- Gotchas carried from FEAT-04: Ahem test font is wide (use Wrap/FittedBox on narrow rows); layout helpers in `test/ui/layout_checks.dart`.

## Left to CI or later
- APK build (CI only). Ken's M2 tablet check after merge: lock after the limit, PIN unlock, NFR-09 on a small device.

## Pending for Ken
- None blocking. FYI: moving the tablet clock forward starts a new day (out of scope; Android's settings lock covers it).
