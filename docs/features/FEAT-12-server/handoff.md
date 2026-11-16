# Handoff: FEAT-12 — Server foundation
Branch: feat/FEAT-12-server · PR: #17 (draft) · Updated: 2026-11-16 by verify
Stage done: verify (rework) at `d392ebc`
Next: rework fix — kickoff: "Fix FEAT-12 rework on branch feat/FEAT-12-server. Read docs/STATE.md, the handoff.md and the "Rework" section of verify.md, then do the Rework fix stage in AGENTS.md."

## What the next stage needs
- Two fixes, both in `verify.md` "Rework": nginx template `http2 on;` → `listen 443 ssl http2;` (stock Ubuntu nginx 1.24 rejects `http2 on`), and `grep -RlE` in `install.sh`'s duplicate-hostname check.
- Prove the template in CI: in the `server` job, render it with a test hostname, make a self-signed cert at the `/etc/letsencrypt/live/<host>/` paths, `sudo apt-get install -y nginx`, include it and run `sudo nginx -t`.
- Re-verify kickoff after the fix: "Re-verify FEAT-12 on branch feat/FEAT-12-server since d392ebc. Read docs/STATE.md and the handoff.md, then do the Re-verify stage in AGENTS.md."

## Left to CI or later
- AC-6 (live deploy, health 200, `/_/` 404, tablet "Connected") and the droplet restore drill after Ken's setup.

## Pending for Ken
- Setup in `server/README.md` "One-time setup" (deploy user + key, `ssh-keyscan` line, repo secrets, variable `SERVER_HOSTNAME=api.brainbubblz.audiodenoiser.com`). He can do it now; run "Deploy server" only after the rework fix.
