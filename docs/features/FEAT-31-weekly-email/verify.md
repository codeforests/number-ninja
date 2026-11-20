# FEAT-31: Verify

> Verdict: **accepted** (2026-11-20, auto mode). Verified at build head `23c0672`; this stage only adds docs.

## Checks re-run here

- `scripts/check.sh` on `23c0672`: format, analyze and the full `flutter test` PASS.
- `server/test/run.sh` PASS (main, restored, Resend and founding PocketBases); `dart analyze` in `server/test` clean.
- APK build and manifest check: CI on the final head (PR #38). No new plugin or Android config.
- Not run: AC-10 (live, after the M9 server deploy).

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `api_rules_test.dart` group `weekly_email`: own switch and tz readable and writable, another parent's not; `email_token` absent from view, update and list answers; `weekly_emails` list empty and view, create, update, delete refused for parents. |
| AC-2 | pass | `weekly_email_test.dart` "when it is sent": 07:59 local `notDue`, 08:00 one email to the account address and a `sent` row, second run nothing; Wednesday 08:00 dropped; a failed send logs nothing and the next run sends. |
| AC-3 | pass | switch off, unverified and expired Plus get nothing; idle family writes `skipped`; tz −300 parent is sent at their own Monday 08:00. |
| AC-4 | pass | preview: "Practised 1 h 12 min on 2 days", "3 rounds (1 revision)", "24 questions, 79% right (80% the week before)", "Topics to practise: Money (63%), Time (67%)" (incl. mixed round), badge names, idle sibling line, edge records outside the week not counted, `<b>Kai</b>` escaped, no images; nothing sent or logged. |
| AC-5 | pass | link and both List-Unsubscribe headers in the sent mail; Resend stub receives `headers` (`resend_test.dart`); GET changes nothing; wrong token or user changes nothing; right token turns off; 429 after 10 POSTs. |
| AC-6 | pass | admin route refuses parent and guest; preview returns subject and html only. |
| AC-7 | pass | `test/tool/server_names_test.dart`: topic and badge maps equal the Dart lists. |
| AC-8 | pass | `test/features/parent/weekly_email_test.dart`: server value, on writes tz, off, failed write restores with error line, tz refresh on open (and none when same), unverified, no Plus with Plus card, offline; SCR-20 line. |
| AC-9 | pass | checks above; CI on the PR head. |
| AC-10 | live, later | after the M9 deploy, not required to merge. |

## Beyond the tests

- Read `lib/weekly.js`, `weekly_email.pb.js`, the migration, `mail.pb.js` change, `WeeklyEmailSection` and the client calls. Values are escaped, the token compare is constant-time, GET never changes state, the send log's unique index backs the once-a-week rule. Changed older tests: only `account_screen` behaviour via the list key (build note); no assertion weakened or skipped.
- Notes (not fails): `weekly_email_tz` has no server default of 480 (PocketBase number default 0), but the app always writes the tz when turning the switch on, so it doesn't matter. The section keeps its own value after a write instead of invalidating `weeklyEmailProvider` (WE-13 wording); the screen shows the right state either way.
