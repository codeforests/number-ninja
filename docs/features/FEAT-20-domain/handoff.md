# Handoff: FEAT-20 — Own domain and new app id
Branch: claude/project-thread-wqok43 · PR: https://github.com/codeforests/number-ninja/pull/30 (ready) · Updated: 2026-11-20 by verify
Stage done: verify (accepted)
Next: Ken — steps 1–4 of `ken-steps.md`, then merge on his go, Deploy server, release `v2.1.0`, tablet switch (step 7).

## What the next stage needs
- Verify notes in `verify.md`. Deploy server and the release APK need step 4's GitHub variables first (else the old app's Google return breaks and the APK points at the old host).
- Release asset name `brainbubblz-v2.1.0.apk` (ken-steps step 7).

## Left to CI or later
- AC-5 live after the deploy. `server/test/run.sh` runs in CI.

## Pending for Ken
- ken-steps 1–4 before merge; say go to merge, deploy and release.
