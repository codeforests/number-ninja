# Build state

> The first file a build or verify thread reads. Keep it under 40 lines.

- **Phase:** phase 2 construction. v1 (FEAT-01..09) is done and released as `v1.0`. Phase 2 (requirements 2.0, `04-architecture.md`, plan 2.0 with FEAT-10..16) signed off by Ken 2026-11-15 (PR #12).
- **In progress:** FEAT-13 parent account, verified (accepted, AC-6 live pending); PR #18 ready, waiting for Ken's merge.
- **Remaining order:** 10, 17, 11 (M5, offline) → 12, 13, 14 (M6, server, account, sync) → 15, 16 (M7, server bank, rename, `v2.0`).
- **Merged:** FEAT-12 (PR #17), server live; restore drill pending. FEAT-11 (PR #16); M5 done, release `m5` published. FEAT-17 (PR #15). FEAT-10 (PR #14). FEAT-09 polish (PR #11, 2026-11-15, accepted); M4 done, release `v1.0` published. FEAT-08 badges (PR #10, 2026-11-15, accepted); M3 done, release `m3` published (from main 30e3ff8). FEAT-07 PDF report (PR #8, 2026-11-15, accepted). FEAT-06 parent dashboard (PR #7, 2026-11-15, accepted). FEAT-05 screen-time lock (PR #6, 2026-11-15, accepted); M2 done, release `m2` published. FEAT-04 home, topic map and difficulty steps (PR #5, 2026-11-15, accepted). FEAT-03 quiz engine (PR #4, 2026-11-15, accepted); M1 signed off by Ken, release `m1` published. FEAT-01 walking skeleton (PR #2, 2026-11-14, accepted). FEAT-02 question bank (PR #3, 2026-11-15, accepted; format mix 29/62/9, not rebalanced).
- **Environment:** in the number-ninja cloud environment Flutter 3.50.0 is preinstalled; check `which flutter` first and install into ~/sdk/flutter only if it's missing: install the stable tarball listed in `releases_linux.json` (3.50.0) into `~/sdk/flutter`, add `~/sdk/flutter/bin` to PATH, and run `git config --global --add safe.directory ~/sdk/flutter`. There's no Android SDK either, so APK builds and the manifest check run only in GitHub CI (runs on every push to a PR). Material widgets come from `package:material_ui/material_ui.dart`.
- **Last CI run:** [43864304629](https://github.com/codeforests/number-ninja/actions/runs/43864304629) (FEAT-12 re-verify, PR #17), success.

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
