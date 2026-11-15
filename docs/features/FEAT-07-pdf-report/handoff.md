# Handoff: FEAT-07 — PDF progress report
Branch: feat/FEAT-07-pdf-report · PR: none · Updated: 2026-11-15 by design
Stage done: design
Next: build — kickoff: "Build FEAT-07 (from T1) on branch feat/FEAT-07-pdf-report. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- Read design.md whole (under 80 lines). Reuses FEAT-06: `lib/domain/stats.dart` (byTrack, byTopic, overall, needsPractice, weeklyTrend), `statsDataProvider` and `PeriodPicker` in `lib/features/parent/stats_view.dart`, SCR-11 tiles in `parent_screen.dart`.
- Versions resolved at design time: `pdf` 3.13.1, `printing` 5.15.1 (`flutter pub add pdf printing`). pdf + printing analyze and run in `flutter test` on 3.50; the Android APK build with `printing` is not yet proven, hence T1 pushes early for CI.
- Helvetica has no Unicode: a "–" logs "Unable to find a font" and draws nothing. Keep report text ASCII (AC-1 tests it). FEAT-06 `pct`/`secs` use "–", so don't reuse them for the PDF.
- `pdf` writes text as hex strings, so tests can't grep the bytes for words: test content on `ReportData` (AC-1) and only structure on the PDF (AC-2).
- Flutter in cloud: `git clone --depth 1 -b 3.50.0 https://github.com/flutter/flutter.git /root/sdk/flutter`, PATH, safe.directory.

## Left to CI or later
- APK build with `printing` (CI, T1). Real share sheet on the tablet: M3 check after FEAT-08.

## Pending for Ken
- none
