# Handoff: FEAT-24 — Crash reports
Branch: feat/FEAT-24-crash-reports · PR: draft (see STATE) · Updated: 2026-11-20 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-24 on branch feat/FEAT-24-crash-reports. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- AC → tests: AC-1/2 `test/data/crash_reporter_test.dart` + `test/features/crash/crash_app_test.dart`; AC-3 `test/data/crash_repository_test.dart`; AC-4 both reporter tests + `test/live/crash_live_test.dart` (in `server/test/run.sh`); AC-5 `migration_test.dart` group v11 + `test/features/parent/crash_switch_test.dart`; AC-6 `server/test/test/api_rules_test.dart` group `crash_reports`; AC-7 `server/test/test/crash_digest_test.dart` + last case of `resend_test.dart`.
- Deviations (recorded in 02-design change log): `install()` chains to the previous `FlutterError.onError` (default `presentError`; in tests the test binding's); device info is loaded in `main()` before `runApp`, so no `deviceInfoProvider`; crash context reads `bankProvider` (not `activeBankProvider`).
- Digest retention by `created`; `CRASH_KEEP_DAYS` (default 90) is a test knob, set to 0 on the main test server so the digest test proves the delete. Deploy passes optional secret `CRASH_DIGEST_TO` (workflow → deploy.sh → install.sh env file).
- SCR-13's ListView now restarts at the top on the delete-PIN step (key on `_confirmingDelete`): the longer privacy note had scrolled the PIN message out of the lazy list.
- `server/test/run.sh` passed locally (PocketBase 0.40.6); `scripts/check.sh` passed (full suite).

## Left to CI or later
- APK build proves the Kotlin `brainbubblz/device` channel compiles; nothing ran it on a device.
- AC-8 live check on the tablet is Ken's, optional.

## Pending for Ken
- none (optional: add repo secret `CRASH_DIGEST_TO` and redeploy for the daily email)
