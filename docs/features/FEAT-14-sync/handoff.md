# Handoff: FEAT-14 — Progress sync
Branch: feat/FEAT-14-sync · PR: https://github.com/codeforests/number-ninja/pull/19 (draft) · Updated: 2026-11-16 by rework fix
Stage done: rework fix (SYN-06 reset before first sync)
Next: re-verify — kickoff: "Re-verify FEAT-14 on branch feat/FEAT-14-sync since f47a334. Read docs/STATE.md and the handoff.md, then do the Re-verify stage in AGENTS.md."

## What the next stage needs
- Verified commit: `f47a334`. Fix is in `SyncService._child` and `_linkAccount` (`lib/data/sync/sync_service.dart`).
- `_child`: the `pendingReset` branch now runs first and also sets `childId`, so a newly linked device calls the reset route before push/pull.
- `_linkAccount` now keeps `pendingReset` on a first link (no previous account) and clears it only on an account switch. Found while fixing: if the first run failed at `refresh` (before linking), the link used to drop the reset too.
- Tests: two new cases in the `reset` group of `test/data/sync/sync_service_test.dart` (fail at `listChildren`, fail at `refresh`); both fail on `f47a334` and pass now. `scripts/check.sh` all pass (full suite).
- Re-verify: run `server/test/run.sh` too (AC-6/7), and CI once on the final head (subscribe to PR #19); then fill Verified by for SYN-01..07, NFR-16 and mark the PR ready.

## Left to CI or later
- CI not run (fix commit is `[skip ci]`; re-verify runs it once). AC-9 on Ken's tablets with the M6 APK.

## Pending for Ken
- After merge: OK to run "Deploy server" (new migration + reset hook on the droplet), then the M6 APK with SERVER_URL.
