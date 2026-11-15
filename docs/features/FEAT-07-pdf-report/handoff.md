# Handoff: FEAT-07 — PDF progress report
Branch: feat/FEAT-07-pdf-report · PR: https://github.com/codeforests/number-ninja/pull/8 · Updated: 2026-11-15 by verify
Stage done: verify (accepted, after one rework)
Next: PR — Ken reviews and merges PR #8; then FEAT-08 design — kickoff: "Design FEAT-08 on branch feat/FEAT-08-<slug> (create it from main). Read AGENTS.md and docs/STATE.md, then do docs/03-plan.md §2 step 1."

## What the next stage needs
- Verdict and evidence: `verify.md` (re-verify section at the top). PAR-09 Verified by filled.
- PDF layout gotcha: `pdf` MultiPage splits a vertical `pw.Column`; wrap blocks that must stay together in `pw.Inseparable`. Check page breaks by rendering with `pdftoppm`/`pdftotext`, not tests alone.

## Left to CI or later
- APK build and manifest check: CI on PR #8.
- Real share sheet on the tablet: M3 check after FEAT-08 (`m3` release after FEAT-08 merges).

## Pending for Ken
- Merge PR #8.
