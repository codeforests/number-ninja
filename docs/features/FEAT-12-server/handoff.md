# Handoff: FEAT-12 — Server foundation
Branch: feat/FEAT-12-server · PR: none · Updated: 2026-11-16 by design (nginx revision)
Stage done: design
Next: build — kickoff: "Build FEAT-12 (from T1) on branch feat/FEAT-12-server. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Ken's droplet already runs nginx for audiodenoiser.com on 80/443: no Caddy. Deploy adds one nginx site + certbot certificate and must never touch other nginx files (design, "nginx, not Caddy").
- Hostname confirmed `api.brainbubblz.audiodenoiser.com`; Ken added the A record 2026-11-16.
- Hostname is only ever `SERVER_HOSTNAME` (repo variable) / `SERVER_URL` (dart-define); no hostname in code or tests. Short term `api.brainbubblz.audiodenoiser.com`, later `api.brainbubblz.com`.
- The cloud env can download the PocketBase release zip from github.com (checked 2026-11-16); pub.dev `pocketbase` Dart package is 0.26.0. Pick the latest stable PocketBase and pin it with its sha256 in `server/VERSION`.
- PocketBase ≥0.23 API: superusers are the `_superusers` collection, `pocketbase superuser upsert`, rules use `@request.body` (not `@request.data`). Check the migration JS API against the pinned version's docs, not memory.
- The live deploy (AC-6) needs Ken's setup (below); build everything else and leave AC-6 for verify/after merge.

## Left to CI or later
- APK manifest check and the `server` job run only in CI (no Android SDK here).
- AC-6 deploy and the droplet restore drill: after Ken's setup.

## Pending for Ken
- Setup still to do: deploy SSH key and user, firewall 80/443, repo secrets and the `SERVER_HOSTNAME` variable (steps in `server/README.md` once T3 lands; summary sent to Ken 2026-11-16).
