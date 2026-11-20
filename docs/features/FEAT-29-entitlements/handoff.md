# Handoff: FEAT-29 — Entitlements on the server
Branch: feat/FEAT-29-entitlements · PR: #35 · Updated: 2026-11-20 by verify
Stage done: verify (accepted)
Next: design FEAT-30 — kickoff: "Design FEAT-30 on branch feat/FEAT-30-plus-in-app (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- FEAT-30 reads Plus from `GET /api/nn/entitlement` (AD-5: `plus, until, source, status, will_renew, ended_at, checked_at`).
- Bank list/download now need Plus and a file token (`latestBank` asks for it when signed in).

## Left to CI or later
- Server not deployed yet: deploy (`deploy-server.yml`) together with the M9 app release, then check AC-9 (Ken's account `plus true`). A v2.2.0 tablet has no file token, so it keeps its bank until it updates.

## Pending for Ken
- none
