# Handoff: FEAT-09 — Polish and v1.0 release
Branch: feat/FEAT-09-polish · PR: https://github.com/codeforests/number-ninja/pull/11 (draft) · Updated: 2026-11-15 by design + build
Stage done: build (T1–T5 of 5)
Next: verify — kickoff: "Verify FEAT-09 on branch feat/FEAT-09-polish. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Small feature: designed and built in one thread. Deviations are in design §9 (FEAT-09 build row): backgrounds per home track (School / Olympiad), durations in `AppMotion`.
- New tests: `test/tool/sounds_test.dart`, `test/tool/icon_test.dart`, `test/features/quiz/sound_test.dart`, `test/features/parent/sound_switch_test.dart`, `test/features/look/` (AC-4, AC-5), migration v2→v3 and `soundOn` cases in `test/data`.
- Existing test changed: `migration_test.dart` v1→v2 now expects `user_version` 3 (schema bumped); `stats_repository_test.dart` reset case also asserts the sound switch survives. Nothing weakened.
- Regenerate checks: `dart run tool/generate_sounds.dart`, `dart run tool/generate_icon.dart` then `dart run flutter_launcher_icons` should give no diff.
- Worth rendering: SCR-02/03/05 with the backgrounds and the icon (`assets/icon/icon.png`) to judge the look, not only tests.

## Left to CI or later
- APK build with `audioplayers`: CI on PR #11's final head. Real sound and look on the tablet with the `v1.0` release.

## Pending for Ken
- After verify: merge PR #11, then the `v1.0` release (CI workflow_dispatch on main with release=v1.0).
