# Handoff: FEAT-04 — Home, topic map and difficulty steps
Branch: feat/FEAT-04-topic-map · PR: https://github.com/codeforests/number-ninja/pull/5 (draft) · Updated: 2026-11-15 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-04 on branch feat/FEAT-04-topic-map. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- Tests per AC: AC-1 `test/domain/progress_test.dart`; AC-2 `test/data/round_repository_test.dart` (group "progress") and `test/data/migration_test.dart` (v1 SQL dumped from the FEAT-03 schema); AC-3 `result_flow_test.dart` group "AC-3"; AC-4/5 `test/features/topics/topic_map_test.dart`; AC-6 `test/features/quiz/responsive_test.dart` (SCR-04, per format longest prompt and longest with a visual) and `test/features/child_screens_layout_test.dart` (SCR-02/03/05 + NFR-03); AC-7 `test/features/quiz/no_scroll_test.dart`.
- Helper `test/ui/layout_checks.dart`: sizes, `expectNoOverlap`, `expectChildSizes` (a copy of FEAT-03's NFR-03 check, so `layout_test.dart` stays unchanged).
- AC-7 loads Roboto + MaterialIcons from `$FLUTTER_ROOT/bin/cache/artifacts/material_fonts` and skips with a reason if missing; it ran (110 templates, none skipped) locally.
- Changes outside the design's file list, all for NFR-09 under Ahem/text scale 1.3: feedback title row → `Wrap`; picture-graph "Each ★ stands for N" → one `Text.rich`; SCR-05 stars in `FittedBox(scaleDown)`; SCR-04 right half has no side padding (keypad 264 dp fits a 640 dp half).
- `TrackSlug` (school/olympiad → tracks) lives in `topic_map_screen.dart`; home uses it for star totals.
- Home uses scroll + `IntrinsicHeight` so cards fill the screen but scroll on 640 × 360.
- `RoundState.level` carries the played level into `RoundSummary`; `levelFor` isn't counted by `CountingRepository` (AC-8 of FEAT-03 unaffected).

## Left to CI or later
- APK build (CI on PR #5); Ken's M2 tablet check with FEAT-05.

## Pending for Ken
- none
