# Handoff: FEAT-26 — Parent first-run setup
Branch: feat/FEAT-26-first-run-setup · PR: https://github.com/codeforests/number-ninja/pull/33 · Updated: 2026-11-20 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-26 on branch feat/FEAT-26-first-run-setup. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Build decisions AD-14 (resume asks for the PIN whenever a PIN is set; Back moves are saved) and AD-15 (small deviations: `syncOnce` returns `SyncStatus`, "Skip for now" label, `ChildRepository.blank`, `ParentButton`) in design.md.
- T1–T4 landed as one commit (the router change needs the new screen to compile); T5 tests, T6 layout + docs separate.
- Tests: `test/features/setup/setup_flow_test.dart` (AC-1..4), `setup_layout_test.dart` (AC-6), `test/data/migration_test.dart` group `v10` (AC-5), `test/domain/setup_test.dart`. Helper `setup_harness.dart`.
- Changed old tests' setup only: `pin_flow_test.dart` (AC-1 cases now reach the PIN through Welcome; app session from the setup step), `profile_flow_test.dart` (first-run cases now on the Children step behind the resume PIN; redirect test on `inSetup`), `QuizHarness.session`, `AppSession(hasPin: true, …)` → `AppSession(…)` in two tests. SCR-12/SCR-13 tests unchanged.
- `scripts/check.sh` all PASS at the end of build.

## Left to CI or later
- CI has not run on PR #33 yet (every build push carried [skip ci]): verify runs it, incl. the APK build (no Android SDK here). AC-7 is Ken's optional tablet check.

## Pending for Ken
- none
