# Handoff: FEAT-08 — Badges and badge shelf
Branch: feat/FEAT-08-badges · PR: https://github.com/codeforests/number-ninja/pull/10 (draft) · Updated: 2026-11-15 by build
Stage done: build (T1–T5 of 5)
Next: verify — kickoff: "Verify FEAT-08 on branch feat/FEAT-08-badges. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- Files: `lib/domain/badges.dart`, `lib/data/badge_repository.dart`, `lib/ui/badge_icons.dart`, `lib/features/badges/badge_shelf_screen.dart` (+ `latestBadge`); hooks in `quiz_controller.dart` (`_awardBadges`, try/catch), `result_screen.dart` (`_NewBadges`, `see-badges`), `home_screen.dart` (`_BadgesButton`), `app.dart` (`Routes.badges`, in `counts`), `providers.dart`, `theme.dart` (`AppSizes.badge/badgeSmall`, `AppMotion.badgePop`).
- Tests: `test/domain/badges_test.dart` (AC-1), `test/data/badge_repository_test.dart` (AC-2), `test/features/quiz/badges_result_test.dart` (AC-3), `test/features/badges/badge_shelf_test.dart` (AC-4, AC-5), `test/features/badges/badges_layout_test.dart` (AC-6). Full `scripts/check.sh`: 667 tests pass.
- Deviations (design §9 build row): SCR-06 is a `Wrap` of 220 dp tiles, not a fixed-height GridView (long hints at scale 1.3); count under the title; best-stars map instead of `progressByTopic`; `hide Badge` on Material imports.
- `awardNew` evaluates whatever is in the DB, so calling it after quit rounds alone would award attempt badges; only the quiz controller calls it, after a finished round.
- Pop test: `Transform.scale` matrix, read `entry(0, 0)` (getMaxScaleOnAxis includes z = 1).
- BDG-01..03 Feature cells already say FEAT-08; Verified by is verify's.

## Left to CI or later
- APK build: CI on PR #10. Real tablet check at M3 (`m3` release after merge).

## Pending for Ken
- none
