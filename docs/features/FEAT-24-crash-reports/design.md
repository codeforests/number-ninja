# FEAT-24: Crash reports

> Implements: CRS-01..07 (D22, ADR-11 in `05-phase3-plan.md`) · Touches: NFR-11, NFR-13, NFR-14 (privacy note), NFR-08 · Screens: SCR-11 (new "Send crash reports" switch), SCR-13 (privacy note line)
> Status: designed · Branch: `feat/FEAT-24-crash-reports` · 2026-11-20 (auto mode: decisions below taken by Claude on Ken's standing instruction)

## Scope

Dart errors in the app (Flutter framework errors and uncaught async errors) are saved on the device and sent, when online, to a create-only `crash_reports` collection on our own PocketBase server. Each report carries app version, bank version, Android version, device model, the screen (route pattern), error type, message and stack trace, and how many times it happened. No account, no device id, no child data. A parent switch turns it off. Ken reads reports in the PocketBase admin; an optional daily digest email is sent once a recipient is configured.

Not in scope: native crashes and ANRs (Play Console Android vitals give them free once the app is on Play, FEAT-23/32; Xcode Organizer for iOS later), any third-party SDK, a viewer page, symbolication (release builds keep Dart stack traces readable; no `--obfuscate`).

## Design decisions (this feature)

Auto mode (Ken, 2026-11-20): each takes the recommended option; the reason follows the dash.

- **AD-1 Own server, no SDK** (ADR-11, plan row). Crashlytics/Sentry would send device data from a children's app to a third party (NFR-14, Play Families rules) and need new accounts. Our server is already there, so nothing for Ken to sign up for.
- **AD-2 On by default, parent can turn it off** (plan §6 decision 6, signed off "everything else is ok"). Reports hold no personal data, and most parents never open settings, so off-by-default would mean no reports. The switch is on SCR-11 and the privacy note says so. No setup step: FEAT-26's wizard stays as it is (one less screen for the parent).
- **AD-3 Per-device setting, not synced.** `app_settings.crash_reports` (bool, default true). Diagnostics are about this device; syncing it would add a SYN field for no gain.
- **AD-4 Works signed out, sends anonymously.** Sign-in is optional (D10), so the upload is a plain `POST /api/collections/crash_reports/records` with no auth header even when signed in — a report can never be tied to an account. The collection's create rule is public; list, view, update and delete are superuser only (NFR-13).
- **AD-5 Device info from a small method channel, no plugin.** `brainbubblz/device` in `MainActivity.kt` returns `versionName`, `versionCode`, `Build.MODEL`, `Build.MANUFACTURER`, `Build.VERSION.RELEASE`, `SDK_INT`. Avoids `package_info_plus` + `device_info_plus` (two plugins for six strings). Off Android (tests, desktop) it falls back to `Platform.operatingSystem` and the version from `--dart-define=APP_VERSION` or `unknown`. Device model is coarse (e.g. "SM-X200"), not an identifier.
- **AD-6 Screen = route pattern, not location.** `GoRouterState.fullPath` (`/quiz/:topicId`), read from the router delegate. Parameters and query strings (topic ids, `?d=` dates, `?child=`) are dropped, so no child id or date leaves the device.
- **AD-7 Scrub names.** Before saving, every child nickname on the device (and the signed-in email, if any) is replaced by `<name>` / `<email>` in the message and stack, case-insensitive; message capped at 1,000 chars, stack at 8,000 (top frames kept). An error message can quote user text; this keeps names out without dropping the report.
- **AD-8 Group repeats on the device.** Signature = sha1 of error type + the first 5 stack frames with line numbers stripped of column. The same signature and app version bumps `count` and `last_at` on the unsent row instead of adding one. At most 30 unsent rows kept (oldest dropped). A crash loop therefore makes one row with a big count, not thousands.
- **AD-9 Send at launch and on resume**, beside the bank check in `app.dart` (same `AppLifecycleListener`), only if the switch is on and a server is configured; at most 10 rows per send, then rows are marked sent and deleted after 7 days. Errors from sending are swallowed (no retry storm; the next launch retries). Turning the switch off deletes unsent rows.
- **AD-10 Server limits.** Rate limit rule `crash_reports:create`, audience guest and auth, 10 per 60 s per IP (behind nginx `X-Real-IP`, gotcha FEAT-12). Field limits mirror AD-7 (message 1,000, stack 8,000, other text 128, count 1..100000), so a malformed or huge post is refused. Abuse risk of a public create rule is accepted: worst case is junk rows Ken can delete; there's nothing to read back.
- **AD-11 Capture once, never recurse.** `CrashReporter.install()` in `main()` before `runApp`: wraps `FlutterError.onError` (still calls `FlutterError.presentError`, so debug output stays) and `PlatformDispatcher.instance.onError` (returns true). Errors before the database opens wait in a 20-item memory buffer. A flag guards re-entry; any error inside the reporter is dropped. Clock is a parameter (NFR-08).
- **AD-12 Optional daily digest** (plan row). `pb_hooks/crash_digest.pb.js`: `cronAdd("crash_digest", "0 1 * * *", …)` (01:00 UTC = 9 am Singapore) emails `CRASH_DIGEST_TO` a count per signature for the last 24 h with app version and top line, through the existing mailer (Resend hook). If `CRASH_DIGEST_TO` is unset or there were no reports, nothing is sent. Ken can add the address to the server env any time; no action needed to ship.
- **AD-13 Reports on the server are kept 90 days.** The same cron deletes older rows, so the table can't grow without bound and old data doesn't pile up (privacy policy in FEAT-22 will say 90 days).

## Design

- **Domain** `lib/domain/crash.dart`: `CrashInfo` (app version, build, os, device), `CrashEntry` (type, message, stack, screen, at), `crashSignature(type, stack)`, `scrubText(text, names, email)`, `trimStack(stack, max)`, `trimMessage`. Pure, unit-tested.
- **Data**: schema v11, table `CrashReports` (`id`, `signature`, `app_version`, `bank_version` int, `os`, `device`, `screen`, `error_type`, `message`, `stack`, `count`, `first_at`, `last_at`, `sent_at` nullable); `app_settings.crash_reports` bool default true (`_from10To11`, column added before `_from6To7`, gotcha). `CrashRepository` (`lib/data/crash_repository.dart`): `record(entry, info, bankVersion)` (AD-8 grouping and cap), `pending(limit)`, `markSent(ids, at)`, `purge(now)`, `enabled()`/`setEnabled(bool)` (off deletes unsent). `CrashReporter` (`lib/data/crash_reporter.dart`): `install()`, buffer, scrub with names from `ChildRepository.all()` and the account email, `sendPending()`; `crashReporterProvider`, `crashRepositoryProvider`, `deviceInfoProvider` in `providers.dart`. `DeviceInfo` (`lib/data/device_info.dart`, channel `brainbubblz/device`, AD-5).
- **Server client**: `ServerClient.sendCrashReport(Map<String, dynamic>)` — `PocketBaseServerClient` posts with plain `http` (no auth store, AD-4); `FakeServerClient` records the bodies.
- **Screen tracking**: `app.dart` listens to `router.routerDelegate` and stores `fullPath` in `CrashReporter.screen`.
- **UI**: SCR-11 `_CrashReportsTile` (`SwitchListTile`, key `crash-reports-switch`, "Send crash reports", subtitle "Helps us fix problems. No names or account details are sent."), near the privacy/account rows. `privacyNote` gains one sentence (and drops the gendered "her" → "your child's"): "If crash reports are on, error details (app version, device model, the screen and the error) are sent with no names or account; turn them off in Settings."
- **Server** `pb_migrations/1763251207_crash_reports.js`: collection `crash_reports` (fields per AD-10 + autodate `created`, index on `signature`), createRule `""`, other rules null; adds the rate-limit rule. `pb_hooks/crash_digest.pb.js` (AD-12, AD-13). `server/README.md`: how to read reports in the admin, `CRASH_DIGEST_TO` env line.
- **Keys**: `crash-reports-switch`.

## Acceptance criteria

- **AC-1** (CRS-01): a widget test throws in a build method and a test throws in an unawaited future: both end up as rows with type, message, stack, screen pattern (`/quiz/:topicId`, no id) and app/bank version; `FlutterError.presentError` still runs; an error thrown inside the reporter doesn't loop.
- **AC-2** (CRS-02, CRS-06): nickname "Mia" and the account email in a message are saved as `<name>`/`<email>`; message and stack are capped; the stored row and the posted body have no child id, account id, device id or email field.
- **AC-3** (CRS-03): the same error 500 times → one row with count 500; 40 different errors → 30 unsent rows (oldest dropped).
- **AC-4** (CRS-04): with `FakeServerClient`: launch and resume send pending rows (≤ 10 per send), they're marked sent and purged after 7 days; signed out it still sends; a failing server keeps them for next time; no server configured → nothing sent.
- **AC-5** (CRS-05): SCR-11 switch is on for a fresh install and after the v10 → v11 migration (`migration_test.dart`); turning it off deletes unsent rows and stops recording and sending; it stays off after a restart. Switch passes the FEAT-04 sizes and phone sizes (NFR-09, NFR-17).
- **AC-6** (CRS-06, NFR-13): `api_rules_test.dart` group `crash_reports`: a guest and a signed-in user can create; nobody but a superuser can list, view, update or delete; oversized fields are refused; the 11th create in 60 s from one IP gets 429.
- **AC-7** (CRS-07): server test runs the `crash_digest` cron (`POST /api/crons/crash_digest` as superuser): with `CRASH_DIGEST_TO` set and reports present, the mail sink gets one email listing them by signature; unset or no reports → no mail; rows older than 90 days are deleted.
- **AC-8** (live, Ken, optional): with the release APK on the tablet, Ken triggers nothing special; after the next real error (or a debug build's test button, not shipped) a row shows in the admin. Not required to ship.

## Tasks

- **T1** Domain `crash.dart` + tests; schema v11 (`CrashReports`, `app_settings.crash_reports`), `_from10To11`, migration test (AC-5 part); `CrashRepository` + tests (AC-3); code-map lines.
- **T2** `DeviceInfo` + Kotlin channel (AD-5); `CrashReporter` (install, buffer, scrub, re-entry guard), `main()` wiring, screen tracking in `app.dart`; tests (AC-1, AC-2).
- **T3** `ServerClient.sendCrashReport` (real + fake), send at launch/resume, purge (AC-4).
- **T4** SCR-11 switch, `privacyNote` sentence, layout test (AC-5).
- **T5** Server migration `1763251207_crash_reports.js`, `crash_digest.pb.js`, `api_rules_test.dart` group and digest test in `run.sh` (AC-6, AC-7); README lines.
- **T6** `scripts/check.sh`, docs (02-design SCR-11/SCR-13 rows and change log, requirements Feature cells, STATE), draft PR (CI proves the Kotlin channel in the APK build).
