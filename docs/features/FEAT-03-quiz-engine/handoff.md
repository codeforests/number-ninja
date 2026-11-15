# Handoff: FEAT-03 — Quiz engine
Branch: feat/FEAT-03-quiz-engine · PR: none · Updated: 2026-11-15 by design
Stage done: design
Next: build — kickoff: "Build FEAT-03 (from T1) on branch feat/FEAT-03-quiz-engine. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- Read `design.md` (all of it is short) and `tool/bank/README.md` § "Visuals FEAT-03 draws" for visual fields.
- No schema change: `rounds`, `attempts`, `play_sessions` exist (`lib/data/database.dart`).
- `isCorrect(q, given)` exists in `lib/domain/answers.dart`: given is a String (mcq, number) or List<String> (drag). Drag `slots` is an int.
- Bank facts: 50 number answers contain `.` (money), none negative, max 4 chars; drag ≤ 6 items, ≤ 5 slots, ≤ 12 chars; longest prompt 157 chars; every topic has ≥ 18 questions per level. 1,009 questions have no visual.
- Kinds in the bank: pictureGraph 108, shapes 93, barModel 60, coins 30, groups 27, clock 27, fraction 20, ruler 15, figure 5.
- Widget tests use a 2560 × 1600 px view at DPR 2 (1280 × 800 dp), an in-memory DB and a fake clock (see `test/features/pin_flow_test.dart`).
- Material comes from `package:material_ui/material_ui.dart`. Locally `origin/main` may be stale: `git fetch origin main` first.
- Design §9 records the deferrals (needs-practice mix-in → FEAT-06; level 1 + placeholder topic list until FEAT-04).
- T1–T6 fit one build thread; T7 (results, full-round/layout/size tests, draft PR) may go to a second.

## Left to CI or later
- APK build (no Android SDK in cloud). NFR-04 300 ms on the tablet: Ken's M1 check.

## Pending for Ken
- none (M1 tablet sign-off after FEAT-03 merges)
