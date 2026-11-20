# Handoff: FEAT-25 — Siblings
Branch: feat/FEAT-25-siblings · PR: none · Updated: 2026-11-20 by design
Stage done: design
Next: build — kickoff: "Build FEAT-25 (from T1) on branch feat/FEAT-25-siblings. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Auto mode (Ken, 2026-11-20): decisions AD-1..13 in design.md are final; record any new one there and as a D-row, don't wait for Ken.
- Requirement rows FAM-01..07, D20, ADR-12 (04-architecture §4) and SCR-17/18 (02-design §6) are already in; T6 fills Feature/Verified cells and 02-design §4.
- Schema v9 = `_from8To9`; the re-keyed tables (`daily_usage`, `badges_earned`, `topic_unlocks`, `sync_fields`) need `TableMigration` rebuilds; keep `_from6To7` ordering gotcha in mind.
- `onCreate` must insert child 1, so tests that build a fresh DB keep working; `QuizHarness`/`ParentHarness` should seed extra children through `ChildRepository`.
- Server already allows several children per owner with cascade delete; only `children.avatar` is new (`1763251206_siblings.js`).
- Sync today uses `children.first` (`SyncService._child`); T5 replaces it with per-child handling (AD-9..11).
- Plan: T1–T3 in the first build thread, then hand off T4–T6. Draft PR at the end of the build (T5 adds no plugin).

## Left to CI or later
- APK build and the server job run in CI only. AC-10 (two tablets) is Ken's optional live check.

## Pending for Ken
- none
