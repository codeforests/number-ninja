# FEAT-26: Verify

## Re-verify (2026-11-20, auto mode)

> Verdict: **accepted**. Re-verified `8f74de9..7cc107a` (R1 fix in `children_step.dart`, AD-16).

- R1 / AC-1: **pass**. `onBack` stays on while the form is open with no child; with children it stays off and Cancel returns to the list. `AC-1: Back on an empty Children step (verify)` now passes.
- AC-6: **pass**. `setup_layout_test.dart` passes with Back shown on the open form.
- `flutter test test/features/setup/` 18 pass; full `scripts/check.sh` PASS (format, analyze, all tests). CI on the head: see PR #33.
- Not redone: clean clone, ACs that already passed. AC-7 stays Ken's optional tablet check.

> Verdict: **rework** (2026-11-20, auto mode). Code verified at `8f74de9`. One AC-1 failure: an empty Children step has no Back. Everything else passes. This stage added three tests to `test/features/setup/setup_flow_test.dart`; one fails on purpose until the fix.

## Rework

- **R1 (AC-1, SET-02 "Back on every step")**: when the Children step has no child yet it opens the form at once (`_reload(openIfEmpty: true)`), and `children_step.dart:245` passes `onBack: null` while editing, and Cancel only shows when `kids.isNotEmpty`. So a parent who tapped "Skip for now" by mistake (or resumes there with no child) can't go back to sign in. Fix: keep Back (to Account) available on the empty form, at least when no child exists. Failing test: `AC-1: Back on an empty Children step (verify)`. Check that AC-6 layout still passes with the button shown on the open form.

## Checks re-run here

- `build_runner build` and `tool/generate_bank.dart` left no diff.
- `scripts/check.sh` on the build head: format and analyze PASS; full `flutter test` 1,340 built tests pass; only the verify tests added here failed at first (see below).
- Not run here: APK build (no Android SDK), runs in CI after the fix.

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | **fail (R1)** | Full path, PIN mismatch, AD-5 and Back from Account/Done pass (`AC-1: the whole path`); added `AC-1: Back works on every step` (Pin→Welcome, Time→Children→Account→PIN→Welcome, PIN kept) passes; empty Children step has no Back (R1). |
| AC-2 | pass | `AC-2: a kill at each step…` reopens at every step, resume PIN, wrong PIN, Mia not doubled; lockout test as PAR-03. |
| AC-3 | pass | Restore with Mia and Leo → Done names both, Leo's limit 45, launch shows SCR-17; empty account and a server that never answers → Children. Added: a one-off server error is retried inside the same sync and the family still comes back. |
| AC-4 | pass | `AC-4: add up to 4, edit, remove; Next needs a child`. |
| AC-5 | pass | `migration_test.dart` group `v10` (welcome / children / NULL / fresh); launch with NULL goes home (end of AC-2 test). |
| AC-6 | pass | `setup_layout_test.dart` every step at the six sizes and 1.3 text scale, 4 longest names, buttons ≥ 56 dp; SCR-12/SCR-13 tests unchanged and passing. |
| AC-7 | live, Ken, optional | not run. |

## Beyond the tests

- Old tests' changes are setup only (handoff list), no assertion removed.
