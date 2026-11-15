# Handoff: FEAT-03 — Quiz engine
Branch: feat/FEAT-03-quiz-engine · PR: [#4](https://github.com/codeforests/number-ninja/pull/4) (draft) · Updated: 2026-11-15 by build
Stage done: build (T1–T7 of 7)
Next: verify — kickoff: "Verify FEAT-03 on branch feat/FEAT-03-quiz-engine. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- AC → tests: AC-1 `test/domain/round_builder_test.dart` + `test/data/round_repository_test.dart`; AC-2/3/4/8 `test/features/quiz/quiz_screen_test.dart` + `answer_widgets_test.dart`; AC-5/9 `test/features/quiz/result_flow_test.dart` + `test/domain/stars_test.dart`; AC-6/7 `test/features/quiz/layout_test.dart`.
- SCR-05 (`result_screen.dart`): keys `result-score`, `result-time`, `star-0..2`, `play-again`, `home`. `formatMinSec` rounds down to the second.
- AC-6 renders the longest-prompt question of each of the 109 templates alone on SCR-04 (single-question bank via `QuizHarness(bank:)`), answers it wrongly so the feedback panel lays out too, and fails on any overflow/exception. Portrait sample: longest per visual kind and per format without a visual.
- AC-7 uses `MinimumTapTargetGuideline(64 × 64)` (semantics) and checks every `RenderParagraph` ≥ 20 sp outside `QuestionVisual` and `Icon` (visual labels scale with their box; icons are glyphs). Both checks were confirmed to fail when the thresholds are raised.
- Harness change in T7: `QuizHarness.tap` calls `ensureVisible` first. The test font (Ahem) is wider than Roboto, so the longest drag answers (5 time chips) push Check below 800 dp into the right half's scroll view; with Roboto loaded, `p1.time.order.003` fits on one screen, filled or empty (checked by eye).
- T7 also set the keypad backspace icon to `AppText.heading` (it was the button default 18).

## Left to CI or later
- APK build and CI on PR #4. NFR-04 300 ms on the tablet: Ken's M1 check.

## Pending for Ken
- none
