# Handoff: FEAT-30 — Free tier and Plus in the app
Branch: feat/FEAT-30-plus-in-app · PR: none · Updated: 2026-11-20 by design
Stage done: design
Next: build — kickoff: "Build FEAT-30 (from T1) on branch feat/FEAT-30-plus-in-app. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- 7 tasks (T1–T7), so a separate build; stop at a task boundary after ~6 and hand off if long.
- Requirements D24 and PLS-01..08 and the SCR-20 row in `02-design.md` §6 are already written; build fills Feature/Verified cells only at the end (T7) and adds the change-log line.
- Server is done (FEAT-29); read only `GET /api/nn/entitlement` (FEAT-29 AD-5 fields). No server change.
- Cache is a new single-row table `plus_state` (schema v12), not `app_settings` columns (PD-3): avoids the `_from6To7` trap.
- Harness defaults `plus: true` so existing tests keep their behaviour; new free-tier tests pass `plus: false` (PD-12).
- Siblings on free (PD-6): keep `ChildRepository.add`'s `maxChildren`; screens use `childLimit(plus)`. `pickerShows` must also need Plus.
- Child lock only on SCR-02 (PD-8, Families policy); none on SCR-05.

## Left to CI or later
- AC-9 live check with the M9 release, after `deploy-server.yml` ships FEAT-29.

## Pending for Ken
- none to build. At the M9 release: every family tablet must be signed in to keep Plus features (PD-2); say so in the release note.
