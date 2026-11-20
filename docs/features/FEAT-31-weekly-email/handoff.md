# Handoff: FEAT-31 — Weekly progress email
Branch: feat/FEAT-31-weekly-email · PR: https://github.com/codeforests/number-ninja/pull/38 (draft) · Updated: 2026-11-20 by design + build
Stage done: build (T1–T5 of 5); small feature, design carried straight into the build
Next: verify — kickoff: "Verify FEAT-31 on branch feat/FEAT-31-weekly-email. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Decisions WE-1..14 in design.md (auto mode), D26 and WEM-01..06 in 01-requirements.md; build notes in design.md.
- Server: `lib/weekly.js` does the work; the cron and `POST /api/nn/admin/weekly-email` both call `run(app, now, user)`. Tests drive time only through that admin route.
- `scripts/check.sh` with `server/test/run.sh` was green at the end of the build (1451 app tests; server suites incl. `weekly_email_test.dart` 9 cases, `resend_test.dart` header case).
- No new secret or env: the turn-off link uses a per-account random token (`users.email_token`, hidden).

## Left to CI or later
- APK build and CI: on the PR head.
- AC-10 live after the M9 deploy (FEAT-29 + FEAT-36 + FEAT-31 go out together): Ken's account turns the switch on and gets the Monday email; Ken can preview with the admin call (server/README "Weekly progress email").

## Pending for Ken
- none
