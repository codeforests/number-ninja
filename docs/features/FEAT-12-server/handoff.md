# Handoff: FEAT-12 — Server foundation
Branch: feat/FEAT-12-server · PR: see STATE / draft PR · Updated: 2026-11-16 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-12 on branch feat/FEAT-12-server. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- No Caddy: the droplet's nginx (serves audiodenoiser.com). `server/install.sh` writes only `/etc/nginx/sites-available/numberninja.conf` + link, `nginx -t` before reload, undoes its change on failure. Certificate via `certbot certonly --webroot` (design "Build notes"), so certbot edits no nginx file.
- PocketBase 0.40.6 pinned (`server/VERSION`). Server tests: `server/test/run.sh` (starts PB via `scripts/server-local.sh`, 25 rule tests + backup, restores with `restore.sh` into a 2nd PB on 8091, checks it). Install shellcheck with `pip install shellcheck-py` (apt has none).
- PB rate limit (2 sign-ins / 3 s per IP) is on: tests sign in via `signIn()` retry. `trustedProxy.headers = ["X-Real-IP"]` so limits are per client behind nginx.
- CI manifest check now requires the permission list to be exactly `android.permission.INTERNET`; if CI shows another plugin permission that was there before FEAT-12, the check (not the app) needs the baseline added.
- Release APK gets `SERVER_URL=https://$SERVER_HOSTNAME` only when the repo variable is set; tests and local builds are offline (`ServerConfig.none`).
- `install.sh`/`deploy.sh` are shellchecked only: no nginx/systemd in the cloud env. AC-6 is their real test.

## Left to CI or later
- APK build + manifest check and the `server` job run in CI only.
- AC-6 (deploy, health 200 with valid cert, `/_/` 404, tablet "Connected") and the droplet restore drill: after Ken's setup.

## Pending for Ken
- Setup in `server/README.md` "One-time setup": deploy user + key, `ssh-keyscan` line, repo secrets, variable `SERVER_HOSTNAME=api.brainbubblz.audiodenoiser.com`. Then run "Deploy server".
