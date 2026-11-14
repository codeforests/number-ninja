# Number Ninja: Design

> Version 1.0 (signed off by Ken 2026-11-14) · 2026-11-14 · Implements [01-requirements.md](01-requirements.md)
> Changes after sign-off: add a row to §9 and edit in place; a decision that reverses another gets a new D-number in the requirements.

## 1. Architecture at a glance

One Flutter app, no server. Three layers, and code only calls downwards:

| Layer | Folder | Holds | May use |
|---|---|---|---|
| UI | `lib/features/<area>/` | Screens and widgets per area (home, quiz, parent, …) | domain, data, `lib/ui/` |
| Domain | `lib/domain/` | Pure Dart: question models, round builder, scoring, stars, screen-time clock, badge rules, stats | nothing from Flutter or the database |
| Data | `lib/data/` | Drift database, bank loader, repositories | domain models |

Shared UI pieces (theme, PIN pad, big buttons, drawn visuals) live in `lib/ui/`. State uses Riverpod providers; navigation uses go_router. The generator lives in `tool/` and is never shipped.

**Stack:** Flutter stable (3.50), Dart 3.14, flutter_riverpod, go_router, drift + drift_flutter (SQLite), fl_chart, pdf + printing, crypto. Exact versions are pinned in `pubspec.lock`.

## 2. Topics (BNK-02)

Topic ids are permanent, like requirement ids.

| Track | Topic id | Topic |
|---|---|---|
| P1 | `p1.place` | Numbers to 100: place value, compare, order |
| P1 | `p1.bonds` | Number bonds and missing numbers |
| P1 | `p1.groups` | Multiplication and division as equal groups |
| P1 | `p1.money` | Money in cents and dollars |
| P1 | `p1.time` | Time to the hour and half hour |
| P1 | `p1.measure` | Length and mass |
| P1 | `p1.shapes` | 2D shapes and patterns |
| P1 | `p1.graphs` | Picture graphs |
| P2 | `p2.place` | Numbers to 1000: place value, compare, order, odd and even |
| P2 | `p2.regroup` | Addition and subtraction within 1000 with regrouping |
| P2 | `p2.times` | Multiplication tables 2, 3, 4, 5, 10 |
| P2 | `p2.divide` | Division by 2, 3, 4, 5, 10 |
| P2 | `p2.fractions` | Fractions: halves to twelfths, compare, add like fractions |
| P2 | `p2.measure` | Length (m, cm), mass (kg, g), volume (ℓ) |
| P2 | `p2.money` | Money: dollars and cents, change |
| P2 | `p2.time` | Time: 5-minute steps, a.m./p.m., durations |
| P2 | `p2.shapes` | 2D and 3D shapes, patterns |
| P2 | `p2.graphs` | Picture graphs with scales |
| P2 | `p2.words` | Word problems (1–2 steps) |
| Olympiad | `oly.patterns` | Number and shape patterns |
| Olympiad | `oly.logic` | Logic puzzles |
| Olympiad | `oly.counting` | Counting: shapes, paths, arrangements |
| Olympiad | `oly.models` | Model drawing (bar models) |

The School track shows P1 and P2 topics; the Olympiad track shows `oly.*`.

## 3. Question bank (BNK-01..06)

- `tool/generate_bank.dart` holds 3–6 templates per topic plus a hand-written list for `oly.logic` and `oly.counting`. It writes `assets/questions/bank_v<N>.json` with a fixed seed and runs its validator before writing (BNK-04).
- Question JSON: `id` (e.g. `p2.fractions.cmp.017`), `topic`, `level` (1–3), `format` (`mcq` | `number` | `drag`), `prompt`, `visual` (optional typed object, e.g. `{"kind":"clock","h":3,"m":15}`), `options` (mcq), `answer`, `drag` (items and target slots, for drag), `explanation`.
- Ids are made from topic, template and a per-template counter that only grows, so v2 keeps v1's ids (BNK-05).
- Format mix target: about 45% mcq, 40% number, 15% drag.

## 4. Data model (Drift, `lib/data/database.dart`)

| Table | Columns | Notes |
|---|---|---|
| `app_settings` | id = 1, pin_hash, pin_salt, daily_limit_min (20), bank_version | One row, created on first open |
| `play_sessions` | id, started_at, ended_at | One per app opening |
| `rounds` | id, session_id, topic_id, level, started_at, score, duration_ms, stars | |
| `attempts` | id, round_id, question_id, answer_given, correct, time_ms, answered_at | Saved before the next question shows (NFR-05) |
| `daily_usage` | day (yyyy-MM-dd), seconds_used, extra_seconds_granted | Screen time per day |
| `badges_earned` | badge_id, earned_at | |
| `pin_lockout` | id = 1, failed_count, locked_until | PAR-03 |

Stats (PAR-05..08) are computed from `attempts` joined to the bank, never stored twice. Schema changes bump `schemaVersion` with a migration and a migration test.

## 5. Key rules

- **PIN (PAR-01..04):** 4 digits, hashed with SHA-256 over a random 16-byte salt, 10,000 rounds. Compared in constant time.
- **Screen-time clock (TIM-01..05):** a `ScreenTimeClock` in the domain layer takes `now()` and an elapsed-time source as parameters (NFR-08). It adds foreground seconds to today's `daily_usage` row every 10 seconds and on pause. "Today" is the later of the device date and the latest day already recorded, so moving the clock back cannot reopen a used day. Allowance = daily limit + extra granted today.
- **Stars (PRC-06):** 10/10 = 3 stars, 8–9 = 2, 6–7 = 1, else 0. Speed does not reduce stars, so she is never punished for being careful.
- **Round builder (PRC-08, PRC-09):** picks 10 questions at the topic's current level, preferring ones not answered correctly in her last 3 rounds; mixes in up to 2 questions from a "needs practice" topic on the School track.

## 6. Screens

| ID | Screen | Requirements |
|---|---|---|
| SCR-01 | First-run PIN setup | PAR-01 |
| SCR-02 | Home: two track cards, minutes left, latest badge, small parent button | PRC-01, TIM-06 |
| SCR-03 | Topic map: tiles with stars, grouped P1 / P2 or Olympiad | PRC-01, PRC-07 |
| SCR-04 | Quiz: question, visual, answer area, progress dots | PRC-02..05, PRC-10 |
| SCR-05 | Round result: score, time, stars, new badge | PRC-06, BDG-02 |
| SCR-06 | Badge shelf | BDG-03 |
| SCR-07 | Time's up lock | TIM-02 |
| SCR-08 | PIN entry | PAR-02, PAR-03 |
| SCR-09 | Parent dashboard | PAR-05..07 |
| SCR-10 | Topic detail | PAR-08 |
| SCR-11 | Parent settings: daily limit, extra time, change PIN, export PDF, reset | TIM-04, PAR-04, PAR-09, PAR-10 |

**Look:** bright, high-contrast, rounded. Colours, radii and text sizes are defined once in `lib/ui/theme.dart` and never hard-coded in screens. Child screens use 64 dp minimum tap targets and 20 sp minimum text (NFR-03). Landscape layout first: question on the left, answer area on the right (NFR-02).

## 7. Badges (BDG-01)

First Round · Perfect 10 · 3-Day Streak · 7-Day Streak · 30-Day Streak · 100 Questions · 500 Questions · Speedy (10 right in under 2 minutes) · Times Table Hero (all of `p2.times` at 90%+, 30+ attempts) · Division Dojo · Fraction Friend · Money Master · Time Keeper · Shape Spotter · Pattern Finder · Puzzle Master (20 `oly.logic` right) · Counting Star · Bar Model Builder · School Explorer (a round in every School topic) · Ninja Master (3 stars in every topic).

## 8. Testing

- Domain: unit tests for every rule in §5 and every badge rule, with an injected clock.
- Data: Drift tests on an in-memory database (`NativeDatabase.memory()`).
- Bank: a test that loads the shipped JSON and re-runs the validator and coverage counts (BNK-02..04).
- UI: widget tests for each screen's main path; golden or screenshot checks only where layout matters (quiz on a 12-inch landscape size).
- CI (`.github/workflows/ci.yml`): `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test`, `flutter build apk --release`; the APK is uploaded as a build artifact.

## 9. Change log

| Date | Change |
|---|---|
| 2026-11-14 | First version. |
