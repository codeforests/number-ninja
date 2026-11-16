# Handoff: FEAT-13 — Parent account
Branch: feat/FEAT-13-account · PR: none · Updated: 2026-11-16 by design
Stage done: design
Next: build — kickoff: "Build FEAT-13 (from T1) on branch feat/FEAT-13-account. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- 6 tasks, no Drift schema change. T1 adds two plugins: open the draft PR at T1 so CI proves the APK build.
- Server secrets reach PocketBase through `pb_hooks/config.pb.js` on every start (env in `/etc/default/numberninja-pb`), not a migration, so secrets added later and a hostname change both take effect on redeploy. Missing secrets = feature off, deploy still green.
- Google uses PocketBase's browser OAuth2 flow (Web client, redirect `https://<host>/api/oauth2-redirect`), not `google_sign_in`.
- Email links open `pb_public/verify.html` and `reset.html` on the server; no Android deep links.
- `children` create now also needs `@request.auth.verified = true` (new migration); FEAT-12's AC-2 tests create children with verified users, check they still do.
- The cloud container's proxy can't reach the live server: live checks only through workflow logs or Ken's tablet.

## Left to CI or later
- APK build and manifest check (CI). AC-6 live flows wait for Ken's setup and the M6 test APK.

## Pending for Ken
- Before AC-6 (not blocking the build): a Brevo account (SMTP key, sender verified) and a Google Cloud Web OAuth client; add repo secrets SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, MAIL_SENDER_ADDRESS, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET. Steps go in `server/README.md` (T2).
- FEAT-12 restore drill after the first nightly backup.
