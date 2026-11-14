# Build state

> The first file a build or verify thread reads. Keep it under 40 lines.

- **Phase:** construction. Requirements, design and plan signed off by Ken 2026-11-14 (PR #1).
- **In progress:** FEAT-02 question bank on `feat/FEAT-02-question-bank`: designed, T1 built; next stage and kickoff in `docs/features/FEAT-02-question-bank/handoff.md`.
- **Remaining order:** FEAT-02 → 03 (M1) → 04 → 05 (M2) → 06 → 07 → 08 (M3) → 09 (M4).
- **Merged:** FEAT-01 walking skeleton (PR #2, 2026-11-14, accepted).
- **Environment:** cloud sessions have no Flutter SDK: install the stable tarball listed in `releases_linux.json` (3.50.0) into `~/sdk/flutter`, add `~/sdk/flutter/bin` to PATH, and run `git config --global --add safe.directory ~/sdk/flutter`. There's no Android SDK either, so APK builds and the manifest check run only in GitHub CI (runs on every push to a PR). Material widgets come from `package:material_ui/material_ui.dart`.
- **Last CI run:** [43603699383](https://github.com/codeforests/number-ninja/actions/runs/43603699383) on PR #2 head `d66b902`, success, release-signed APK artifact `number-ninja-apk`.

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
