# Handoff: FEAT-26 — Parent first-run setup
Branch: feat/FEAT-26-first-run-setup · PR: https://github.com/codeforests/number-ninja/pull/33 · Updated: 2026-11-20 by rework fix
Stage done: rework fix (R1)
Next: re-verify — kickoff: "Re-verify FEAT-26 on branch feat/FEAT-26-first-run-setup since 8f74de9. Read docs/STATE.md and the handoff.md, then do the Re-verify stage in AGENTS.md."

## What the next stage needs
- R1 fixed in `lib/features/setup/children_step.dart` (`onBack`): Back stays on while the form is open and no child exists; with children it stays off and Cancel returns to the list. Recorded as design AD-16.
- `flutter test test/features/setup/` passes (18, incl. `AC-1: Back on an empty Children step (verify)` and the AC-6 layout tests); `flutter analyze lib/features/setup` clean. Full `scripts/check.sh` and CI not run here.
- Re-verify only AC-1, AC-6 layout and the setup tests; then `scripts/check.sh` and CI once on the head.

## Left to CI or later
- APK build in CI on the final head. AC-7 is Ken's optional tablet check.

## Pending for Ken
- none
