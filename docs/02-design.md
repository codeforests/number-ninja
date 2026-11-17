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

**Stack:** Flutter stable (3.50), Dart 3.14, flutter_riverpod, go_router, drift + drift_flutter (SQLite), own `CustomPainter` trend charts (`lib/ui/trend_chart.dart`, no fl_chart), intl, pdf + printing, crypto. Exact versions are pinned in `pubspec.lock`.

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

- `tool/generate_bank.dart` holds 3–6 templates per topic plus a hand-written list for `oly.logic` and `oly.counting`. It writes `assets/questions/bank.json` (FEAT-15; `bank_v1.json` before) with a fixed seed and runs its validator before writing (BNK-04).
- Question JSON: `id` (e.g. `p2.fractions.cmp.017`), `topic`, `level` (1–3), `format` (`mcq` | `number` | `drag`), `prompt`, `visual` (optional typed object, e.g. `{"kind":"clock","h":3,"m":15}`), `options` (mcq), `answer`, `drag` (items and target slots, for drag), `explanation`.
- Ids are made from topic, template and a per-template counter that only grows, so v2 keeps v1's ids (BNK-05).
- FEAT-15: the file is `assets/questions/bank.json`; top level `version` (`bankVersion` in `tool/bank/bank.dart`) and `format`; a question may be `"retired":true` (`tool/bank/retired.dart`), kept for old results and never served (BNK-10). Newer versions are published to the server by the "Publish bank" workflow (BNK-07).
- Format mix target: about 45% mcq, 40% number, 15% drag.

## 4. Data model (Drift, `lib/data/database.dart`)

| Table | Columns | Notes |
|---|---|---|
| `app_settings` | id = 1, pin_hash, pin_salt, daily_limit_min (20), bank_version, sound_on (true), profile_pending (true), device_id | One row, created on first open; `sound_on` schema v3 (FEAT-09); `profile_pending` schema v4, false on upgrade (FEAT-10, PRO-02); `device_id` schema v7 (FEAT-14) |
| `child_profile` | id = 1, nickname, school_year (1–6), school_start_level, olympiad_start_level (nullable), updated_at | Schema v4 (FEAT-10, PRO-01); kept by the PAR-10 reset |
| `play_sessions` | id, started_at, ended_at | One per app opening |
| `rounds` | id, session_id, topic_id, level, started_at, score, duration_ms, stars, finished_at, kind, uuid, dirty, remote_id | `finished_at` is null until the last answer is saved (schema v2, FEAT-04); `kind` `normal` or `revision` (schema v6, FEAT-11), a mixed revision round has `topic_id = 'mixed'`; `uuid`/`dirty`/`remote_id` schema v7 (FEAT-14 sync) |
| `attempts` | id, round_id, question_id, answer_given, correct, time_ms, answered_at, uuid, dirty | Saved before the next question shows (NFR-05); `uuid`, `dirty` schema v7 |
| `daily_usage` | day (yyyy-MM-dd), device_id, seconds_used, extra_seconds_granted, dirty, remote_id | Screen time per day and device (key day + device_id, schema v7); a day's totals sum all devices (FEAT-14) |
| `badges_earned` | badge_id, earned_at, dirty, remote_id | `dirty`, `remote_id` schema v7 |
| `pin_lockout` | id = 1, failed_count, locked_until | PAR-03 |
| `topic_unlocks` | topic_id (primary key), opened_at | Schema v5 (FEAT-17): topics the parent opened (PRC-14); kept by the PAR-10 reset |
| `sync_fields` | field (primary key), changed_at, dirty | Schema v7 (FEAT-14): when each synced profile/settings field last changed here (last change wins) |
| `sync_state` | id = 1, account_id, child_id, reset_epoch, pending_reset, cursors (json), last_sync_at, last_error | Schema v7 (FEAT-14) |

Stats (PAR-05..08) are computed from `attempts` joined to the bank, never stored twice. Schema changes bump `schemaVersion` with a migration and a migration test.

## 5. Key rules

- **PIN (PAR-01..04):** 4 digits, hashed with SHA-256 over a random 16-byte salt, 10,000 rounds. Compared in constant time.
- **Screen-time clock (TIM-01..05):** a `ScreenTimeClock` in the domain layer takes `now()` and an elapsed-time source as parameters (NFR-08). It adds foreground seconds to today's `daily_usage` row every 10 seconds and on pause. "Today" is the later of the device date and the latest day already recorded, so moving the clock back cannot reopen a used day. Allowance = daily limit + extra granted today.
- **Stars (PRC-06):** 10/10 = 3 stars, 8–9 = 2, 6–7 = 1, else 0. Speed does not reduce stars, so she is never punished for being careful.
- **Round builder (PRC-08, PRC-09):** picks 10 questions at the topic's current level, preferring ones not answered correctly in her last 3 rounds; mixes in up to 2 questions from a "needs practice" topic on the School track.
- **Level (PRC-09):** a topic's current level is worked out from its latest finished round (level L, stars S), never stored: S = 3 → L + 1, S ≤ 1 → L − 1, else L, kept within 1–3. No finished round yet → the profile's start level (PRO-03, FEAT-10 design), or 1 without a profile. A quit round doesn't count. Best stars (PRC-07) = most stars in any finished round of the topic, at any level.
- **Topic lock (PRC-12..14, FEAT-17):** worked out from finished rounds, the profile and `topic_unlocks`, never stored. Pass = a finished round with 7+ right, any level. A School topic is open when passed, played (any finished round), in a year below her profile year (no profile = P1), opened by the parent, or when the topic before it in its year is passed; the first topic of a year opens at or below her year, or when every topic of the year before is passed. Olympiad topics are always open.

- **Revision (REV-01..06, FEAT-11):** `RuleRevisionPlanner` (`lib/domain/revision.dart`) over the last 30 days of attempts. Question type = id without `.nnn`. Weak type: 5+ of its latest 10 attempts and under 70 % right, or 1.5× slower than its topic. Mistake: latest attempt wrong. A round = up to 5 mistakes, then weak types round-robin at the topic's level, then siblings of the mistakes; 10 at most. Offered for a topic with a weak type or mistake; on home with a weak type or 3+ mistakes. A revision round's attempts count everywhere, but `finishedRounds()` is normal-only, so levels, best stars and the lock ignore it.

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
| SCR-11 | Parent settings: daily limit, extra time, change PIN, export PDF, reset; FEAT-15 adds the "Question bank" row (version in use, built in or downloaded, last check, Check now) | TIM-04, PAR-04, PAR-09, PAR-10, BNK-12 |
| SCR-12 | Phase 2: child profile; see [04-architecture.md](04-architecture.md) §3 | PRO |
| SCR-13 | Account (`/parent/account`, from SCR-11's "Account" row): create, sign in (email or Google), verify/resend, forgot password, sign out, delete with PIN, privacy note (FEAT-13); FEAT-14 adds the sync section (last sync, "Syncing…", error line, Sync now) | ACC-01..07, NFR-14, SYN |
| SCR-14 | Revision start (`/revise/<topic or mixed>`): mistakes count, tricky kinds, Go (FEAT-11) | REV-03, REV-04 |
| SCR-15 | School topics: lock state of each P1/P2 topic, parent opens one (FEAT-17) | PRC-14 |

**Look:** bright, high-contrast, rounded. Colours, radii and text sizes are defined once in `lib/ui/theme.dart` and never hard-coded in screens. Child screens use 64 dp minimum tap targets and 20 sp minimum text (NFR-03). Landscape layout first: question on the left, answer area on the right (NFR-02). On smaller screens (NFR-09) the layout adapts by width and height rather than by device: halves side by side only when the screen is landscape and at least 600 dp wide, otherwise stacked; anything that doesn't fit scrolls instead of overlapping. The 12-inch landscape tablet still never scrolls during a question.

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
| 2026-11-15 | FEAT-03 design: the round builder's "needs practice" mix-in (§5) moves to FEAT-06, which first computes needs practice. FEAT-03 plays rounds at level 1 from a placeholder topic list until FEAT-04 adds SCR-03 and difficulty steps (PRC-09). |
| 2026-11-15 | FEAT-04 design: `rounds.finished_at` (schema v2) so a quit round doesn't move the level; level rule in §5; small-screen layout rule in §6 (NFR-09, D9). |
| 2026-11-15 | FEAT-05 design: screen time counts only on child screens (not PIN entry or the parent area); route `/locked` for SCR-07; "finish the current question" (TIM-03) ends at the latest 2 minutes after time runs out; parent unlock = extra minutes or a higher limit on SCR-11. No schema change. |
| 2026-11-15 | FEAT-05 build: SCR-07 itself doesn't count as screen time, so extra minutes a parent grants aren't used up on the lock screen. |
| 2026-11-15 | FEAT-06 design: stats count each attempt for its question's topic (quit rounds included), per-attempt time capped at 120 s in averages, weeks start Monday; trend charts are a small CustomPainter (`lib/ui/trend_chart.dart`) instead of fl_chart; the mix-in uses 30-day needs practice and counts in the round's score; reset keeps the PIN, limit and `daily_usage`. No schema change. |
| 2026-11-15 | FEAT-06 build: stack row drops fl_chart; `RoundRepository.forgetSession()` after a reset (its cached `play_sessions` row is deleted); parent-only text sizes `AppText.chartLabel` 14 / `parentBody` 16 (NFR-03 sizes apply to child screens only). |
| 2026-11-15 | FEAT-07 design: PDF built with `pdf` (built-in Helvetica, ASCII text only, no font asset) and shared with `printing` (`Printing.sharePdf`), no `share_plus`; export from SCR-11 (period sheet) and SCR-09 (shown period); same stats rules as SCR-09; nothing stored. No schema change. |
| 2026-11-15 | FEAT-07 build: `pdfColor` lives in `report_pdf.dart` (not `theme.dart`) so only the two report files import `pdf`; `AppPdf` in `theme.dart` holds every PDF size; `ReportData` keeps trends as per-week values (`weeks`, `accuracyTrend`, `speedTrend`); the topic legend states the full FEAT-06 needs-practice rule (below 70 % or slower than average); each chart stays on one page with its heading; the export sheet closes after sharing. |
| 2026-11-15 | FEAT-08 design: badge rules evaluated from scratch over all finished rounds and attempts after each finished round (no counters stored); the five topic badges and Pattern Finder use "27 of the latest 30 attempts, 30+ attempts" for §7's 90 %+; Perfect 10 = a 3-star round; streaks count days with a finished round; SCR-06 at `/badges` counts as screen time; SCR-02 shows the latest badge. No schema change. |
| 2026-11-15 | FEAT-08 build: SCR-06 is a `Wrap` of 220 dp tiles in a scroll view, not a fixed-height `GridView`, so long hints at text scale 1.3 grow the tile instead of overflowing; the "N of 20" count sits under the title (fits 360 dp); `ninja-master` and `school-explorer` use a small best-stars map instead of `progressByTopic`; the domain `Badge` clashes with Material's, so screens importing both use `hide Badge`. |
| 2026-11-15 | FEAT-09 design: sound effects synthesised by `tool/generate_sounds.dart` and played with `audioplayers`; `app_settings.sound_on` (schema v3) with a switch on SCR-11, kept by the PAR-10 reset; gradient backgrounds on child screens SCR-02..07 and confetti on SCR-05 drawn with CustomPainters (no image assets); launcher icon drawn by `tool/generate_icon.dart` and written by `flutter_launcher_icons`; version 1.0.0+2. |
| 2026-11-15 | FEAT-09 build: backgrounds follow the home tracks, School (P1 and P2) and Olympiad, not P1/P2 separately (`KidScene`); SCR-02, SCR-06 and SCR-07 use a sunny home scene; animation durations live in `AppMotion` (`celebration`, `starPop`). |
| 2026-11-15 | Phase 2 plan: §1's "no server" holds for v1 only; the server, sync, bank hosting and privacy decisions are in [04-architecture.md](04-architecture.md) (ADR-01..08); screens SCR-12..14 added. Requirements 2.0 draft (D10–D16). |
| 2026-11-15 | FEAT-10: schema v4 (`child_profile`, `app_settings.profile_pending`); an unplayed topic starts at the profile's start level (§5); SCR-12 at `/setup/profile` (first run) and `/parent/profile`. |
| 2026-11-16 | FEAT-17: School topic lock derived like levels (§5), pass = 7+ right in a finished round, played topics stay open; `topic_unlocks` (schema v5) for parent openings, kept by reset; padlocks on SCR-03, guard in the quiz controller; new SCR-15 from SCR-11 (SCR-09 lists no topics before her first answers, so SCR-10 couldn't host it). |
| 2026-11-16 | FEAT-11: revision planner (§5) behind `RevisionPlanner`; `rounds.kind` (schema v6); `finishedRounds()` normal-only so revision never moves level, stars or lock; topic-map badges use normal rounds only; SCR-14 at `/revise/<scope>` (counts as screen time); entries on SCR-05 and SCR-02; weak types card on SCR-10, which became a non-lazy scroll view. |
| 2026-11-16 | FEAT-12: server in `server/` (PocketBase 0.40.6 behind the droplet's nginx, certbot webroot certificate; migrations hold collections and API rules); app gets INTERNET + HTTPS-only network config, `SERVER_URL` build define (`ServerConfig`, `ServerClient`), and a "Server" row with a Check button on SCR-11. No schema change. |
| 2026-11-16 | FEAT-13: parent account on SCR-13; session (token + record, never the password) in `flutter_secure_storage`; Google through PocketBase's browser OAuth2 flow in a Custom Tab (`url_launcher`); server email and Google settings applied from env by `pb_hooks/config.pb.js` on each start; email links open `pb_public/verify.html` / `reset.html`; `children` create needs a verified account. No schema change. |
| 2026-11-16 | FEAT-14: progress sync (`lib/data/sync/sync_service.dart`, `sync_controller.dart`, merge rules in `lib/domain/sync_merge.dart`); schema v7 (ids, dirty counters, per-device `daily_usage`, `sync_fields`, `sync_state`); server reset route `POST /api/nn/children/{id}/reset` (`pb_hooks/reset.pb.js`), migration `1763251203_sync.js` (`children.reset_at`, batch API on, create limit 5000/5 s and batch 10/s for signed-in users, sign-ups still 20/5 s); SCR-13 sync section; SCR-11 reset note while signed in. |
| 2026-11-17 | FEAT-15: server question bank. Bank file renamed `bank.json` with `format` and `retired`; "Publish bank" workflow (`tool/publish_bank.dart`); `banks.version` a number (migration `1763251204_banks.js`); schema v8 (`bank_files`, `app_settings.bank_checked_at`/`bank_check_note`); `BankStore` + `BankUpdater` check at launch and resume at most daily, a new bank applies at launch or before the next round; SCR-11 "Question bank" row. |
