# FEAT-18: Progress per day

> Implements: PAR-11 · Screens: SCR-16 (new: one day), SCR-09 (new "By day" card)
> Status: built · Branch: `feat/FEAT-18-daily-progress` · 2026-11-20

## Scope

SCR-09 sums a rolling period (7 days, 30 days, all time). Ken asked to see one specific day: pick a date, and see that day's answers, accuracy, speed and screen time, per topic, the rounds she played and each question with her answer (PAR-11).

Not in scope: changing SCR-09's period sums or the PDF report; a month calendar view; responsive changes to the other parent screens (a separate thread). SCR-16 is built to the NFR-09 rules from the start.

## Design decisions (this feature)

- **A day** is a local calendar day of `attempts.answered_at`, keyed `yyyy-MM-dd` with `dayKey` (`screen_time.dart`), the same key `daily_usage` uses. A round that crosses midnight shows on both days, with that day's answers only.
- **Screen time** for the day = `daily_usage.seconds_used` summed over every device row of that day (synced rows from her other tablets count), shown in whole minutes. Extra time granted is not shown.
- **Topic of an answer** is the bank topic of its question, as on SCR-09 (a mix-in question counts for its own topic). An answer whose question is not in the bank falls back to its round's topic and shows its id instead of a prompt.
- **Read on demand**: `StatsRepository.day(String day)` queries one day; no stored summaries, no schema change. The provider watches `syncDataVersionProvider` like `statsDataProvider`.
- **Navigation on SCR-16**: back to SCR-09; arrows step one calendar day; the date button opens Material's date picker (first date: her first answer's day, or 1 year back with none; last: today). Next is disabled on today. Default day (no `d`): today.
- **SCR-09 "By day" card** (`daily-card`): the 7 latest days with answers, newest first (date, answers, % right, s per question), each opening SCR-16; a "Pick a day" button opens today. Days come from `StatsData.all`, so the card needs no new query. It shows even when the period picker excludes those days (it's a shortcut, not part of the period sums).

## Design

- **Domain** (`lib/domain/daily.dart`): `({DateTime start, DateTime end}) dayBounds(String day)` (local midnight to next local midnight, DST-safe via `DateTime(y, m, d + 1)`); `DayAnswer` (`AttemptRecord record`, `String given`); `DayRound` (`int id`, `String topicId`, `int level`, `bool revision`, `DateTime startedAt`, `DateTime? finishedAt`, `int score`, `int stars`, `int durationMs`, `List<DayAnswer> answers`); `DayDetail` (`String day`, `List<DayRound> rounds` by `startedAt`, `int secondsUsed`) with `records`, `tally` (`overall`), `topics` (`byTopic`); `List<({String day, Tally tally})> recentDays(Iterable<AttemptRecord>, {int limit = 7})`.
- **Data** (`stats_repository.dart`): `Future<DayDetail> day(String day)` reads attempts in `dayBounds`, their rounds, and the day's `daily_usage` rows; `Future<String?> firstDay()` (earliest attempt's day). Revision = `rounds.kind == roundKindRevision`.
- **SCR-16** (`lib/features/parent/day_screen.dart`, `DayScreen(day:)`, `dayDetailProvider` family, `parent-day` route `day?d=`; `Routes.day(String)`): back key `back-dashboard`; header `day-prev`, `day-pick` (label `EEE d MMM yyyy`), `day-next`; cards `day-summary` (answers, right, per question, minutes, rounds), `day-topics` (row `day-topic-<id>`: name, answers, %, s), `day-rounds` (tile `day-round-<id>`: "09:14 · Money · Level 2 · 7/10", revision tag, duration; expands to rows `day-answer-<attemptIndex>` with prompt, her answer, right answer when wrong, ✓/✗ icon, seconds). Empty day: `day-empty` "No answers on this day." (screen time still shown). One column, centred, at most 900 dp wide, text wraps, rows wrap on narrow screens.
- **SCR-09** (`dashboard_screen.dart`): `_DailyCard` after the track summary; rows `daily-<yyyy-MM-dd>`, button `open-day`. Hidden in the empty state like the rest.
- Shared: `answerText` (was `_answer` in `topic_detail_screen.dart`) moves to `stats_view.dart`.

## Acceptance criteria

- **AC-1** (domain): `test/domain/daily_test.dart`: `dayBounds` covers local midnight to midnight (and a 23 h/25 h DST day isn't assumed 24 h); `recentDays` returns the 7 latest days with answers newest first with right tallies; `DayDetail.tally`/`topics` add up its answers.
- **AC-2** (data): `test/data/stats_day_test.dart`: `day()` returns only answers from that local day (23:59 yes, 00:00 next day no), groups them by round with level, score, stars, revision; sums `daily_usage` over two device rows; an unknown question id falls back to its round's topic; `firstDay()` is the earliest answer's day or null.
- **AC-3** (PAR-11, SCR-16): widget tests: with seeded rounds today and 2 days ago, `/parent/day?d=<today>` shows the summary figures, topic rows and rounds; expanding a round shows her answer and the right answer for a wrong one; `day-prev` twice reaches the older day; `day-next` is disabled on today; `day-pick` opens the date picker; a day with no answers shows `day-empty` and its screen-time minutes.
- **AC-4** (SCR-09): the "By day" card lists seeded days newest first, at most 7; tapping `daily-<day>` opens SCR-16 for that day; `open-day` opens today; back returns to SCR-09.
- **AC-5** (NFR-09): SCR-16 (with an expanded round) and SCR-09 pass the six FEAT-04 sizes and text scale 1.3 in `parent_layout_test.dart`. Existing tests pass unchanged.

## Tasks

- [ ] T1 Domain `daily.dart` + `StatsRepository.day`/`firstDay` (AC-1, AC-2).
- [ ] T2 SCR-16 screen, provider, route (AC-3).
- [ ] T3 SCR-09 "By day" card (AC-4).
- [ ] T4 Layout cases, code-map, requirements row, STATE (AC-5), full `scripts/check.sh`, draft PR.
