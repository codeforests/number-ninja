# Build state

> The first file a build or verify thread reads. Keep it under 40 lines.

- **Phase:** construction. Requirements, design and plan signed off by Ken 2026-11-14 (PR #1).
- **In progress:** FEAT-07 PDF report (M3) on `feat/FEAT-07-pdf-report`: designed and built 2026-11-15 (T1–T5, 597 tests), draft PR #8; verify 2026-11-15: rework (chart heading split from its chart, rounding test); rework built 2026-11-15 (599 tests); re-verify 2026-11-15: **accepted**, PR #8 ready for Ken to merge. FEAT-08 next. Ken's M1 feedback still open: PRC-11 and NFR-10 (FEAT-09).
- **Remaining order:** 07 → 08 (M3; `m3` release after 08 merges) → 09 (M4).
- **Merged:** FEAT-06 parent dashboard (PR #7, 2026-11-15, accepted). FEAT-05 screen-time lock (PR #6, 2026-11-15, accepted); M2 done, release `m2` published. FEAT-04 home, topic map and difficulty steps (PR #5, 2026-11-15, accepted). FEAT-03 quiz engine (PR #4, 2026-11-15, accepted); M1 signed off by Ken, release `m1` published. FEAT-01 walking skeleton (PR #2, 2026-11-14, accepted). FEAT-02 question bank (PR #3, 2026-11-15, accepted; format mix 29/62/9, not rebalanced).
- **Environment:** cloud sessions have no Flutter SDK: install the stable tarball listed in `releases_linux.json` (3.50.0) into `~/sdk/flutter`, add `~/sdk/flutter/bin` to PATH, and run `git config --global --add safe.directory ~/sdk/flutter`. There's no Android SDK either, so APK builds and the manifest check run only in GitHub CI (runs on every push to a PR). Material widgets come from `package:material_ui/material_ui.dart`.
- **Last CI run:** [43697516776](https://github.com/codeforests/number-ninja/actions/runs/43697516776) on `f16b182` (FEAT-07 rework, PR #8), success.

## Kickoff prompts (the handoff names the exact one)

AGENTS.md is already loaded in every thread; kickoffs don't ask to read it again. Stage details: AGENTS.md, "Stages".

```
Design FEAT-NN on branch feat/FEAT-NN-<slug> (create it from main).
Read docs/STATE.md, then do the Design stage in AGENTS.md.
```
```
Build FEAT-NN (from T<n>) on branch feat/FEAT-NN-<slug>.
Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md.
```
```
Verify FEAT-NN on branch feat/FEAT-NN-<slug>.
Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md.
```
```
Fix FEAT-NN rework on branch feat/FEAT-NN-<slug>.
Read docs/STATE.md, the handoff.md and the "Rework" section of verify.md, then do the Rework fix stage in AGENTS.md.
```
```
Re-verify FEAT-NN on branch feat/FEAT-NN-<slug> since <verified sha>.
Read docs/STATE.md and the handoff.md, then do the Re-verify stage in AGENTS.md.
```
