# FEAT-12: Verify

## Re-verify (2026-11-16, `d392ebc`..`1e6914a` plus one CI-check fix)

> Fresh thread · Verdict: **accepted** (rework fixed; AC-1..AC-5 pass, AC-6 live deploy pending)

- Rework 1 (http2): template now `listen 443 ssl http2;` / `listen [::]:443 ssl http2;`, no `http2 on;`; header comment fixed. CI step renders it with install.sh's `sed` and runs `nginx -t` on stock Ubuntu nginx: passes (CI run 43864304629).
- Rework 2 (symlinks): duplicate-host check is `grep -RlE`. The three SC2015 rewrites (`install.sh` x2, `server-local.sh`) keep the same logic (fail when either value is empty / either dir is missing; kill only if the pid file exists).
- Manifest permission check (`c64f1c0`): counts `<uses-permission>` names only, so profileinstaller's receiver guard `DUMP` no longer trips it. Found here: it missed a `<uses-permission>` written over several lines (the merged manifest puts each attribute of a multi-attribute element on its own line), so an extra permission with `maxSdkVersion` would pass. Fixed in the check (join lines with `tr` first); shown on a sample manifest (old: INTERNET only; new: INTERNET + the multi-line one).
- `scripts/check.sh`: format, analyze, 863 tests pass. shellcheck and nginx aren't installable in this container (no apt source), so both run only in CI: [43864304629](https://github.com/codeforests/number-ninja/actions/runs/43864304629) on `91d8f5e` green: server job (shellcheck, rule tests, restore, nginx -t) and build job (tests, APK, manifest check).

> Verified 2026-11-16 in a fresh thread that did not write the code · Commit under test: `d392ebc` (plus `797b8a2`, a one-line README change) · Verdict: **rework** (two small deploy-script defects; AC-1..AC-5 pass)

## Rework

1. **`http2 on;` breaks `nginx -t` on Ubuntu's nginx.** `server/nginx/numberninja.conf.template` uses the `http2 on;` directive, which exists only from nginx 1.25.1. Ubuntu 24.04 ships 1.24, 22.04 ships 1.18, Debian 12 ships 1.22, so on the droplet's stock nginx the full site fails `nginx -t` ("unknown directive"), `install.sh` undoes it and exits 1: AC-6 can't pass. (The bootstrap port-80 site would have passed, so the certificate step works and only the final step fails.) Fix: drop `http2 on;` and write `listen 443 ssl http2;` / `listen [::]:443 ssl http2;`, which every nginx from 1.9.5 accepts (1.25.1+ only warns). Add a CI check that greps the template for `http2 on` or, better, runs `nginx -t` on the rendered template in the `server` job (`apt-get install nginx` on ubuntu-latest gives 1.24 too, with a self-signed cert for the paths).
2. **Duplicate-hostname check never sees enabled sites.** `install.sh` looks for another site with the same `server_name` using `grep -rlE … /etc/nginx/sites-enabled/`; `grep -r` doesn't follow symlinks inside a directory, and every Debian `sites-enabled` entry is a symlink, so the check finds nothing (shown here with a symlinked test dir: `-r` no match, `-R` match). Fix: `grep -RlE`. Also correct the template's header comment ("envsubst" → the `sed` that `install.sh` uses).

Re-verify needs only: the rendered template passes `nginx -t` (CI), the `-R` change, shellcheck, CI once.

## Checks re-run from a clean checkout

Fresh clone at `d392ebc`, Flutter 3.50.0 (CI's pin), PocketBase 0.40.6 (sha256 checked by `server-local.sh`).

| Check | Result |
|---|---|
| `scripts/check.sh` (format, analyze, test) | all PASS, 863 tests |
| `shellcheck server/*.sh scripts/server-local.sh server/test/run.sh` | PASS |
| `server/test/run.sh` (rules, backup, `restore.sh` into a 2nd PB, restored check) | PASS |
| CI on `d392ebc` | `server` job green ([run 43862518171](https://github.com/codeforests/number-ninja/actions/runs/43862518171)); `build` (APK + manifest) see the PR checks |

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `server/` has every listed file; shellcheck clean; `migrate up` on an empty dir creates the collections (run.sh starts from empty `build/server-test`); rules, fields, indexes and settings read match design. |
| AC-2 | pass | `api_rules_test.dart`: B and anonymous get no list rows, view 404, update 403/404, create 400/403 for child and all four per-child collections; owner list/view/update; attempt update/delete refused; delete 403 for rounds/badges/usage, superuser deletes; round can't move to B's child, child can't move to B, child can't be created for B or anonymously; duplicate uuids and badge per child rejected; banks list for anyone, create superuser only. |
| AC-3 | pass | `backup_test.dart` (cron `0 19 * * *`, keep 14, backup zip via API) → `restore.sh` with `PB_SERVICE=` → `restore_check_test.dart` signs in as A on the restored server and reads every record and the settings. |
| AC-4 | pass (CI part pending in `build`) | `server_config_test.dart` covers empty, `http://`, junk, `https://host`; manifest and network config read; CI check now requires exactly INTERNET, cleartext false, the config. |
| AC-5 | pass | `server_row_test.dart`: "Not set up" with no call, Connected, offline text, layout checks at 1.3. |
| AC-6 | not run | Needs Ken's setup in `server/README.md`; blocked by Rework 1 until fixed. |

## Beyond the tests

- **Code read:** `install.sh` touches only its own site file and link, runs `nginx -t` before every reload and restores the previous file on failure; secrets come on stdin; `IFS='=' read` keeps `=` inside a password (checked). `restore.sh` copies the zip out of `pb_data` before moving it, keeps the old data and backups. Unit listens on 127.0.0.1 only, `ProtectSystem=strict` with `pb_data` writable.
- **Nit (FEAT-13):** the settings migration sets `meta.appURL` from `SERVER_HOSTNAME` once; when the hostname changes to `api.brainbubblz.com`, re-running migrations won't update it, and FEAT-13's email links use it. Add a step or migration then.
- **Nit:** `ServerConfig.parse` `replace(query: null)` keeps a query rather than dropping it; harmless for a build define.

## Test diff review

All test files are new (`server/test/**`, `test/data/server_config_test.dart`, `fake_server_client.dart`, `server_row_test.dart`); no existing test changed, no `skip:` except the restore check's skip outside `run.sh`, which `run.sh` runs.
