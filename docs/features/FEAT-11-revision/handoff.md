# Handoff: FEAT-11 — Revision module
Branch: feat/FEAT-11-revision · PR: draft (see STATE) · Updated: 2026-11-16 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-11 on branch feat/FEAT-11-revision. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Deviations from design.md: `BadgeRound` gained `bool revision` (not a `kind` string), so `lib/domain` stays free of the data-layer constants `roundKindNormal`/`roundKindRevision` (in `round_repository.dart`).
- `RevisionHistory.levels` comes from `progress()` only; an unplayed topic is level 1 to the planner (the profile start level isn't applied there). The round row's level for topic scope does use `levelFor(start: profile)`.
- SCR-10 changed from a lazy `ListView` to `SingleChildScrollView` + `Column`, so the new weak-types card doesn't push `most-missed` out of the built range (existing tests unchanged).
- The quiz header had no topic name before; revision mode adds a line above the top bar, key `quiz-revision` ("Revision" / "Revision: <topic>").
- `revisionOffersProvider(scopeId)` drives both entries; `revisionPreviewProvider(scopeId)` drives SCR-14 ("nothing" when not offered or the plan is empty). The quiz controller invalidates `revisionHistoryProvider` after each finished round (no code invalidated `topicProgressProvider`; it's autoDispose).
- Tests: `test/domain/revision_test.dart`, `test/data/revision_repository_test.dart`, `test/features/revision/` (round, entries, layout), `test/features/parent/weak_types_test.dart`; additions in round_repository, badges, migration (v5→v6) and parent_layout tests. Migration tests' expected `user_version` moved 5 → 6.

## Left to CI or later
- APK build in CI on the draft PR. Look of SCR-14 and the home card on the real tablet at the M5 check.

## Pending for Ken
- none
