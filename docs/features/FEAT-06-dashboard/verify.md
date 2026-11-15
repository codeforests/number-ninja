# FEAT-06: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `a03a078` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone of `feat/FEAT-06-dashboard`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (no schema change, as designed) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 574 tests |
| CI run [43692238934](https://github.com/codeforests/number-ninja/actions/runs/43692238934) (`a03a078`) | success (incl. APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `stats_test.dart` "tallies": accuracy, 120 s capped average and counts per topic and track; `since`/`includes` at exactly 7 and 30 days (and 1 ms before); `withBankTopics` skips an unknown id and counts a mixed-in question for its own topic. `stats_repository_test.dart`: the same join and filters on Drift, `since` inclusive. | pass |
| AC-2 | `stats_test.dart` "needs practice": 9 attempts at 0 % not listed; 69.2 % listed, exactly 70 % (10 attempts) not; slower than overall listed; lowest accuracy first, then id. | pass |
| AC-3 | `stats_test.dart` "weekly trend": Monday 00:00 start, Sunday 23:59 in the week before, 1 Nov 2025 in the week of 27 Oct, a week spanning 30 Nov–1 Dec; 8 points ending this week, empty weeks null. | pass |
| AC-4 | `round_builder_test.dart` "mix-in": 2 + 8, no repeats, random positions, prefers not-recently-correct, short topic filled by own topic. `mix_in_test.dart` (controller): 29 days ago gives 2 questions, 31 days none, never own topic, never Olympiad. `stats_repository_test.dart`: School only. Mix-in level comes from `levelFor(mixTopic)` (`quiz_controller.dart:96`). | pass |
| AC-5 | `dashboard_test.dart`: SCR-11 → Progress → SCR-09 with P2 card 71 % / 24 answers / 5.0 s, empty P1/Olympiad cards, needs-practice money only, both charts, topic rows and flag; 7 days changes to 65 % / 20; empty state; PIN guard. | pass |
| AC-6 | `topic_detail_reset_test.dart` "SCR-10": most missed ordered 3, 2, 1 wrong with prompt and answer; slowest first with "avg 32.5 s"; period passed on; back to SCR-09. | pass |
| AC-7 | `topic_detail_reset_test.dart` "reset": wrong PIN deletes nothing; right PIN empties the four tables, PIN, limit and usage kept, home shows 0 stars and Level 1, a new round saves; 5 wrong PINs lock out and delete nothing. Data part in `stats_repository_test.dart`. | pass |
| AC-8 | `parent_layout_test.dart`: SCR-09, SCR-10 and reset at the six FEAT-04 sizes and text scale 1.3 via `layout_checks.dart`. Earlier tests pass unchanged. | pass |

## Beyond the tests

- **Mutation checks** (scratch clone, reverted), all 9 caught: needs-practice `<=` 70 %; no time cap; week starting Sunday; minimum 9 attempts; mix-in in Olympiad rounds; Olympiad topic as mix-in source; reset keeping `play_sessions`; reset keeping `badges_earned`; mix-in window 7 instead of 30 days.
- **Rules.** `lib/domain/stats.dart` imports only `topics.dart` (pure Dart); the clock is injected into `StatsRepository` (NFR-08); new screens take colours and sizes from `theme.dart` (no hex colours or literal font sizes found).
- **Build deviations** in `design.md` fit PAR-05..08 and PAR-10.

## Test diff review

Nine test files changed against `main`, 1103 lines added, none removed; `round_builder_test.dart` only gained the mix-in group. No `skip:`, no assertion loosened.

## Notes (not blocking)

1. SCR-10's per-topic trend chart is checked for layout (AC-8) but its values aren't asserted; it reuses `weeklyTrend`, which AC-3 covers.
2. The mix-in tests use one level, so "at the mix-in topic's own level" is checked by code reading, not a test.
3. Ken's M3 tablet check comes after FEAT-08.
