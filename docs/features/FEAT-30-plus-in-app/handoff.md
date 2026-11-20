# Handoff: FEAT-30 — Free tier and Plus in the app
Branch: feat/FEAT-30-plus-in-app · PR: https://github.com/codeforests/number-ninja/pull/36 · Updated: 2026-11-20 by verify
Stage done: verify (accepted)
Next: design FEAT-36 — kickoff: "Design FEAT-36 on branch feat/FEAT-36-invite-codes (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- `verify.md` "Beyond the tests": the launch bank check can see Plus as off while the cache loads; FEAT-36 (next Plus feature) should add a task so `checkBank` awaits `plusCacheProvider.future` (code-map gotcha).
- FEAT-36 adds an "Enter a code" row to SCR-20 (`plus_screen.dart`); redeeming should call `plusControllerProvider.notifier.check()` to refresh.

## Left to CI or later
- AC-9 live check with the M9 release, after `deploy-server.yml` ships FEAT-29.

## Pending for Ken
- At the M9 release: every family tablet must be signed in to keep Plus features (PD-2); say so in the release note.
