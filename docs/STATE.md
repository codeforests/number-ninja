# Build state

> The first file a build or verify thread reads. Keep it under 40 lines.

- **Phase:** construction. Requirements, design and plan signed off by Ken 2026-11-14 (PR #1).
- **In progress:** FEAT-05 screen-time lock on `feat/FEAT-05-screen-time`: verified and accepted 2026-11-15 (verify.md, 507 tests), PR [#6](https://github.com/codeforests/number-ninja/pull/6) ready for Ken. After merge, publish release `m2` (completes M2). Ken's M1 feedback still open: PRC-11 and NFR-10 (FEAT-09).
- **Remaining order:** 04 → 05 (M2) → 06 → 07 → 08 (M3) → 09 (M4).
- **Merged:** FEAT-04 home, topic map and difficulty steps (PR #5, 2026-11-15, accepted). FEAT-03 quiz engine (PR #4, 2026-11-15, accepted); M1 signed off by Ken, release `m1` published. FEAT-01 walking skeleton (PR #2, 2026-11-14, accepted). FEAT-02 question bank (PR #3, 2026-11-15, accepted; format mix 29/62/9, not rebalanced).
- **Environment:** cloud sessions have no Flutter SDK: install the stable tarball listed in `releases_linux.json` (3.50.0) into `~/sdk/flutter`, add `~/sdk/flutter/bin` to PATH, and run `git config --global --add safe.directory ~/sdk/flutter`. There's no Android SDK either, so APK builds and the manifest check run only in GitHub CI (runs on every push to a PR). Material widgets come from `package:material_ui/material_ui.dart`.
- **Last CI run:** [43673301798](https://github.com/codeforests/number-ninja/actions/runs/43673301798) on `b9f74cb`, success.

## Kickoff prompts (the handoff names the exact one)

```
Design FEAT-NN on branch feat/FEAT-NN-<slug> (create it from main).
Read AGENTS.md and docs/STATE.md, then do docs/03-plan.md §2 step 1.
```
```
Build FEAT-NN (from T<n>) on branch feat/FEAT-NN-<slug>.
Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2.
```
```
Verify FEAT-NN on branch feat/FEAT-NN-<slug>.
Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4.
```
