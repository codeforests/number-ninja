# FEAT-30: Verify

> Verdict: **accepted** (2026-11-20, auto mode). Verified at build head `b65238d`; this stage only adds docs.

## Checks re-run here

- `build_runner build` left no diff.
- `scripts/check.sh` on `b65238d`: format, analyze and the full `flutter test` PASS.
- APK build and manifest check: CI on the final head (PR #36). No new plugin or Android config.
- Not run: AC-9 (live, needs the FEAT-29 server deploy with the M9 release; see handoff).

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `test/domain/plus_test.dart` group `plusActive`: no cache, on, 7 d / 7 d + 1 min, clock back 9 / 11 min, 2 h skew with until 1 h ahead, plus false, until reached. |
| AC-2 | pass | `plus_repository_test.dart`: refresh stores, offline keeps, 401 clears, another account replaces (even offline); `PlusController`: launch signed in refreshes, sign-out clears, sign-in refreshes, account delete clears, check again. `migration_test.dart` group v12. |
| AC-3 | pass | `plus_gates_test.dart` free/Plus pairs: SCR-09 day card, trends, PDF; SCR-10 weak types and trends; SCR-16 day view; SCR-11 PDF and bank row. `revision_free_test.dart`: SCR-05 no offer, `/revise/mixed` goes home. Plus paths unchanged in the older tests (harness default `plus: true`). |
| AC-4 | pass | `siblings_free_test.dart`: `pickerShows` needs Plus, no chip and no SCR-17 on free, chip back with Plus; SCR-18 paused rows, "Make active" switches child and `current()`, Add opens SCR-20, children and rounds rows unchanged. `setup_flow_test.dart` "one child on free, more with Plus". |
| AC-5 | pass | `revision_free_test.dart`: lock card on SCR-02, sheet with one OK and no price/`$`/store/parent link; no lock without revision due; none on SCR-05. |
| AC-6 | pass | `plus_screen_test.dart`: signed out (Sign in opens SCR-13), free, forever, renewing, ending, billing issue, offline "Last checked 3 days ago", Check again calls the server, reached from SCR-11 and a Plus card, PIN first. |
| AC-7 | pass | same file: unavailable service shows "coming soon" and no `FilledButton`; a fake available service lists the offer and records `buy('yearly')`. |
| AC-8 | pass | `bank_updater_test.dart` "free: no server call": `noPlus`, empty `bankLog`, version kept; Plus then downloads. |
| AC-9 | live, later | with the M9 release, not required to merge. |

## Beyond the tests

- Changed older tests: `sound_switch_test` scrolls to its row and `parent_time_test` pumps after `ensureVisible` (SCR-11 grew a Plus row); `migration_test` version pins 11 → 12. No assertion weakened or skipped.
- Read `plus.dart`, `plus_repository.dart`, the v12 migration (runs after the `_from6To7` rebuild, which doesn't touch `plus_state`), `entitlement()` and the bank gate. Clock is a parameter everywhere except `Entitlement.fromJson`'s fallback when the server omits `checked_at` (FEAT-29 always sends it).
- **Follow-up (not a fail):** the launch bank check runs in a post-frame callback and reads `plusProvider`, which is false while `plusCacheProvider` is still loading, so a Plus family's launch check can return `noPlus` and the update waits for the next resume or "Check now". Fix in the next Plus feature: `checkBank` awaits `plusCacheProvider.future` first (code-map gotcha).
- `plusProvider` is evaluated when the cache changes, not on a timer, so Plus ending mid-session takes effect at the next refresh, sync or launch. Acceptable for a 7-day grace.
