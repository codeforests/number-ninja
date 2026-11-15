# Handoff: FEAT-05 — Screen-time lock
Branch: feat/FEAT-05-screen-time · PR: [#6](https://github.com/codeforests/number-ninja/pull/6) (draft) · Updated: 2026-11-15 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-05 on branch feat/FEAT-05-screen-time. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- Read `design.md` here, including "Build deviations": SCR-07 itself doesn't count; `redirectFor(session, locked, location)`; router refreshes only on `lockedListenable`; holds live in `QuizScreen`/`ResultScreen`; `elapsedProvider` is the test seam.
- Code: `lib/domain/screen_time.dart`, `lib/data/usage_repository.dart`, `lib/features/screen_time/` (controller, lock screen), `app.dart` (route, redirect, warning SnackBar), `home_screen.dart`, `parent_screen.dart`, `quiz_screen.dart`, `result_screen.dart`.
- Tests per AC: AC-1 `test/domain/screen_time_test.dart`; AC-2 `test/data/usage_repository_test.dart` (+ effectiveDay in the domain test); AC-3/AC-6 `test/features/screen_time/lock_test.dart`; AC-4 `grace_test.dart`; AC-5 `parent_time_test.dart`; AC-7 `lock_layout_test.dart`.
- Test helper changes: `QuizHarness` got `elapsed`, `run(d)` (moves clock and elapsed), `more` overrides; `pin_flow_test.dart` overrides `elapsedProvider` with zero and passes `false` for `locked` in its redirect asserts.
- Gotcha: refreshing GoRouter while on `/result` loses `extra` and bounces home, so don't put the whole controller in `refreshListenable`.
- Local run: `scripts/check.sh` all PASS, 507 tests.

## Left to CI or later
- APK build and CI on PR #6. Ken's M2 tablet check after merge: lock after the limit, PIN unlock, NFR-09 on a small device; then publish `m2`.

## Pending for Ken
- None blocking. FYI: moving the tablet clock forward starts a new day (Android's settings lock covers it).
