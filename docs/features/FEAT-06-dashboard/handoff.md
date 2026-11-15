# Handoff: FEAT-06 — Parent dashboard
Branch: feat/FEAT-06-dashboard · PR: [#7](https://github.com/codeforests/number-ninja/pull/7) (ready) · Updated: 2026-11-15 by verify
Stage done: verify (accepted)
Next: PR merge by Ken, then FEAT-07 design when Ken says so — kickoff: "Design FEAT-07 on branch feat/FEAT-07-pdf-report (create it from main). Read AGENTS.md and docs/STATE.md, then do docs/03-plan.md §2 step 1."

## What the next stage needs
- FEAT-07 (PAR-09) reuses `lib/domain/stats.dart` and `StatsRepository.recordsIn(period)`; screens read `statsDataProvider` (`lib/features/parent/stats_view.dart`).
- Charts are an own `CustomPainter` (`lib/ui/trend_chart.dart`); the PDF draws its charts with the `pdf` package (design §1).
- Verify notes 1–2 in verify.md (SCR-10 trend values, mix-in level) are not blocking.

## Left to CI or later
- M3 tablet check and `m3` release after FEAT-08 merges.

## Pending for Ken
- Merge PR #7.
