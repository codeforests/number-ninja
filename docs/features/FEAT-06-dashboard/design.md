# FEAT-06: Parent dashboard

> Implements: PAR-05..08, PAR-10, design §5 "needs practice" mix-in (PRC-08) · Screens: SCR-09 (dashboard), SCR-10 (topic detail), SCR-11 (link, reset), SCR-04 (mix-in)
> Status: designed (T1–T7) · Branch: `feat/FEAT-06-dashboard` · 2026-11-15

## Scope

Behind the PIN, the parent opens a dashboard (SCR-09) from SCR-11. For a chosen period (7 days, 30 days, all time) it shows per-track and per-topic accuracy, average seconds per question and attempts (PAR-05), weekly trends of accuracy and speed per track (PAR-06) and the "needs practice" topics (PAR-07). Tapping a topic opens SCR-10 with its own weekly trend and its most-missed and slowest questions (PAR-08). SCR-11 gets "Reset all progress", confirmed with the PIN (PAR-10). School-track rounds mix in up to 2 questions from a needs-practice School topic (design §5, moved here by the FEAT-03 design). No schema change: everything is computed from `attempts` joined to the bank (design §4).

Not in scope: PDF export (PAR-09, FEAT-07, which reuses this feature's stats), badges (FEAT-08), screen-time history, per-question drawn visuals on SCR-10 (prompt text only).

## Design decisions (this feature)

- **Navigation:** the PIN still lands on SCR-11 (so the FEAT-05 lock → PIN → extra time path is unchanged). SCR-11 gets a "Progress" tile at the top → `/parent/dashboard` (SCR-09); a topic row → `/parent/topic/:topicId` (SCR-10). Both sit under `/parent`, so the PIN redirect and "doesn't count as screen time" already apply.
- **What counts:** every saved attempt, including those in quit rounds. A topic's stats use the topic of the *question* (bank lookup by `question_id`), not the round's topic, so mixed-in questions count for their own topic. Attempts whose question id is not in the bank are skipped.
- **Period (PAR-05):** rolling, from the injected clock: 7 days = `answered_at >= now − 7 days`, 30 days likewise, all time = everything. Default 30 days. The period applies to the stats table, track summary, needs-practice list and SCR-10 lists; trends always show the last 8 weeks.
- **Speed:** average seconds = mean of `time_ms` over attempts, with each attempt capped at 120 s (`timeCap`), so one question left open while she walked away doesn't swing an average. Shown with one decimal.
- **Tracks (PAR-06):** the three design §2 tracks P1, P2, Olympiad (`Track` enum).
- **Weekly trend (PAR-06):** weeks start Monday 00:00 local time; 8 points ending with the current week; a week with no attempts is a gap (null), not zero.
- **Needs practice (PAR-07):** a topic with ≥ 10 attempts in the period and accuracy < 70 % or average seconds > her overall average (all topics, same period). Sorted by accuracy, lowest first, then topic id.
- **Mix-in (design §5):** when a School-track (P1 or P2) round starts, take needs-practice School topics over the last 30 days other than the round's topic; if any, the first one (the order above) gives up to 2 questions at *its* current level (same `buildRound` rules: not recently correct first), and the round's own topic fills the other 8. The 2 go in random positions. They count in the round's score and stars like any other question; she can't tell them apart. Olympiad rounds never mix in. If the bank lacks questions, the round's own topic fills up to 10.
- **Charts:** a small `CustomPainter` line chart in `lib/ui/trend_chart.dart` instead of adding fl_chart: two charts (accuracy 0–100 %, seconds 0–max), one line per series, dots on points, gaps for null weeks, a legend, week labels "d MMM". Colours from `theme.dart` (new `AppColors.trackP1/trackP2/trackOly`). This avoids a dependency that may not build against the `material_ui` split, and FEAT-07 draws its PDF charts with the `pdf` package anyway (design §1 stack row to be updated).
- **Reset (PAR-10):** SCR-11 "Reset all progress" (key `reset-progress`) → `/parent/reset`: a warning text and the PIN pad; the correct PIN (same `PinRepository.verify`, so PAR-03 lockout applies) deletes all `attempts`, `rounds`, `play_sessions` and `badges_earned` rows in one transaction, then shows a SnackBar "Progress reset" on SCR-11. Kept: PIN, daily limit and `daily_usage` (resetting must not give screen time back, TIM-05). A wrong PIN deletes nothing. Cancel returns to SCR-11.

## Design

- **Domain** (`lib/domain/stats.dart`, pure Dart):
  - `AttemptRecord {questionId, topicId, correct, timeMs, answeredAt}`.
  - `enum StatsPeriod { days7, days30, all }` with `DateTime? since(DateTime now)` and a `label`.
  - `Tally {attempts, correct, totalMs}` (capped ms) with `accuracy` (0–1, null at 0 attempts), `avgSeconds` (null at 0); `const timeCap = Duration(seconds: 120)`.
  - `Map<String, Tally> byTopic(Iterable<AttemptRecord>)`, `Map<Track, Tally> byTrack(...)`, `Tally overall(...)`.
  - `List<String> needsPractice(Map<String, Tally>, Tally overall, {int minAttempts = 10, double below = 0.7})`.
  - `DateTime weekStart(DateTime)`; `List<WeekPoint> weeklyTrend(Iterable<AttemptRecord>, DateTime now, {int weeks = 8})`, `WeekPoint {weekStart, Tally}`.
  - `QuestionTally {questionId, Tally}`; `mostMissed(records, {n = 5})` (wrong count desc, then wrong rate desc, then id; only questions with ≥ 1 wrong), `slowest(records, {n = 5})` (avg desc, then id).
  - `round_builder.dart`: `buildRound(...)` gains optional `List<Question> mixIn = const []` (already picked, ≤ 2): result = `mixIn` + own-topic picks up to `size`, then shuffled with `random`. A new `pickMixIn({candidates, level, recentCorrect, random, count = 2})` reuses the same preference.
- **Data** (`lib/data/stats_repository.dart`): `StatsRepository(AppDatabase, QuestionBank, {Clock clock})`: `records({DateTime? since, String? topicId})` reads `attempts` (filtered by `answered_at`) and maps through the bank; `Future<void> resetProgress()` (transaction above). `statsRepositoryProvider` (async, needs `bankProvider`) in `providers.dart`. Quiz start uses it to find the mix-in topic: `needsPractice` over `StatsPeriod.days30`, School topics only, minus the round's topic; then `levelFor` and `recentCorrectIds` of that topic.
- **SCR-09** (`lib/features/parent/dashboard_screen.dart`): AppBar "Progress" with back to SCR-11. `SegmentedButton<StatsPeriod>` (key `period-7`, `period-30`, `period-all`). Track summary row: three cards P1 / P2 / Olympiad (keys `track-p1` …) with accuracy %, avg s, attempts. "Needs practice" list (key `needs-practice`; "Nothing yet. Needs 10+ answers in a topic." when empty), each item tappable → SCR-10. Two trend charts (key `trend-accuracy`, `trend-speed`) for the three tracks. Topic table: one row per topic grouped by track (key `topic-row-<id>`): name, accuracy, avg s, attempts ("–" when none), a flag icon if needs practice; tap → SCR-10. Empty state (no attempts at all): "No answers yet. Stats appear after her first round." Landscape ≥ 900 dp wide: summary + needs practice + charts on the left, table on the right; otherwise one scrolling column.
- **SCR-10** (`lib/features/parent/topic_detail_screen.dart`): title = topic name, its tally for the period (period passed as query `?p=7|30|all`, default 30), its two trend charts (one series), "Most missed" (key `most-missed`: prompt, "wrong W of N", the correct answer) and "Slowest" (key `slowest`: prompt, "avg S s"). Prompts are plain text, at most 2 lines, ellipsis.
- **SCR-11:** "Progress" tile (key `open-dashboard`) at the top; "Reset all progress" tile (key `reset-progress`, error colour) at the bottom. Reset screen `lib/features/parent/reset_screen.dart` with the PIN pad (`lib/ui/pin_pad.dart`).
- **Theme:** add track colours to `AppColors`; no hard-coded colours or sizes in the new screens.

## Acceptance criteria

- **AC-1** (PAR-05): `stats.dart` unit tests: accuracy, capped average and counts per topic and per track; period filters at exact 7- and 30-day boundaries with an injected clock; attempts of an unknown question id are skipped; a mixed-in question counts for its own topic.
- **AC-2** (PAR-07): needs-practice tests: 9 attempts never listed; 10 at 69 % listed, 70 % not; slower than overall average listed; order lowest accuracy first.
- **AC-3** (PAR-06): `weeklyTrend` tests: Monday week start (including a Sunday-night attempt and a week across a month end), 8 points, empty weeks null.
- **AC-4** (PRC-08, design §5): round builder tests: with a needs-practice School topic, a School round has exactly 2 questions from it and 8 from its own topic, no repeats; none when no topic qualifies, when the only one is the round's own topic, or for an Olympiad round; the controller test shows the mix-in topic comes from 30-day stats.
- **AC-5** (PAR-05..07): widget test with seeded attempts: SCR-11 → Progress shows SCR-09 with the expected track cards, topic rows, a needs-practice entry and both charts; switching to 7 days changes the numbers; with no attempts the empty state shows.
- **AC-6** (PAR-08): tapping a topic row opens SCR-10 with its most-missed (ordered by wrong count) and slowest questions and their prompts.
- **AC-7** (PAR-10): reset with a wrong PIN deletes nothing; with the right PIN `attempts`, `rounds`, `play_sessions` and `badges_earned` are empty while the PIN, daily limit and today's `daily_usage` remain; home stars and levels go back to none / level 1; 5 wrong PINs trigger the PAR-03 lockout.
- **AC-8** (NFR-09): SCR-09, SCR-10 and the reset screen at the six FEAT-04 sizes and text scale 1.3: no exception or overflow (`test/ui/layout_checks.dart`; the 64 dp / 20 sp child-screen checks don't apply to parent screens). Existing tests pass unchanged.

## Tasks

- [x] T1 — Domain `stats.dart` (records, periods, tallies, needs practice, weekly trend, most missed, slowest).
      Done when: `scripts/check.sh 'flutter test test/domain/stats_test.dart'` passes with the AC-1..3 tests.
- [x] T2 — Data `StatsRepository` (`records`, `resetProgress`) and provider.
      Done when: Drift tests on an in-memory DB for `records` filters and the AC-7 data part pass, with existing `test/data`.
- [x] T3 — Mix-in: `pickMixIn`, `buildRound(mixIn:)`, wiring in `QuizController.start`.
      Done when: AC-4 tests and `flutter test test/domain test/features/quiz` pass.
- [ ] T4 — `TrendChart` painter in `lib/ui/trend_chart.dart`, track colours in the theme.
      Done when: a widget test paints 3 series with gaps without exceptions and shows the legend.
- [ ] T5 — SCR-09 dashboard, route, SCR-11 Progress tile.
      Done when: AC-5 widget tests pass.
- [ ] T6 — SCR-10 topic detail; reset screen and SCR-11 tile.
      Done when: AC-6 and AC-7 widget tests pass.
- [ ] T7 — AC-8 layout checks; update design §1 stack row and §9; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
