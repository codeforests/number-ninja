# Handoff: FEAT-06 — Parent dashboard
Branch: feat/FEAT-06-dashboard · PR: none · Updated: 2026-11-15 by design
Stage done: design
Next: build — kickoff: "Build FEAT-06 (from T1) on branch feat/FEAT-06-dashboard. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- design.md here: decisions, design, AC-1..8, T1–T7. No schema change, no new package.
- Charts: own `CustomPainter` (`lib/ui/trend_chart.dart`), not fl_chart (not in pubspec; may not build with the `material_ui` split). T7 updates design §1's stack row.
- Stats join attempts to the bank by `question_id` (topic of the question, not of the round); read `QuestionBank.byTopic` / ids, don't change the bank.
- Mix-in: `buildRound` gets `mixIn:`; `QuizController.start` (lib/features/quiz/quiz_controller.dart ~L80) picks the topic from 30-day needs practice, School track only, never the round's own topic. Existing quiz tests seed no attempts, so they see no mix-in.
- Reset reuses `PinRepository.verify` (PAR-03 lockout) and `lib/ui/pin_pad.dart`; keep `app_settings`, `pin_lockout`, `daily_usage`.
- New routes under `/parent` (`/parent/dashboard`, `/parent/topic/:topicId`, `/parent/reset`) so the PIN redirect and screen-time gating already cover them; `Routes.counts` must stay false for them.
- Seven tasks: hand off to a fresh build thread after T6 if the session is long.

## Left to CI or later
- APK build (CI only). M3 tablet check after FEAT-08.

## Pending for Ken
- none
