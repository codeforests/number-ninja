# Handoff: FEAT-07 — PDF progress report
Branch: feat/FEAT-07-pdf-report · PR: https://github.com/codeforests/number-ninja/pull/8 (draft) · Updated: 2026-11-15 by build (rework)
Stage done: build (rework items 1–2 from verify.md)
Next: verify — kickoff: "Verify FEAT-07 on branch feat/FEAT-07-pdf-report. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- Item 1: `_keep` in `lib/features/parent/report_pdf.dart` now wraps its Column in `pw.Inseparable`. New test "a chart heading stays on the page of its chart" in `report_pdf_test.dart` (30-day full report) failed before the fix (heading at the foot of page 1, "100 %" on page 2) and passes after. Helper `pageTexts` joins the per-word `[(word)]TJ` strings of each uncompressed content stream.
- Rendered with `pdftoppm` (30 days, 3 pages): page 2 opens with "Accuracy, last 8 weeks" and its chart, then the speed chart.
- Item 2: `report_test.dart` "non-whole accuracy rounds to the nearest whole %" (2 of 3 → "67 %", 1 of 3 → "33 %", topic and track rows).
- `scripts/check.sh`: all 3 PASS, 599 tests.

## Left to CI or later
- APK build and manifest check: CI on PR #8.
- Real share sheet on the tablet: M3 check after FEAT-08.

## Pending for Ken
- none
