# Handoff: FEAT-11 — Revision module
Branch: feat/FEAT-11-revision · PR: none · Updated: 2026-11-16 by design
Stage done: design
Next: build — kickoff: "Build FEAT-11 (from T1) on branch feat/FEAT-11-revision. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- 6 tasks, so design handed off instead of carrying on. Rules and constants are in design.md "Design decisions"; they are defaults, not asked of Ken.
- Question type = question id minus `.nnn` (bank validator enforces the shape); ~12 questions per type in bank_v1 (min 10).
- `finishedRounds()` becomes normal-only: that single filter keeps levels, best stars and the FEAT-17 lock unaffected (answers FEAT-17's open question: a revision round is never a pass). Badges read `db.rounds` directly, so `BadgeRound.kind` is needed there.
- Mixed rounds store `topic_id = 'mixed'`; anything that looks up `topicsById[round.topicId]` must tolerate a miss (quiz header, result screen, badges).
- Routes `/revise/<scope>` (SCR-14) and `/revise/<scope>/quiz`; add `/revise/` to `Routes.counts`.
- Invalidate `revisionHistoryProvider` wherever `topicProgressProvider` is invalidated.

## Left to CI or later
- APK build in CI on the draft PR (T6). Look of SCR-14 and the home card on the real tablet at the M5 check.

## Pending for Ken
- none
