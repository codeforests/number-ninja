# Handoff: FEAT-08 — Badges and badge shelf
Branch: feat/FEAT-08-badges · PR: none · Updated: 2026-11-15 by design
Stage done: design
Next: build — kickoff: "Build FEAT-08 (from T1) on branch feat/FEAT-08-badges. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- Read design.md whole (it is short); the badge table there is the source of ids, names, rules and hints.
- No schema change: `BadgesEarned` (badge_id PK, earned_at) is in `lib/data/database.dart`; `StatsRepository.resetProgress` already deletes it.
- Facts come from `rounds` with `finished_at` (need `score`, `duration_ms`, `stars`, `finished_at`; `RoundRepository.finishedRounds` doesn't expose them, so query in `BadgeRepository`) and `StatsRepository.records()` for attempts.
- Hook point: `QuizController.check`, right after `repo.finishRound(...)` when `answered.isLast`; wrap in try/catch so a badge error never blocks SCR-05.
- `Routes.counts` in `lib/app.dart` must include `/badges` (TIM-01); add `Routes.badges`.
- Open the draft PR at T2 so CI runs (CI only triggers on pull_request).
- Widget tests: Ahem font is wide, `QuizHarness.tap` uses ensureVisible; the SCR-05 pop animation needs `pumpAndSettle` or a pump of `AppMotion.badgePop`.

## Left to CI or later
- APK build: CI on the draft PR. Real tablet check at M3 (`m3` release after FEAT-08 merges).

## Pending for Ken
- none (the "latest 30" reading of §7's 90 %+ rule is recorded in design §9; Ken can change it at the M3 check).
