# Handoff: FEAT-03 — Quiz engine
Branch: feat/FEAT-03-quiz-engine · PR: none · Updated: 2026-11-15 by build
Stage done: build (T1–T6 of 7)
Next: build — kickoff: "Build FEAT-03 (from T7) on branch feat/FEAT-03-quiz-engine. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- T7 only: finish `lib/features/quiz/result_screen.dart` (now a stub: score + Home). Add `m:ss` time, 0–3 stars, Play again (`context.go(Routes.quiz(summary.topicId))`). It gets a `RoundSummary` (topicId, score, total, durationMs, stars) as route `extra`; `/result` without one redirects home.
- The round is saved before the last feedback shows: `check()` awaits `saveAttempt` and, on the last question, `finishRound`. `next()` is sync, no I/O (AC-8 test in `quiz_screen_test.dart`). "See results" calls `next()` then goes to `/result`.
- Test harness: `test/features/quiz/quiz_harness.dart` (`QuizHarness`: fake bank with one format per topic `p2.fractions` mcq / `p2.money` number / `p2.place` drag, in-memory DB, fake clock `h.now`/`h.tick`, `Random(42)`, `CountingRepository` with a `gate` Completer, `answer(tester, right:)`, `next`, `round`, `current`). Pass `bank:` for AC-6 with the real bank (`QuestionBank.fromJson` of `assets/questions/bank_v1.json` via `File`).
- Keys: `quit`, `progress-dots`, `prompt`, `option-i`, `key-0..9|dot|back`, `check`, `chip-i`, `slot-i`, `feedback-title|answer|explanation`, `next`, `track-school|olympiad`, `topic-<id>`, `back`, `result-score`, `home`.
- Routes: `Routes.play(track)` → `TopicListScreen`, `Routes.quiz(id)` → `QuizScreen`, `Routes.result`. Home track cards are tappable.
- Visuals: `VisualFrame` scales each visual to its box (up to 1.6×). Painter labels (clock, ruler numbers) use the default font, so they show as Ahem boxes in test screenshots; real device is fine. Checked by eye at 1280 × 800 with Roboto loaded: all nine kinds look right.
- Drift stores `DateTime` to the second; `time_ms` keeps milliseconds.
- AC-7 note: visual texts are 20 sp before FittedBox scaling; the size test should check `Text` widgets outside `QuestionVisual` or accept that.

## Left to CI or later
- APK build (no Android SDK in cloud). NFR-04 300 ms on the tablet: Ken's M1 check.

## Pending for Ken
- none
