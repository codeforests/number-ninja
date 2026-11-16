# Handoff: FEAT-13 — Parent account
Branch: feat/FEAT-13-account · PR: https://github.com/codeforests/number-ninja/pull/18 (ready) · Updated: 2026-11-16 by verify
Stage done: verify (accepted; AC-6 live pending)
Next: Ken merges PR #18; then FEAT-14 design — kickoff: "Design FEAT-14 on branch feat/FEAT-14-sync (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- `accountProvider` (`AccountRepository`) is the hook for FEAT-14 to start/stop sync; `refresh()` renews the 30-day token.
- Verify notes in `verify.md` "Beyond the tests": with SMTP off sign-up still says "Check your inbox" (server returns 204); Google tab closed early keeps SCR-13 busy up to 3 minutes.
- FEAT-14 design should set STATE "Merged" to include FEAT-13 (PR #18).

## Left to CI or later
- shellcheck runs only in CI (not installable here). CI on the verify head: see PR #18 checks.
- AC-6 live flows: after Ken's Brevo + Google setup, "Deploy server", and the M6 test APK.

## Pending for Ken
- Merge PR #18.
- Before AC-6 / any SERVER_URL APK: Brevo SMTP key + verified sender, Google Cloud Web OAuth client (redirect `https://<SERVER_HOSTNAME>/api/oauth2-redirect`); repo secrets SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, MAIL_SENDER_ADDRESS, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET; then run "Deploy server".
- FEAT-12 restore drill after the first nightly backup.
