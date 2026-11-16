# Handoff: FEAT-14 — Progress sync
Branch: feat/FEAT-14-sync · PR: https://github.com/codeforests/number-ninja/pull/19 (draft) · Updated: 2026-11-16 by verify
Stage done: verify (rework)
Next: rework fix — kickoff: "Fix FEAT-14 rework on branch feat/FEAT-14-sync. Read docs/STATE.md, the handoff.md and the "Rework" section of verify.md, then do the Rework fix stage in AGENTS.md."

## What the next stage needs
- One bug: `SyncService._child` skips `pending_reset` while `child_id` is null (verify.md "Rework" has the repro and fix).
- Verified commit: `f47a334`. Re-verify kickoff: "Re-verify FEAT-14 on branch feat/FEAT-14-sync since f47a334. Read docs/STATE.md and the handoff.md, then do the Re-verify stage in AGENTS.md."
- Re-verify: run `server/test/run.sh` too (AC-6/7), and CI once on the final head (subscribe to PR #19); then fill Verified by for SYN-01..07, NFR-16 and mark the PR ready.

## Left to CI or later
- CI not run in verify (saved for the re-verify head). AC-9 on Ken's tablets with the M6 APK.

## Pending for Ken
- After merge: OK to run "Deploy server" (new migration + reset hook on the droplet), then the M6 APK with SERVER_URL.
