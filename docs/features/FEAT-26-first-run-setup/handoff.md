# Handoff: FEAT-26 — Parent first-run setup
Branch: feat/FEAT-26-first-run-setup · PR: none · Updated: 2026-11-20 by design
Stage done: design
Next: build — kickoff: "Build FEAT-26 (from T1) on branch feat/FEAT-26-first-run-setup. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Decisions AD-1..13 in design.md (auto mode). Requirements SET-01..07 and D21 added; SCR-19 row in 02-design §6.
- Schema v10 adds only `app_settings.setup_step`; add it before `_from6To7` in `onUpgrade` (code-map gotcha). Fresh DB = `welcome`.
- `AppSession` drops `hasPin`/`profilePending` for the setup step; grep tests for `hasPin:`/`profilePending:` (QuizHarness, ParentHarness) and update their setup only.
- `SyncController` has `requestSync()` and `idle`; T4 adds `syncOnce()` on top, no change to the loop.
- Extractions (`AccountForms`, `ChildForm`) must keep every existing key so SCR-12/SCR-13 tests pass unchanged.
- 6 tasks: hand off after ~T4 if the session is long.

## Left to CI or later
- APK build in CI only (no Android SDK here). AC-7 is Ken's optional tablet check.

## Pending for Ken
- none
