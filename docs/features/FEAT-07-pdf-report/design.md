# FEAT-07: PDF progress report

> Implements: PAR-09 · Screens: SCR-11 (export tile and sheet), SCR-09 (export action)
> Status: built (T1–T5) · Branch: `feat/FEAT-07-pdf-report` · 2026-11-15

## Scope

Behind the PIN, the parent exports a PDF progress report for a chosen period (7 days, 30 days, all time) and shares or saves it through Android's share sheet (PAR-09). The report holds the period, a per-track summary, the needs-practice list, weekly trend charts (accuracy and speed per track) and the per-topic table. Every number comes from FEAT-06's `lib/domain/stats.dart` over the same records the dashboard shows, so the report and SCR-09 always agree. No schema change, nothing is stored: the file is built in memory and handed to the share sheet.

Not in scope: printing (the share sheet's "Save to Files/Drive" covers saving), most-missed / slowest questions per topic (not in PAR-09), badges (FEAT-08), screen-time history, a child's name (the app stores none, D7).

## Design decisions (this feature)

- **Packages:** `pdf` (^3.13.1, pure Dart) builds the file; `printing` (^5.15.1) shares it with `Printing.sharePdf(bytes:, filename:)`, which opens the Android share sheet. No `share_plus`. Both resolve and compile with Flutter 3.50 (checked at design time); the Android build is checked by CI on the first push (T1).
- **Where:** two entry points, one exporter. SCR-11 gets an "Export PDF report" tile (below "Progress") that opens a bottom sheet with the FEAT-06 `PeriodPicker` (default 30 days) and a "Create and share" button. SCR-09's AppBar gets a share action that exports the period currently shown. Both are under `/parent`, so the PIN and "doesn't count as screen time" already apply.
- **Same numbers as SCR-09:** the report takes a `StatsData` (`statsDataProvider`) and a period; the period, tallies, needs practice (`minAttempts` 10, below 70 %) and the 8-week trends are exactly FEAT-06's rules (FEAT-06 design, "Design decisions"). Trends always show the last 8 weeks, as on SCR-09, and say so.
- **Fonts:** the built-in Helvetica only, so no font asset ships. It has no Unicode support, so every string the report draws is ASCII: "-" for no data (not the dashboard's "–"), "%" and "s" as on SCR-09, dates `d MMM yyyy`. A test checks that all report text is ASCII.
- **Layout:** A4 portrait, 2 cm margins, `pw.MultiPage` so the topic table flows onto a second page; footer "Number Ninja - page X of Y". Order: title "Number Ninja progress report", period line ("Last 30 days: 16 Oct 2026 - 15 Nov 2026", or "All time: up to 15 Nov 2026"), "Created 15 Nov 2026 14:05"; track summary table (Track, Accuracy, Avg time, Answers); "Needs practice" (topic, track, accuracy, avg time; "Nothing yet. Needs 10+ answers in a topic." when empty); two trend charts "Accuracy, last 8 weeks" (0–100 %) and "Seconds per question, last 8 weeks" (0–max) with one line per track, gaps for empty weeks, a legend and week labels `d MMM`; topic table grouped by track with all 23 topics (Topic, Accuracy, Avg time, Answers, "!" when needs practice) and a legend line for "!". With no attempts in the period, the report is one page: header, then "No answers in this period."
- **Charts:** drawn with `pw.CustomPaint` (a small painter like `lib/ui/trend_chart.dart`), not `pw.Chart`, because `pw.LineDataSet` can't leave gaps. Colours from `theme.dart` (`AppColors.trackP1/trackP2/trackOly/chartGrid/ink/muted`), converted with `PdfColor.fromInt(c.toARGB32())` in one helper; no colour literals in the report code.
- **File name:** `number-ninja-report-<yyyy-MM-dd>-<7d|30d|all>.pdf`, date from the injected clock (NFR-08).
- **Testability:** report building is split from sharing. A provider `reportSharerProvider` holds `Future<void> Function(Uint8List bytes, String filename)`, default `Printing.sharePdf`; widget tests override it to capture the bytes and name, so no platform channel runs in tests. Building takes a few hundred ms at most for 23 topics, so it runs on the UI isolate with a progress indicator on the button; a failure shows a SnackBar "Couldn't create the report" and nothing is shared.

## Design

- **Report model** (`lib/domain/report.dart`, pure Dart, no `pdf` import): `ReportData {period, now, from (null for all), tracks: List<ReportRow>, topics: List<ReportTopicRow> (23, design §2 order), needsPractice: List<ReportTopicRow>, accuracyTrend/speedTrend: Map<Track, List<WeekPoint>>, isEmpty}`. `ReportRow {label, accuracy, avgTime, answers}` as display strings (ASCII); `ReportTopicRow` adds `topicId`, `track`, `flagged`. `ReportData build(List<AttemptRecord> all, StatsPeriod period, DateTime now)` uses `byTrack`, `byTopic`, `overall`, `needsPractice`, `weeklyTrend`. `String reportFileName(StatsPeriod, DateTime now)`.
- **PDF** (`lib/features/parent/report_pdf.dart`): `Future<Uint8List> buildReportPdf(ReportData data)` with the layout above; colours via `pdfColor(Color)` from the theme. Only this file and `report_export.dart` import `pdf` / `printing`.
- **Export** (`lib/features/parent/report_export.dart`): `reportSharerProvider`; `Future<bool> exportReport(WidgetRef ref, StatsPeriod period)` reads `statsDataProvider`, builds `ReportData` and bytes, calls the sharer with `reportFileName`; returns false on error. `ExportSheet` widget (key `export-sheet`): `PeriodPicker`, button key `export-share` (disabled with a progress indicator while building).
- **SCR-11:** tile key `export-report` ("Export PDF report", subtitle "Share or save a summary") under `open-dashboard`; opens `ExportSheet` with `showModalBottomSheet`.
- **SCR-09:** AppBar `IconButton` key `export-pdf` (icon share, tooltip "Export PDF") calls `exportReport` with the shown period.
- **Theme:** reuse FEAT-06 colours; PDF sizes (title 20, heading 13, body 10, chart height 140 pt) go in a new `AppPdf` class in `theme.dart`, so the report hard-codes no sizes either.

## Acceptance criteria

- **AC-1** (PAR-09 content): `report.dart` unit tests with seeded records and an injected clock: track rows and topic rows match `byTrack` / `byTopic` (accuracy %, avg s with one decimal, answers); all 23 topics in design §2 order with "-" where there are no answers; needs-practice rows and `flagged` match `needsPractice`; trends have 8 points with nulls for empty weeks; the period line and dates for 7 / 30 days and all time; `isEmpty` with no records in the period; every string ASCII.
- **AC-2** (PAR-09 file): `buildReportPdf` for a full data set and for an empty one returns bytes starting with `%PDF-`; the full one has 2 or more pages, the empty one 1 (count `/Type /Page` objects in an uncompressed save, or the page list); no exception with all 23 topics at 0 answers or with one track missing from the trends.
- **AC-3** (file name, NFR-08): `reportFileName` gives `number-ninja-report-2026-11-15-30d.pdf` (and `-7d`, `-all`) from the injected clock.
- **AC-4** (PAR-09 share, SCR-11): widget test: SCR-11 → `export-report` → sheet → choose 7 days → `export-share` calls the overridden sharer once with PDF bytes and the `-7d` file name; a sharer that throws shows "Couldn't create the report".
- **AC-5** (PAR-09, SCR-09): widget test: on SCR-09 with "All time" chosen, `export-pdf` calls the sharer with the `-all` file name.
- **AC-6** (NFR-09): the export sheet at the six FEAT-04 sizes and text scale 1.3: no exception or overflow (`test/ui/layout_checks.dart`; parent screen, so the 64 dp / 20 sp checks don't apply). Existing tests pass unchanged.

## Tasks

- [x] T1 — Add `pdf` and `printing` to `pubspec.yaml`; `AppPdf` sizes and `pdfColor` helper in `theme.dart`; push early so CI checks the release APK build with `printing`.
      Done when: `flutter pub get` and `flutter analyze` pass, and CI's APK job is green on the pushed commit (if it fails on Gradle or minSdk, stop and record it in the handoff for design).
- [x] T2 — `lib/domain/report.dart` (`ReportData.build`, `reportFileName`).
      Done when: AC-1 and AC-3 tests pass: `scripts/check.sh 'flutter test test/domain/report_test.dart'`.
- [x] T3 — `lib/features/parent/report_pdf.dart` (layout, tables, `pw.CustomPaint` trend charts with gaps).
      Done when: AC-2 tests pass.
- [x] T4 — `report_export.dart` (sharer provider, `exportReport`, `ExportSheet`), SCR-11 tile, SCR-09 action.
      Done when: AC-4 and AC-5 widget tests pass with `flutter test test/features/parent`.
- [x] T5 — AC-6 layout checks; design §9 build row if anything deviated; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
