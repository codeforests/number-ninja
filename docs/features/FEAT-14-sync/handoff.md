# Handoff: FEAT-14 — Progress sync
Branch: feat/FEAT-14-sync · PR: https://github.com/codeforests/number-ninja/pull/19 · Updated: 2026-11-16 by re-verify
Stage done: verify (accepted on re-verify; fix f185da2)
Next: merge (Ken), then "Deploy server", then M6 release; then FEAT-15 design — kickoff: "Design FEAT-15 on branch feat/FEAT-15-<slug> (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- `verify.md` top section has the re-verify; SYN-01..07 and NFR-16 Verified by cells filled ("live at AC-9").
- Deploy server must run after merge: new migration `1763251203_sync.js` and `pb_hooks/reset.pb.js` on the droplet.
- M6 APK needs SERVER_URL; per FEAT-13, sign-up mail needs the Brevo secret set first.

## Left to CI or later
- AC-9 (two tablets with the M6 APK: progress shows on the other after Sync now; reset clears the other).

## Pending for Ken
- Merge PR #19; OK to run "Deploy server"; then the M6 APK.
