# Code map

> Where code lives, so a thread reads the right file by name instead of surveying `lib/`. Read only the section a task touches (`grep -n '^## ' docs/code-map.md`). A stage that adds a file, a route, a table or a gotcha adds one line here in the same commit.

## Entry and wiring

- `lib/main.dart` → `lib/app.dart`: `NumberNinjaApp`, `routerProvider` (go_router). Routes: `/play/:track`, `/quiz/:topicId`, `/locked`, parent area under `/parent`: `pin`, `change-pin`, `dashboard`, `topic/:topicId`, `reset`.
- `lib/providers.dart`: `databaseProvider`, `bankProvider`, `clockProvider`, the repository providers, `topicProgressProvider`. Tests override these.

## Domain (`lib/domain`, pure Dart)

- `question.dart` (`Question`, `QuestionBank`, `QuestionFormat`, `DragSpec`), `topics.dart` (`Track`, `Topic`), `answers.dart`, `expr.dart` (answer expressions).
- `quiz.dart` (`Quiz`, `QuizPhase`, `AnswerResult`), `round_builder.dart` (`buildRound`, `pickMixIn`), `stars.dart`, `progress.dart` (`TopicProgress`, `FinishedRound`).
- `stats.dart` (`AttemptRecord`, `Tally`, `StatsPeriod`, `needsPractice`, `WeekPoint`), `report.dart` (PDF report rows and formatting).
- `screen_time.dart` (`ScreenTimeClock`, `ScreenTimeStatus`, `effectiveDay`), `pin.dart` (`PinHasher`, `PinLockoutPolicy`), `clock.dart` (`systemClock`), `bank_validator.dart`.

## Data (`lib/data`)

- `database.dart`: Drift tables `AppSettings`, `PlaySessions`, `Rounds`, `Attempts`, `DailyUsage`, `BadgesEarned`, `PinLockout`; `schemaVersion` and migrations at the bottom. After a table change: `dart run build_runner build`, bump `schemaVersion`, add a case to `test/data/migration_test.dart`.
- `sound_player.dart`: `SoundEffect`, `SoundPlayer` (`AudioSoundPlayer`, `audioplayers`), `SoundEffects` (checks `UsageRepository.soundOn`); `soundEffectsProvider` in `providers.dart`. Tests use `RecordingSoundPlayer` from the quiz harness.
- Repositories: `pin_repository.dart`, `round_repository.dart`, `stats_repository.dart`, `usage_repository.dart`; `question_bank_loader.dart` (`loadBank`).

## Features (`lib/features`)

- `home/home_screen.dart`, `topics/topic_map_screen.dart` (+ `topic_icons.dart`), `setup/setup_pin_screen.dart`.
- `quiz/`: `quiz_controller.dart` (`QuizController`, `RoundState`, `RoundSummary`), `quiz_screen.dart`, `result_screen.dart`, `feedback_panel.dart`, `answers/` (`mcq_answer`, `number_answer`, `drag_answer`).
- `screen_time/`: `screen_time_controller.dart` (`ScreenTimeController`, `screenTimeProvider`), `lock_screen.dart`.
- `parent/`: `pin_entry_screen`, `parent_screen` (incl. screen-time section), `change_pin_screen`, `dashboard_screen`, `stats_view` (`statsDataProvider`, `StatsCard`, `TrendCharts`), `topic_detail_screen`, `reset_screen`, `report_pdf` and `report_export` (`exportReport`, `reportSharerProvider`).

## Shared UI (`lib/ui`)

- `theme.dart` (`buildTheme`, all colours, radii and text sizes), `kid_background.dart` (`KidBackground`, `KidScene`, on SCR-02..07), `celebration.dart` (SCR-05 confetti), `layout.dart`, `screen_frame.dart`, `pin_pad.dart`, `trend_chart.dart`.
- `visuals/`: `question_visual.dart` dispatches to one widget per visual kind (bar model, clock, coins, figure, fraction, groups, picture graph, ruler, shapes) inside `visual_frame.dart`.

## Question bank (`tool/`)

- `tool/generate_sounds.dart` (+ `tool/sounds/synth.dart`) writes `assets/sounds/*.wav`; `tool/generate_icon.dart` (+ `tool/icon/draw.dart`) writes `assets/icon/*.png`, then `dart run flutter_launcher_icons` writes the Android mipmaps.
- `tool/generate_bank.dart` writes `assets/questions/*.json` (never read those). Templates: `tool/bank/templates_p1.dart`, `templates_p2.dart` (large: grep for the topic id), `templates_oly.dart`, `handwritten.dart`, `helpers.dart`, `generator.dart`.

## Tests

- Mirrors `lib/`: `test/domain`, `test/data`, `test/features`, `test/ui`, `test/tool`.
- Helpers: `test/features/quiz/quiz_harness.dart` (`QuizHarness`: fake bank, fixed clock, `pumpApp`, `CountingRepository`), `test/ui/layout_checks.dart` (`setTextScale`, `expectNoOverlap`, `expectChildSizes`).

## Gotchas

- The Ahem test font is wider than Roboto: `QuizHarness.tap` calls `ensureVisible` first.
- The router refreshes only on the session and `ScreenTimeController.lockedListenable` (FEAT-05); don't make it watch other providers.
- Call `forgetSession()` after a reset (FEAT-06).
- Widget tests of async PDF work need `tester.runAsync` and a poll loop with `tester.pump()` (FEAT-07).
- `pdf` MultiPage splits a `pw.Column`; wrap blocks that must stay together in `pw.Inseparable`, and check page breaks with `pdftoppm`/`pdftotext` (FEAT-07).
- Child screens wrap a transparent `Scaffold` in `KidBackground`; a new child screen should too (FEAT-09).
- Material widgets come from `package:material_ui/material_ui.dart`.
