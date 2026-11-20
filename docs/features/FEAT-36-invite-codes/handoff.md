# Handoff: FEAT-36 — Invitation codes
Branch: feat/FEAT-36-invite-codes · PR: (draft, see STATE/PR list) · Updated: 2026-11-20 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-36 on branch feat/FEAT-36-invite-codes. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Deviations are in design.md "Build notes": rate-limit label is `POST /api/nn/invite/` (a bare prefix never applied; FEAT-29's `/api/nn/billing/` has the same bug, left for FEAT-35); the admin endpoint mails only with `send_to` (address or `"default"`), tool `--send-to`/`--email`.
- Server tests: `invite_test.dart` and `make_invites_test.dart` run on the main PocketBase in `server/test/run.sh`; redeem calls send a random `X-Real-IP` so only AC-5 hits the limit.
- App: `test/features/parent/invite_code_test.dart` (AC-7, AC-8) uses new `QuizHarness.realPlus`; AC-9 in `test/domain/plus_test.dart`; AC-10 group "checkBank at launch" in `test/data/bank_updater_test.dart`; `storeEntitlement` case in `plus_repository_test.dart`.
- Last local run: `scripts/check.sh` all pass (flutter test 232 s), `server/test/run.sh` pass, server `dart analyze` clean. CI not run yet (build commits are `[skip ci]` except the last push).

## Left to CI or later
- APK build and manifest check (CI only). AC-11 live check with the M9 release after `deploy-server.yml` ships FEAT-29 + FEAT-36 (add repo secret `INVITE_MAIL_TO` if codes should go somewhere other than `CRASH_DIGEST_TO`).

## Pending for Ken
- none
