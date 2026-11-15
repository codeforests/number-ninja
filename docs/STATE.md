# Build state

> The first file a build or verify thread reads. Keep it under 40 lines.

- **Phase:** construction. Requirements, design and plan signed off by Ken 2026-11-14 (PR #1).
- **In progress:** FEAT-03 quiz engine (completes M1) on `feat/FEAT-03-quiz-engine`: built T1–T6 of 7 (2026-11-15, `scripts/check.sh` all PASS, 107 tests). Next: build T7 (result screen, full-round/layout/size tests, draft PR).
- **Remaining order:** 03 (M1) → 04 → 05 (M2) → 06 → 07 → 08 (M3) → 09 (M4).
- **Merged:** FEAT-01 walking skeleton (PR #2, 2026-11-14, accepted). FEAT-02 question bank (PR #3, 2026-11-15, accepted; format mix 29/62/9, not rebalanced).
- **Environment:** cloud sessions have no Flutter SDK: install the stable tarball listed in `releases_linux.json` (3.50.0) into `~/sdk/flutter`, add `~/sdk/flutter/bin` to PATH, and run `git config --global --add safe.directory ~/sdk/flutter`. There's no Android SDK either, so APK builds and the manifest check run only in GitHub CI (runs on every push to a PR). Material widgets come from `package:material_ui/material_ui.dart`.
- **Last CI run:** [43605859362](https://github.com/codeforests/number-ninja/actions/runs/43605859362) on PR #3 head `43ee587`, success incl. the bank-up-to-date step, release-signed APK artifact `number-ninja-apk`.

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
