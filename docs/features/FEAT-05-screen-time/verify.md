# FEAT-05: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `b9f74cb` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone of `feat/FEAT-05-screen-time`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (no schema change, as designed) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 507 tests |
| CI run [43673301798](https://github.com/codeforests/number-ninja/actions/runs/43673301798) (`b9f74cb`) | success (incl. APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `screen_time_test.dart` "ScreenTimeClock": counts only between `start`/`stop`, carries sub-second remainders, crosses midnight into the new day, clock set back a day keeps adding to the later day; start/stop idempotent. | pass |
| AC-2 | `usage_repository_test.dart`: used seconds survive closing and reopening `AppDatabase` on a file; `effectiveDay` for earlier, same and later dates in the domain test. | pass |
| AC-3 | `lock_test.dart`: 19:50 used shows "1 min left"; 10 counted s later SCR-07; `/`, `/play/school`, `/quiz/<id>` land on SCR-07; next morning home shows "20 min left" and yesterday stays at 1200 s. Android back stays on SCR-07; Parent opens PIN entry. | pass |
| AC-4 | `grace_test.dart`: warning SnackBar once at 120 s left (≥ 22 sp, gone after 6 s, not repeated); mid-question she answers and sees feedback, Next shows SCR-07 and the round stays quit; 10th question goes to SCR-05, then Home and Play again go to SCR-07; open question locks exactly at `graceCap`; Quit in grace goes to SCR-07. | pass |
| AC-5 | `parent_time_test.dart`: SCR-07 → PIN → SCR-11 → +10 min → Done shows "10 min left", `extra_seconds_granted` 600; wrong PIN keeps the lock; stepper +5 saves 25 to `app_settings` and unlocks today, stops at 120 and 5 (buttons disabled). | pass |
| AC-6 | `lock_test.dart` "AC-6": PIN entry, SCR-11 and a hidden app add nothing; home and resume count again (30 → 50 → 65 s). | pass |
| AC-7 | `lock_layout_test.dart`: SCR-07 and SCR-02 with minutes left at the six FEAT-04 sizes and 1.3 text scale, via `layout_checks.dart`. FEAT-03/04 tests pass unchanged. | pass |

## Beyond the tests

- **Mutation checks** (scratch clone, reverted), each caught: grace never expiring fails AC-4; ignoring the latest recorded day fails AC-1/AC-2; counting PIN entry fails AC-6; not stopping on hide fails AC-6; warning on every flush fails AC-4; no 5–120 clamp fails the data test.
- **Rules.** `lib/domain/screen_time.dart` imports only `clock.dart` (pure Dart); clock and elapsed time are injected (NFR-08); the SnackBar text size comes from `AppText.body`.
- **Build deviations** (SCR-07 not counted, `lockedListenable`, holds in the screens) are recorded in `design.md` and fit TIM-01..04.

## Test diff review

Six test files added. `pin_flow_test.dart` only gained the `locked` argument (`false`) in its redirect asserts and an `elapsedProvider` override; `quiz_harness.dart` only gained `elapsed`, `run` and `more`. No assertion removed or loosened, no `skip:`.

## Notes (not blocking)

1. Up to 10 s counted since the last flush is lost if Android kills the app without a hide event; this favours her by seconds, within TIM-05's intent.
2. PAR-03 lockout under the lock isn't re-tested here; it's the same PIN entry screen covered by `pin_flow_test.dart` "AC-3".
3. Moving the device clock forward starts a new day (out of scope; Android's settings lock covers it).
4. Ken's M2 tablet check after merge: lock after the limit, PIN unlock, NFR-09 on a small device; then publish `m2`.
