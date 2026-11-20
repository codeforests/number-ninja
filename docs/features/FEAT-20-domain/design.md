# FEAT-20: Own domain brainbubblz.com and new app id

> Implements: D19 · Screens: none (server host, Android id, sign-in return page, emails)
> Status: built · Branch: `claude/project-thread-wqok43` · 2026-11-20

## Scope

The server answers at `api.brainbubblz.com`; the old `api.brainbubblz.audiodenoiser.com` stays served as a legacy alias so the installed v2.0.1 keeps working until the tablet switches. The Android app id becomes `com.brainbubblz.kids` (Ken's pick 2026-11-20) and the Google sign-in return link `brainbubblz://signin`. Email comes from `noreply@brainbubblz.com` through Resend. Version `2.1.0+5`. Ken's console steps: `ken-steps.md`.

Not in scope: Dart package `number_ninja`, server unit/nginx/user names, keystore alias, Drift file name, badge id (internal, no one sees them); the new droplet; Play upload.

## Design decisions (this feature)

- **D-1 Legacy host.** Optional repo variable `SERVER_LEGACY_HOSTNAME`, passed `deploy-server.yml` → `deploy.sh` → `install.sh`. Same nginx site (`server_name` lines for both; lines naming the legacy host are dropped when it's empty), rendered by `server/nginx/render.sh` (used by `install.sh` and the CI `nginx -t` step).
- **D-2 One certificate** with `--cert-name $SERVER_HOSTNAME` for both names, (re)issued only when missing or its SAN list differs. Meanwhile 443 keeps pointing at a certificate that exists (own, or the legacy host's on the move), so the old app never loses HTTPS; on a certbot failure the previous site is put back.
- **D-3 Return page by host.** `map $host $brainbubblz_app_scheme` picks `numberninja` on the legacy host (old APKs are the old id with that scheme) and `brainbubblz` elsewhere; the `/signin/google` body uses that variable. The redirect URL is `https://<host the app was built for>/signin/google`, so each app gets its own scheme back.
- **D-4 New app id, not an update.** `com.brainbubblz.kids` installs next to the old app; data returns through sign-in and sync (D10); the PIN is set again. Method channel renamed `brainbubblz/sign_in`.
- **D-5 Email.** Code unchanged: `MAIL_SENDER_ADDRESS` secret becomes `noreply@brainbubblz.com` once Resend verifies the domain; links use `appURL` = `https://SERVER_HOSTNAME`. Sender name stays the app name.
- **D-6 Google.** Same Web OAuth client; add the new host's `/signin/google` redirect URI and the authorized domain. No Android client (browser-tab flow).

## Acceptance criteria

- AC-1 `build.gradle.kts` id and namespace, Kotlin package, manifest scheme, Dart channel all say `com.brainbubblz.kids` / `brainbubblz` (`test/tool/app_id_test.dart`; CI merged-manifest check).
- AC-2 Rendered site passes `nginx -t` with and without a legacy host; `/signin/google` opens `brainbubblz://` on the host and `numberninja://` on the legacy host (CI `server` job).
- AC-3 `install.sh` issues one certificate for both names, keeps HTTPS on the legacy host while it does, restores the previous site on a certbot failure (review; live on Deploy server).
- AC-4 `deploy.sh` checks the new host's page (`brainbubblz://`) and, when set, the legacy host's health and page (`numberninja://`).
- AC-5 Live, after Ken's steps: Deploy server green; on the tablet the new APK signs in by email and Google against `api.brainbubblz.com`, progress comes back by sync, a reset email comes from `noreply@brainbubblz.com`; the old app still syncs on the legacy host until uninstalled.
- AC-6 Version `2.1.0+5`; full `scripts/check.sh` green.

## Tasks

- T1 Server: legacy host, render script, one certificate, return page by host, deploy checks, CI nginx test. ✓
- T2 App: app id, Kotlin package, scheme, channel, version, tests, CI manifest check. ✓
- T3 Docs: server README, `ken-steps.md`, D19, plan row, code-map, STATE. ✓
