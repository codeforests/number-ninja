# Handoff: FEAT-07 — PDF progress report
Branch: feat/FEAT-07-pdf-report · PR: https://github.com/codeforests/number-ninja/pull/8 (draft) · Updated: 2026-11-15 by verify
Stage done: verify (rework)
Next: build — kickoff: "Build FEAT-07 (rework from verify.md) on branch feat/FEAT-07-pdf-report. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2 for the two items under 'Rework' in verify.md."

## What the next stage needs
- Everything else passed (AC-1..6, 597 tests, CI green on `42376c0`); only the two items in `verify.md` "Rework".
- Item 1: `_keep` in `lib/features/parent/report_pdf.dart` returns a `pw.Column`, which `MultiPage` splits (Flex is a SpanningWidget). `pw.Inseparable(child: pw.Column(...))` fixed it in a scratch run; a `pw.Container` wrapper did not. Reproduce with `ReportData.build(full(), StatsPeriod.days30, now)` from `report_pdf_test.dart`: heading at the foot of page 1, chart on page 2.
- Test idea: `buildReportPdf(data, compress: false)`, split the text on `/Type /Page` objects or content streams and check the heading and "100 %" fall on the same page; confirm it fails before the fix. Text is drawn as Helvetica strings, so check how `pdf` encodes them in the stream first.
- Item 2: one seeded topic with a non-whole accuracy (2 of 3 → "67 %").
- Then full `scripts/check.sh`, push (CI runs on PR #8), hand off to verify with the standard verify kickoff.

## Left to CI or later
- Real share sheet on the tablet: M3 check after FEAT-08.

## Pending for Ken
- none
