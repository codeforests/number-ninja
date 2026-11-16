# Handoff: FEAT-12 — Server foundation
Branch: feat/FEAT-12-server · PR: #17 (ready) · Updated: 2026-11-16 by re-verify
Stage done: verify (accepted after rework; CI green on `91d8f5e`)
Next: AC-6 live deploy, then Ken's merge of PR #17; then FEAT-13 design — kickoff: "Design FEAT-13 on branch feat/FEAT-13-account (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- Rework items 1 and 2 fixed and checked in CI (`nginx -t` on stock Ubuntu nginx, `grep -RlE`). See the top of verify.md.
- Re-verify tightened the CI manifest permission check: it joins the manifest's lines before matching `<uses-permission>`, because multi-attribute elements span lines and were missed.
- AC-6 (live deploy and restore drill on the droplet) is not verified yet: it needs the "Deploy server" workflow run, a production change that waits on Ken's go.

## Left to CI or later
- AC-6 live deploy and restore drill after "Deploy server" runs.

## Pending for Ken
- Setup done 2026-11-16 (still confirming PB_SUPERUSER_EMAIL/PASSWORD and SERVER_HOSTNAME); next is running "Deploy server" for AC-6 now that re-verify passed.
- Merge PR #17.
