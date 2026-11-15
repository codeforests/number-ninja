# FEAT-07: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `42376c0` · Verdict: **rework** (one layout defect, small fix)

## Checks re-run from a clean checkout

Fresh clone of `feat/FEAT-07-pdf-report`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (no schema change, as designed) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 597 tests |
| CI run [43696012542](https://github.com/codeforests/number-ninja/actions/runs/43696012542) (`42376c0`) | success (incl. APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `report_test.dart` "content": track and topic rows compared to `byTrack` / `byTopic`; 23 topics in design §2 order, "-" where empty; needs practice and `flagged` equal `needsPractice`; 8 weeks with nulls, trends over all records; period lines for 7 / 30 days / all time; `isEmpty`; `allText` ASCII for every period. Report literals in `report_pdf.dart` are ASCII too (grep). | pass |
| AC-2 | `report_pdf_test.dart`: `%PDF-` for full and empty; full ≥ 2 pages, empty 1; all topics at 0 in period; Olympiad missing from trends; single answer. | pass |
| AC-3 | `report_test.dart` "file name": `-30d`, `-7d`, `-all` from the injected clock. | pass |
| AC-4 | `report_export_test.dart`: SCR-11 → `export-report` → 7 days → `export-share` shares once, PDF bytes, `-7d` name, sheet closes; a throwing sharer shows "Couldn't create the report". | pass |
| AC-5 | `report_export_test.dart`: SCR-09, All time, `export-pdf` shares `-all`. | pass |
| AC-6 | `parent_layout_test.dart` "SCR-11 export sheet" at the six sizes and scale 1.3. Earlier tests pass unchanged. | pass |

## Beyond the tests

- **Rendered PDF** (30 days, all 23 topics, `pdftoppm`): **defect.** The heading "Accuracy, last 8 weeks" sits alone at the foot of page 1 and its chart starts page 2. The build row in design §9 says "each chart stays on one page with its heading", but `_keep` in `report_pdf.dart` wraps them in a `pw.Column`, and `Flex` is a `SpanningWidget` (`canSpan` true when vertical), so `MultiPage` splits it. Tried in scratch: wrapping the Column in `pw.Inseparable(child: ...)` moves heading and chart to page 2 together; a plain `pw.Container` did not. No test catches it.
- **Mutation checks** (scratch clone, reverted): 9 of 10 caught: trends over the period only; topics ignoring the period; 0-decimal seconds; "–" for no data; `30days` suffix; empty report drawing tables; sheet ignoring the chosen period; no SnackBar on failure; SCR-09 export ignoring the shown period. **Survived:** accuracy `floor` instead of `round` (every seeded accuracy is a whole percent).
- **Rules.** `lib/domain/report.dart` imports only `stats.dart` and `topics.dart`; only `report_pdf.dart` / `report_export.dart` import `pdf` / `printing`; no colour literals or literal font sizes in the report files; clock from `statsDataProvider` (NFR-08).

## Test diff review

Four test files touched against `main`: three new, `parent_layout_test.dart` gained one case and a reworded doc comment. Nothing removed, no `skip:`, no assertion loosened.

## Rework (for the build thread)

1. Make `_keep` non-spanning (`pw.Inseparable`) and add a test that fails today: e.g. in an uncompressed save, the page holding "Accuracy, last 8 weeks" also holds the chart's "100 %" axis label.
2. Add a non-whole accuracy to `report_test.dart` (e.g. 2 of 3 = "67 %") so rounding is pinned.
