# FEAT-20: Verify

> Verdict: **accepted** (2026-11-20). CI run 44693882955 green on 0cfca2a (build + manifest check, server + nginx). Code verified at `eee96d2`; this stage only fixed the stale app-id note in `README.md`. AC-5 is live-only and waits for Ken's steps.

## Checks re-run here

- `scripts/check.sh` (format, analyze, full `flutter test`): all PASS.
- `server/nginx/render.sh` rendered without and with a legacy host (and `CERT_NAME` = legacy): no `${...}` left, no empty `server_name`, map line only with a legacy host, 443 cert folder follows `CERT_NAME`. `nginx -t`, the return-page curls, the APK build and the merged-manifest check run in CI on the final head (no nginx or Android SDK here).
- Not run: `server/test/run.sh` (PocketBase download), live DNS (no resolver here).

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `test/tool/app_id_test.dart` (Gradle id + namespace, Kotlin package and folder, manifest scheme, Dart + Kotlin channel, nginx map); CI manifest grep for `package="com.brainbubblz.kids"` and `android:scheme="brainbubblz"`. Repo grep: no `com.codeforests.number_ninja` or `number_ninja/sign_in` left outside history docs. |
| AC-2 | pass (CI) | `ci.yml` server job: `nginx -t` with and without legacy host, curl asserts `brainbubblz://` on the host and `numberninja://` on the legacy host. |
| AC-3 | pass (review) | `install.sh`: SAN compare (`openssl x509 -ext subjectAltName`, sorted) so certbot runs only when names differ; interim 443 on the host cert, else the legacy cert, else port 80 only; `--cert-name $host` with `-d` per name (non-interactive accepts the domain change); on failure the pre-interim site is reinstalled and nginx reloaded. Both names are checked against other nginx sites. Live proof: Deploy server. |
| AC-4 | pass | `deploy.sh` greps `brainbubblz://signin/google` on the host; when the legacy var is set, checks its `/api/health` and `numberninja://` page. |
| AC-5 | pending (live) | Needs ken-steps 1–4, merge, Deploy server, `v2.1.0`, tablet switch (step 7). |
| AC-6 | pass | `pubspec.yaml` `2.1.0+5`; `scripts/check.sh` green. |

## Beyond the tests

- Order matters: Deploy server must run only after `SERVER_HOSTNAME` = `api.brainbubblz.com` and `SERVER_LEGACY_HOSTNAME` are set (step 4). Deployed with the old host as `SERVER_HOSTNAME` and no legacy var, the old host would get `brainbubblz://` and the installed app's Google sign-in would stop returning. The release APK also takes its server URL from `SERVER_HOSTNAME`, so build it after step 4.
- `MAIL_SENDER_ADDRESS` must change only after Resend verifies the domain (ken-steps says so).
- The old certificate lineage keeps renewing until `certbot delete` (README/ken-steps "Later"); harmless.
- D19 is a decision row; `01-requirements.md` has no Feature/Verified by cells for decisions, so none to fill.
