# Handoff: FEAT-07 — PDF progress report
Branch: feat/FEAT-07-pdf-report · PR: https://github.com/codeforests/number-ninja/pull/8 (draft) · Updated: 2026-11-15 by build
Stage done: build (T1–T5 of 5)
Next: verify — kickoff: "Verify FEAT-07 on branch feat/FEAT-07-pdf-report. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- Files: `lib/domain/report.dart` (ReportData.build, reportFileName, ASCII formatters), `lib/features/parent/report_pdf.dart` (buildReportPdf, pdfColor, `_chart` painter), `lib/features/parent/report_export.dart` (reportSharerProvider, exportReport, ExportSheet, showExportSheet); tile in `parent_screen.dart`, AppBar action + `_export` in `dashboard_screen.dart`; `AppPdf` in `lib/ui/theme.dart`.
- Tests: AC-1/AC-3 `test/domain/report_test.dart`; AC-2 `test/features/parent/report_pdf_test.dart`; AC-4/AC-5 `test/features/parent/report_export_test.dart`; AC-6 new case "SCR-11 export sheet" in `test/features/parent/parent_layout_test.dart`. No existing test changed apart from that added case.
- Deviations (design §9 build row): pdfColor in report_pdf.dart, trends stored as per-week values, legend states the full needs-practice rule (FEAT-06's `needsPractice` also flags topics slower than average), heading+chart kept on one page, sheet closes after sharing.
- `buildReportPdf(data, compress: false)` exists only so tests can count `/Type /Page` objects.
- Widget tests: PDF building is real async work, so taps run inside `tester.runAsync` with a poll loop that also calls `tester.pump()` (without the pump the continuation never runs). The sharer is overridden through a mutable closure because the harness can't override a provider twice.
- To eyeball the PDF: write `buildReportPdf` bytes to a file from a throwaway test and run `pdftoppm -png` (installed). Checked 3 pages at 30 days with all 23 topics: layout, charts with gaps and legend fine.
- "Helvetica has no Unicode support" is printed once per document by `pdf` itself; it is not the "Unable to find a font" warning.

## Left to CI or later
- Release APK with `printing` is green in CI (run 43695199537 on T1). Real share sheet on the tablet: M3 check after FEAT-08.

## Pending for Ken
- none
