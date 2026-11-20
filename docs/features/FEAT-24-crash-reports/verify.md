# FEAT-24: Verify

> Verdict: **accepted** (2026-11-20, auto mode). Verified at build head `2cf704b`; this stage only adds docs and the v2.2.0 version bump.

## Checks re-run here

- `build_runner build` left no diff.
- `scripts/check.sh` on `2cf704b`: format, analyze and the full `flutter test` PASS.
- `server/test/run.sh` (PocketBase 0.40.6): api rules/auth/sync/bank/backup/crash digest 44 pass, restore 3, Resend 3, live sync/bank/crash 2 pass.
- APK build and manifest check: CI on the final head (PR #34). It is the first proof the Kotlin `brainbubblz/device` channel compiles.
- Not run: AC-8 live check on the tablet (Ken, optional).

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `crash_reporter_test.dart` async error → type, message, stack, `/quiz/:topicId`, app/bank version; previous handler still runs; error inside the reporter isn't re-captured. `crash_app_test.dart` build error on SCR-04 saved with the pattern, no topic id. |
| AC-2 | pass | "Mia" and the email become `<name>`/`<email>`, message capped at 1,000; `crash_repository_test.dart` body keys are exactly the 12 report fields; reporter test checks no child/account/device id or email key. |
| AC-3 | pass | 500 repeats → one row, count 500; 40 kinds → newest 30 unsent rows. |
| AC-4 | pass | ≤10 per send, marked sent, purged after 7 days; failing server keeps rows; no server → nothing sent; launch and resume both send (`crash_app_test.dart`); posts carry no auth (`crash_live_test.dart` against a real server). |
| AC-5 | pass | `migration_test.dart` v10→v11 and fresh DB on; `crash_switch_test.dart` off deletes unsent rows and survives restart; layout at the FEAT-04 and phone sizes and 1.3 text scale. |
| AC-6 | pass | `api_rules_test.dart` group `crash_reports`: guest and signed-in create; list/view/update/delete refused except superuser; six oversized/malformed bodies → 400; a 429 within 11 creates (the group's earlier creates share the IP's 10). |
| AC-7 | pass | `crash_digest_test.dart`: one mail by signature with counts, then rows deleted (`CRASH_KEEP_DAYS=0`); no reports → no mail; `resend_test.dart` last case: no address → no mail, rows kept. |
| AC-8 | live, Ken, optional | not run. |

## Beyond the tests

- Changed older tests are setup only: `migration_test.dart` drops the v11 column/table before faking older versions; `account_screen_test.dart` adds privacy-note asserts. No assertion removed or skipped.
- Read `crash_reporter.dart`, `crash.dart`, `device_info.dart`, the migration and the digest hook: errors in capture, save and send are swallowed; the upload has no auth header (AD-4); route pattern only (AD-6). The server needs a deploy for the `crash_reports` collection and the cron.
- Released as v2.2.0 (`pubspec.yaml` 2.2.0+6), closing M8.
