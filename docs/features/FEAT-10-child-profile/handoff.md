# Handoff: FEAT-10 — Child profile
Branch: feat/FEAT-10-child-profile · PR: https://github.com/codeforests/number-ninja/pull/14 · Updated: 2026-11-15 by verify
Stage done: verify (accepted, code `c9cfb37`)
Next: Ken merges PR #14; then FEAT-17 design — kickoff: "Design FEAT-17 on branch feat/FEAT-17-topic-lock (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- FEAT-17 reads `ChildProfile.schoolYear` via `profileRepositoryProvider` / `childProfileProvider` (FutureProvider, invalidate after a save) and `topicYear(Topic)` in `lib/domain/profile.dart`.
- An updated install may have no profile (PRO-02): FEAT-17 must define the lock with no school year.
- Nit for a later tidy: two misplaced doc comments in `lib/providers.dart` (verify.md, Beyond the tests).

## Left to CI or later
- Release APK build in CI on the PR head. SCR-12 look on the real tablet at M5.

## Pending for Ken
- Merge PR #14.
