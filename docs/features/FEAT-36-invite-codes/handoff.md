# Handoff: FEAT-36 — Invitation codes
Branch: feat/FEAT-36-invite-codes · PR: https://github.com/codeforests/number-ninja/pull/37 · Updated: 2026-11-20 by verify
Stage done: verify (accepted)
Next: design FEAT-31 — kickoff: "Design FEAT-31 on branch feat/FEAT-31-weekly-email (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- FEAT-36 verify.md has the evidence. Server not deployed yet: FEAT-29 + FEAT-36 go out with the M9 app release.

## Left to CI or later
- AC-11 live: after `deploy-server.yml` with the M9 release, Ken runs "Make invitation codes" and a test account redeems on a tablet (optional repo secret `INVITE_MAIL_TO`).
- FEAT-29 rate-limit rule `/api/nn/billing/` never applies; fix in FEAT-35.

## Pending for Ken
- none
