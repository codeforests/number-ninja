# Code map

> Where code lives, so a thread reads the right file by name instead of surveying `lib/`. Read only the section a task touches (`grep -n '^## ' docs/code-map.md`). A stage that adds a file, a route, a table or a gotcha adds one line here in the same commit.

## Entry and wiring

- `lib/main.dart` → `lib/app.dart`: `NumberNinjaApp`, `routerProvider` (go_router). Routes: `/setup`, `/setup/profile` (SCR-12 first run, while `AppSession.profilePending`), `/play/:track`, `/quiz/:topicId`, `/locked`, parent area under `/parent`: `pin`, `change-pin`, `dashboard`, `topic/:topicId`, `reset`, `profile`, `topics` (SCR-15), `account` (SCR-13). `/revise/:scopeId` (SCR-14) and `/revise/:scopeId/quiz` (revision round).
- `lib/providers.dart`: `databaseProvider`, `bankProvider`, `clockProvider`, the repository providers, `topicProgressProvider`. Tests override these.

## Server (`server/`, FEAT-12)

- `server/README.md` is the guide (Ken's setup, deploy, tunnel, restore). `VERSION` pins PocketBase; `pb_migrations/*.js` are the only schema and rule source; `nginx/numberninja.conf.template` + `install.sh` (runs on the droplet, called by `deploy.sh`, workflow `deploy-server.yml`); `restore.sh`.
- FEAT-14: `pb_hooks/reset.pb.js` (`POST /api/nn/children/{id}/reset`), `pb_migrations/1763251203_sync.js` (`children.reset_at`, batch API, rate limits); `test/sync_test.dart`. `run.sh` also runs the app's live sync test `test/live/sync_live_test.dart` (AC-7, `SYNC_LIVE_URL`).
- FEAT-15: `pb_migrations/1763251204_banks.js` (`banks.version` number); `test/bank_publish_test.dart` runs `tool/publish_bank.dart --bank-file`; `run.sh` also runs `test/live/bank_live_test.dart` (AC-6).
- FEAT-13: `pb_hooks/config.pb.js` (SMTP, Google OAuth2 and appURL from env on every start), `pb_hooks/mail.pb.js` (with `RESEND_API_KEY`, every mail goes through Resend's HTTPS API instead of SMTP: DigitalOcean blocks SMTP ports; test `test/resend_test.dart` on a third PocketBase in `run.sh`), `pb_migrations/1763251202_auth.js` (users auth settings, email templates, verified-only child create), `pb_public/verify.html` + `reset.html` (email link pages). Tests: `test/auth_test.dart` with `lib/mail_sink.dart` (in-test SMTP sink on `PB_SMTP_PORT`).
- Tests: `server/test/run.sh` (CI job `server`): `scripts/server-local.sh` starts the pinned PocketBase; `test/api_rules_test.dart` (NFR-13), `backup_test.dart` + `restore_check_test.dart` (NFR-15). Helpers in `server/test/lib/fixtures.dart`.

## Domain (`lib/domain`, pure Dart)

- `question.dart` (`Question`, `QuestionBank`, `QuestionFormat`, `DragSpec`), `topics.dart` (`Track`, `Topic`), `answers.dart`, `expr.dart` (answer expressions).
- `quiz.dart` (`Quiz`, `QuizPhase`, `AnswerResult`), `round_builder.dart` (`buildRound`, `pickMixIn`), `stars.dart`, `progress.dart` (`TopicProgress`, `FinishedRound`).
- `stats.dart` (`AttemptRecord`, `Tally`, `StatsPeriod`, `needsPractice`, `WeekPoint`), `report.dart` (PDF report rows and formatting).
- `profile.dart` (`ChildProfile`, `startLevel`, `nicknameError`), `topic_lock.dart` (`topicLocks`, `TopicLock`, `passScore`), `revision.dart` (`RevisionPlanner`, `RuleRevisionPlanner`, `RevisionScope`, `RevisionHistory`, `typeOf`, `mixedScopeId`), `screen_time.dart` (`ScreenTimeClock`, `ScreenTimeStatus`, `effectiveDay`), `pin.dart` (`PinHasher`, `PinLockoutPolicy`), `clock.dart` (`systemClock`), `bank_validator.dart`.

## Data (`lib/data`)

- `database.dart`: Drift tables `AppSettings`, `PlaySessions`, `Rounds`, `Attempts`, `DailyUsage`, `BadgesEarned`, `PinLockout`, `ChildProfiles` (`child_profile`, row class `ProfileRow`), `TopicUnlocks`; `schemaVersion` and migrations at the bottom. After a table change: `dart run build_runner build`, bump `schemaVersion`, add a case to `test/data/migration_test.dart`.
- `sound_player.dart`: `SoundEffect`, `SoundPlayer` (`AudioSoundPlayer`, `audioplayers`), `SoundEffects` (checks `UsageRepository.soundOn`); `soundEffectsProvider` in `providers.dart`. Tests use `RecordingSoundPlayer` from the quiz harness.
- `sync/server_config.dart` (`ServerConfig`, from `--dart-define=SERVER_URL`, https only), `sync/server_client.dart` (`ServerClient`, `PocketBaseServerClient`, `ServerHealth`); `serverConfigProvider`, `serverClientProvider` in `providers.dart`. Tests use `test/data/fake_server_client.dart`.
- FEAT-14: `sync/sync_service.dart` (`SyncService.run`: refresh, child + reset epoch + fields, push dirty rows in batches of 100, pull by `updated` cursor; `SyncOutcome`), `sync/sync_controller.dart` (`SyncController`, `SyncStatus`, `SyncTimers`, `SyncDataVersion`); `syncProvider`, `syncServiceProvider`, `syncAccountProvider`, `syncDataVersionProvider` (data providers watch it to reload after a sync) in `providers.dart`; `app.dart` keeps `syncProvider` alive and syncs on resume. Merge rules: `lib/domain/sync_merge.dart`; ids: `lib/domain/ids.dart`. `ServerClient` record calls throw `SyncException(SyncError)`. Tests: `test/data/sync/` (`fake_sync_timers.dart`), `FakeSyncServer` in `fake_server_client.dart` (two devices share one).
- FEAT-13: `sync/token_store.dart` (`TokenStore`, `SecureTokenStore`, `MemoryTokenStore`); `ServerClient` auth calls throw `AuthException(AuthError)`; `sync/account_repository.dart` (`AccountRepository` notifier, `AccountState`, `AccountNotice`) = `accountProvider`; `signInBrowserProvider` (Custom Tab for Google) in `providers.dart`.
- `revision_repository.dart` (`RevisionRepository.history()`); `revisionPlannerProvider`, `revisionHistoryProvider`, `revisionOffersProvider(scopeId)` in `providers.dart`. `round_repository.dart` has `roundKindNormal`/`roundKindRevision`; `finishedRounds()` is normal-only.
- FEAT-15: `bank_store.dart` (`BankStore`: bundled + downloaded files under app support `banks/`, `loadActive`, `save`, check state), `bank_updater.dart` (`BankUpdater.check`, 24 h rule, `BankCheck`); providers `bankStoreProvider`, `activeBankProvider` → `bankProvider`, `bankUpdaterProvider`, `bankPendingProvider` (applied in `QuizController.start`/`startRevision`), `bankStatusProvider`, `bankCheckProvider` (launch + resume in `app.dart`, SCR-11 "Check now"). `ServerClient.latestBank`/`downloadBank`. Tests: `test/data/bank_test_support.dart` (`BankRig`); `QuizHarness.useBankStore`, `banksDir`, `MemoryBankBundle`.
- Repositories: `topic_lock_repository.dart` (`topicLocksProvider` in `providers.dart`), `profile_repository.dart` (`childProfileProvider` is a FutureProvider; invalidate after a save), `pin_repository.dart`, `round_repository.dart`, `stats_repository.dart`, `usage_repository.dart`; `question_bank_loader.dart` (`loadBank`).

## Features (`lib/features`)

- `revision/revision_start_screen.dart` (SCR-14, `revisionPreviewProvider`).
- `home/home_screen.dart`, `topics/topic_map_screen.dart` (+ `topic_icons.dart`), `setup/setup_pin_screen.dart`, `profile/profile_screen.dart` (SCR-12).
- `quiz/`: `quiz_controller.dart` (`QuizController`, `RoundState`, `RoundSummary`), `quiz_screen.dart`, `result_screen.dart`, `feedback_panel.dart`, `answers/` (`mcq_answer`, `number_answer`, `drag_answer`).
- `screen_time/`: `screen_time_controller.dart` (`ScreenTimeController`, `screenTimeProvider`), `lock_screen.dart`.
- `parent/`: `pin_entry_screen`, `parent_screen` (incl. screen-time section), `change_pin_screen`, `dashboard_screen`, `stats_view` (`statsDataProvider`, `StatsCard`, `TrendCharts`), `topic_detail_screen`, `reset_screen`, `report_pdf` and `report_export` (`exportReport`, `reportSharerProvider`), `topic_locks_screen` (SCR-15), `account_screen` (SCR-13, `/parent/account`; SCR-11 "Account" row).

## Shared UI (`lib/ui`)

- `theme.dart` (`buildTheme`, all colours, radii and text sizes), `kid_background.dart` (`KidBackground`, `KidScene`, on SCR-02..07), `celebration.dart` (SCR-05 confetti), `layout.dart`, `screen_frame.dart`, `pin_pad.dart`, `trend_chart.dart`.
- `visuals/`: `question_visual.dart` dispatches to one widget per visual kind (bar model, clock, coins, figure, fraction, groups, picture graph, ruler, shapes) inside `visual_frame.dart`.

## Question bank (`tool/`)

- `tool/generate_sounds.dart` (+ `tool/sounds/synth.dart`) writes `assets/sounds/*.wav`; `tool/generate_icon.dart` (+ `tool/icon/draw.dart`) writes `assets/icon/*.png`, then `dart run flutter_launcher_icons` writes the Android mipmaps.
- `tool/generate_bank.dart` writes `assets/questions/bank.json` (never read it); version in `tool/bank/bank.dart` (`bankVersion`), retired ids in `tool/bank/retired.dart`. `tool/publish_bank.dart` (+ `tool/bank/publish.dart` checks) uploads it, run by `.github/workflows/publish-bank.yml` (FEAT-15). Templates: `tool/bank/templates_p1.dart`, `templates_p2.dart` (large: grep for the topic id), `templates_oly.dart`, `handwritten.dart`, `helpers.dart`, `generator.dart`.

## Tests

- Mirrors `lib/`: `test/domain`, `test/data`, `test/features`, `test/ui`, `test/tool`.
- Helpers: `test/features/quiz/quiz_harness.dart` (`QuizHarness`: fake bank, fixed clock, `pumpApp`, `CountingRepository`, `lockTopics` false = every topic open), `test/ui/layout_checks.dart` (`setTextScale`, `expectNoOverlap`, `expectChildSizes`).

## Gotchas

- Google sign-in doesn't use PocketBase's realtime `authWithOAuth2` (some networks cut the quiet SSE connection after ~1 min, so the result never arrived). The app opens the provider's `authURL` with redirect `https://<host>/signin/google`; that nginx page opens `numberninja://signin/google?state&code`, `SignInReturnActivity` (Android) passes it on the `number_ninja/sign_in` channel to `SignInBrowser.open` and brings back the existing MainActivity (NEW_TASK|CLEAR_TOP|SINGLE_TOP; MainActivity must keep the default task affinity, or a second copy opens signed out), and `ServerClient` checks state and calls `authWithOAuth2Code`. nginx also answers `/_/` with a result page for the old flow (admin files under `/_/` stay 404).
- The Ahem test font is wider than Roboto: `QuizHarness.tap` calls `ensureVisible` first.
- The router refreshes only on the session and `ScreenTimeController.lockedListenable` (FEAT-05); don't make it watch other providers.
- Call `forgetSession()` after a reset (FEAT-06).
- Widget tests of async PDF work need `tester.runAsync` and a poll loop with `tester.pump()` (FEAT-07).
- `pdf` MultiPage splits a `pw.Column`; wrap blocks that must stay together in `pw.Inseparable`, and check page breaks with `pdftoppm`/`pdftotext` (FEAT-07).
- Child screens wrap a transparent `Scaffold` in `KidBackground`; a new child screen should too (FEAT-09).
- Material widgets come from `package:material_ui/material_ui.dart`.
- Don't use Drift `watch()` streams in providers that widget tests build: they leave a pending timer after the tree is disposed. Use a FutureProvider and invalidate it (FEAT-10).
- SCR-11 is a lazy `ListView`: a far-down tile may not be built; `ParentHarness.tapKey` scrolls to it (FEAT-10).
- Reading an autoDispose `FutureProvider`'s `.future` with `ref.read` inside a notifier fails ("Ref used after disposed"): `ref.listen` it and `await sub.read()` (FEAT-17).
- A mixed revision round has `topic_id = 'mixed'`: code that looks up `topicsById[round.topicId]` must tolerate a miss (FEAT-11).
- PocketBase's built-in rate limit allows 2 sign-ins per 3 s per IP: server tests sign in through `signIn()` (retries on 429), and behind nginx the client IP comes from `X-Real-IP` (`trustedProxy` in the settings migration), or every user would share one limit (FEAT-12).
- `flutter analyze` excludes `server/**`; the server test package is analyzed by its own `dart analyze` in the CI `server` job (FEAT-12).
- Server nginx site: write `listen 443 ssl http2;`, never `http2 on;` (stock Ubuntu/Debian nginx ≤1.24 rejects it; CI `server` job runs `nginx -t` on the rendered template). Search `sites-enabled` with `grep -R`: its entries are symlinks, which `grep -r` skips.
- The PocketBase SDK clears its auth store before a request when the token isn't an unexpired JWT: app tests must use a real-shaped JWT (see `account_repository_test.dart`). `FakeServerClient.authMethods` ignores `fail`, since SCR-13 calls it on open (FEAT-13).
- An unverified user can't create a `children` record: server test parents are verified through the superuser in `Parent.signUp` (FEAT-13).
- CI builds with JDK 21: release lint (`lintVitalAnalyzeRelease`) on `url_launcher_android` crashes on JDK 17 (`NoSuchMethodError List.removeLast`). Source/target stay Java 17 (FEAT-13).
- Every request inside a PocketBase batch counts against the rate limits (`*:create`, and `/api/batch` itself): the sync migration raises them for signed-in users, and `SyncService` waits and resends a batch on 429 (FEAT-14).
- A sync writes local rows only through `SyncService`, with `dirty = 0`; every other local write bumps `dirty` (rows) or `stampFields` (profile/settings), or the change never reaches the server (FEAT-14).
- Widget tests sync only when they override `serverConfigProvider` with a configured URL (`syncAccountProvider` reads it); override `syncTimersProvider` with `FakeSyncTimers` too (FEAT-14).
- A schema step that adds columns to `app_settings` must run before `_from6To7` in `onUpgrade` (it rebuilds the table with every current column) (FEAT-15).
- Tests that need real HTTP (live tests) must not call `TestWidgetsFlutterBinding.ensureInitialized()`: the binding answers every request with 400; read assets from disk instead (FEAT-15).
