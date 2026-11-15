# Handoff: FEAT-04 — Home, topic map and difficulty steps
Branch: feat/FEAT-04-topic-map · PR: none · Updated: 2026-11-15 by design
Stage done: design
Next: build — kickoff: "Build FEAT-04 (from T1) on branch feat/FEAT-04-topic-map. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- Ken's M1 feedback is recorded as D9, NFR-09 (here), PRC-11 and NFR-10 (FEAT-09). T5–T6 are the NFR-09 small-screen fix; Ken was asked whether it stays in FEAT-04 (recommended) or moves to FEAT-09. If STATE.md says it moved, skip T5 and the AC-6 SCR-04 part, and record the move in design §9.
- Overlap cause on SCR-04 (`quiz_screen.dart` `_Body`): stacked layout puts an unflexed `right` scroll view under `Expanded(left)` in a Column, and the left half's prompt + `Expanded` visual can't scroll, so on short screens the answer area covers the prompt (and release builds don't clip overflow).
- Schema v2 is the first migration: write the v1 `CREATE TABLE` SQL by hand in the migration test (copy from `database.g.dart` column definitions via `grep`, don't read it whole).
- `topics.dart` rename `p2.regroup` display name only; ids are permanent.
- FEAT-03 open notes still stand: `QuizController.check` has no save-error handling; recent-correct preference is per level bucket.
- Widget-test harness: `test/features/quiz/quiz_harness.dart` (`pumpApp(tester, location:, size:)`).

## Left to CI or later
- APK build and Ken's M2 tablet check (with FEAT-05).

## Pending for Ken
- Decision: NFR-09 fix in FEAT-04 or FEAT-09 (asked 2026-11-15 in the FEAT-04 design thread).
