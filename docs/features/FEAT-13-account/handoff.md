# Handoff: FEAT-13 — Parent account
Branch: feat/FEAT-13-account · PR: https://github.com/codeforests/number-ninja/pull/18 (draft) · Updated: 2026-11-16 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-13 on branch feat/FEAT-13-account. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Deviations: the session is written to `TokenStore` explicitly after each auth call (plain `AuthStore` in memory) instead of `AsyncAuthStore`, so a write is done when the call returns. `AuthError.badEmail` and `AccountNotice.deleted` were added. `AccountRepository` is the notifier behind `accountProvider`. T4 and T5 are one commit (one screen file).
- Google: `signInBrowserProvider` opens the Custom Tab and tries `closeInAppWebView` after; the 3-minute timeout maps to `cancelled`.
- Server tests: `server/test/run.sh` starts PocketBase with SMTP pointing at the sink that `auth_test.dart` opens (port 2526) and dummy Google secrets; the restored instance starts without them, and `restore_check_test.dart` checks mail and Google are off. `dart test --concurrency=1` now (sink port). All 34 server tests passed locally.
- AC-2 note: links match `https://api.example.test/verify.html?token=…` (SERVER_HOSTNAME sets appURL in the hook).
- Gotchas added to `code-map.md` (JWT-shaped test tokens; verified test parents).

## Left to CI or later
- CI green on 470a402 (server job + APK build with both plugins). The APK build needed CI on JDK 21 (Android lint crash on JDK 17, see code-map Gotchas). shellcheck clean.
- AC-6 live flows wait for Ken's Brevo + Google setup (`server/README.md`) and the M6 test APK.

## Pending for Ken
- Before AC-6 (not blocking verify): Brevo SMTP key + verified sender and a Google Cloud Web OAuth client; repo secrets SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, MAIL_SENDER_ADDRESS, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET; then run "Deploy server".
- FEAT-12 restore drill after the first nightly backup.
