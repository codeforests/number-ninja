# Handoff: FEAT-09 — Polish and v1.0 release
Branch: feat/FEAT-09-polish · PR: https://github.com/codeforests/number-ninja/pull/11 (ready) · Updated: 2026-11-15 by verify
Stage done: verify (accepted)
Next: Ken merges PR #11, then the `v1.0` release (CI workflow_dispatch on main with release=v1.0). No further build stage.

## What the next stage needs
- All six ACs pass; details in `verify.md`. Final code head `d0d9d82`, CI green including the release APK with `audioplayers`.
- Nit for a later touch: misplaced doc line in `lib/providers.dart` (verify.md, "Beyond the tests").
- Adaptive icon headband tips clip under a circular mask; cosmetic.

## Left to CI or later
- Real sound and look on the tablet with the `v1.0` APK.

## Pending for Ken
- Merge PR #11; check v1.0 on the tablet (sound, backgrounds, celebration, icon, parent sound switch).
