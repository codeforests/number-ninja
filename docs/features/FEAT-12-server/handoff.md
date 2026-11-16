# Handoff: FEAT-12 — Server foundation
Branch: feat/FEAT-12-server · PR: #17 (draft) · Updated: 2026-11-16 by rework fix
Stage done: rework fix (`a48c727`), verified commit `d392ebc`
Next: re-verify — kickoff: "Re-verify FEAT-12 on branch feat/FEAT-12-server since d392ebc. Read docs/STATE.md and the handoff.md, then do the Re-verify stage in AGENTS.md."

## What the next stage needs
- Rework 1: template now `listen 443 ssl http2;` / `listen [::]:443 ssl http2;`; header comment says install.sh's `sed`, not envsubst.
- Rework 2: `install.sh` duplicate-hostname check uses `grep -RlE`.
- New CI step "nginx -t on the rendered site file" in the `server` job (apt nginx, self-signed cert at `/etc/letsencrypt/live/api.example.test/`, same sed as install.sh, symlink into sites-enabled, `sudo nginx -t`).
- Also: shellcheck 0.9.0 (ubuntu-24.04) flagged SC2015 on two `install.sh` lines and one `scripts/server-local.sh` line; rewritten as `if` with the same logic.
- Checked here on nginx 1.24.0 (Ubuntu): new template `nginx -t` ok, old one "unknown directive http2"; `-R` finds a symlinked duplicate, `-r` doesn't; shellcheck clean. The container has no IPv6, so the `[::]` lines were dropped for the local run only.
- Commits are `[skip ci]`; re-verify runs CI once.

## Left to CI or later
- `nginx -t` with the `[::]` listens (CI runner); AC-6 live deploy and restore drill after Ken's setup.

## Pending for Ken
- Setup in `server/README.md` "One-time setup"; run "Deploy server" only after re-verify passes.
