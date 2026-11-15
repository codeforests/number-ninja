# Handoff: FEAT-10 — Child profile
Branch: feat/FEAT-10-child-profile · PR: draft (see STATE) · Updated: 2026-11-15 by design + build
Stage done: build (T1–T5 of 5)
Next: verify — kickoff: "Verify FEAT-10 on branch feat/FEAT-10-child-profile. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Tests: `test/domain/profile_test.dart`, `test/data/profile_repository_test.dart`, migration v3 → v4 in `test/data/migration_test.dart`, `test/features/profile/` (flow, start level, layout). Full `scripts/check.sh` passed: 735 tests.
- Existing tests touched, none weakened: migration tests expect `user_version` 4 instead of 3; `round_repository_test` gained a case; `ParentHarness.tapKey` now scrolls a lazy list to a tile not yet built (the new profile tile at the top of SCR-11 pushed "Reset all progress" out of the built range).
- Deviation: `childProfileProvider` is a FutureProvider invalidated after a save, not a Drift stream (pending-timer failures in widget tests). Recorded in design.md and code-map Gotchas.
- `profile_pending` defaults true for new installs and is set false on upgrade, so the v1.0 tablet goes straight home and gets the profile from SCR-11 (PRO-02). To see the first-run flow on a device, clear app data.
- The P1-topic quiz case of AC-4 is checked through SCR-03 tile labels (the fake quiz bank has only P2 topics); the rule itself is covered for every year in `profile_test.dart`.

## Left to CI or later
- APK build only in CI (no Android SDK here). This is the session's last push, so CI runs on the draft PR.

## Pending for Ken
- none (on-tablet check at the M5 milestone)
