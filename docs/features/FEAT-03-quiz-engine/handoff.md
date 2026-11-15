# Handoff: FEAT-03 — Quiz engine
Branch: feat/FEAT-03-quiz-engine · PR: [#4](https://github.com/codeforests/number-ninja/pull/4) (ready) · Updated: 2026-11-15 by verify
Stage done: verify (accepted)
Next: Ken reviews and merges PR #4 and does the M1 check on the tablet. Then, when Ken says so — kickoff: "Design FEAT-04 on branch feat/FEAT-04-<slug> (create it from main). Read AGENTS.md and docs/STATE.md, then do docs/03-plan.md §2 step 1."

## What the next stage needs
- FEAT-04 replaces the placeholder topic list (`lib/features/quiz/topic_list_screen.dart`, route `/play/:track`) and the fixed `playLevel = 1` in `quiz_controller.dart` (PRC-09).
- `buildRound` applies the recent-correct preference per level (verify.md note 2); revisit if FEAT-04's level rules need it across levels.
- `QuizController.check` has no error handling on a failed save (verify.md note 1).
- The widget-test harness is `test/features/quiz/quiz_harness.dart` (`QuizHarness(bank:)`, `tap` scrolls into view first).

## Left to CI or later
- APK build: CI only (run 43664365573 green). NFR-04 300 ms: Ken's M1 check on the tablet.

## Pending for Ken
- Merge PR #4; M1 check on the tablet (play a round in each format, feel of Next).
