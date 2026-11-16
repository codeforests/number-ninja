# Handoff: FEAT-17 — School topic lock
Branch: feat/FEAT-17-topic-lock · PR: https://github.com/codeforests/number-ninja/pull/15 · Updated: 2026-11-16 by verify
Stage done: verify (accepted; code under test 07cf47e)
Next: design FEAT-11 after Ken merges PR #15 — kickoff: "Design FEAT-11 on branch feat/FEAT-11-revision (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- Verdict and evidence in `verify.md`. One test added in verify (lock re-derives on return to SCR-03).
- FEAT-11 must decide whether a revision round counts as a pass: `topicLocks` counts every finished round of a topic (design.md, Scope).
- Nit for a later tidy: `topicLocksProvider` doc comment says SCR-10, means SCR-15.

## Left to CI or later
- Release APK build runs in CI on the PR head. Padlock look on the real tablet at M5.

## Pending for Ken
- Merge PR #15.
