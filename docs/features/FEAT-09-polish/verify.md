# FEAT-09: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `d0d9d82` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone at `d0d9d82`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (schema v3) |
| `dart run tool/generate_bank.dart` | no diff |
| `dart run tool/generate_sounds.dart` | no diff |
| `dart run tool/generate_icon.dart` then `dart run flutter_launcher_icons` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 696 tests |
| CI run [43705493948](https://github.com/codeforests/number-ninja/actions/runs/43705493948) (`d0d9d82`, final code head) | success (incl. release APK build with `audioplayers`) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `test/tool/sounds_test.dart`: four sounds; each generated into a temp dir is RIFF/WAVE, mono, 16-bit, 0.1–1.2 s, under 100 KB and byte-identical to `assets/sounds/`; pubspec lists `assets/sounds/`. | pass |
| AC-2 | `usage_repository_test.dart` default true and `setSoundOn(false)` persists; `stats_repository_test.dart` reset keeps it off; `migration_test.dart` v2→v3 keeps PIN hash and limit 35 and adds `sound_on = true` (v1→v2 now expects `user_version` 3, the new schema, not weakened); `sound_switch_test.dart` toggles `sound-switch` and saves. | pass |
| AC-3 | `test/features/quiz/sound_test.dart`: right/wrong per answer; 9/10 plays `round` once and no `stars`; 10/10 plays 10 × `right` and `stars` once; 6/10 plays exactly 6 right, 4 wrong, `round`; sound off plays nothing; throwing player still reaches SCR-05 with the score. | pass |
| AC-4 | `test/features/look/kid_look_test.dart`: SCR-02/06/07 home scene, SCR-03 School and Olympiad, SCR-04/05 the round's track; `celebration` on 10/10 and `play-again` taps through it; none at 0 stars; grep finds no `Color(0x` in `lib/features`. | pass |
| AC-5 | `look_layout_test.dart`: SCR-05 mid-celebration at the six sizes and scale 1.3, no overlap, child sizes ok; SCR-11 with the switch covered by the existing `parent_layout_test.dart`; `no_scroll_test.dart` and all other layout tests pass unchanged. | pass |
| AC-6 | `test/tool/icon_test.dart`: generator reproduces `assets/icon/*.png`; mipmaps differ from the Flutter default and `mipmap-anydpi-v26/ic_launcher.xml` exists; version `1.0.0+2`. CI built the release APK. | pass |

## Beyond the tests

- **Rendered screens** (scratch test with Roboto and Material icons, 1280×800, not committed): SCR-02 sunny yellow-to-pink gradient with faint shapes, white cards keep contrast; SCR-04 (P2 money) sky-to-mint, question, coins and keypad all readable; SCR-05 (Olympiad 10/10) lilac-to-pink, confetti falling over three stars, "Level up!", score and buttons clear.
- **Icon:** indigo background, dark round ninja head, white eye band, orange headband. Note: on the adaptive icon the headband tails reach past the 66 dp safe zone, so a circular launcher mask clips their tips. Cosmetic; the face stays whole.
- **Sound code:** `SoundEffects` swallows errors and checks the switch on every play; callers don't await it, so sound never delays a round. SCR-05 plays from `initState`, so a rebuild doesn't replay.
- **Nit (not blocking):** in `lib/providers.dart` the doc line "One per app opening, so its play session is shared by every round." now sits above `soundEffectsProvider` instead of `roundRepositoryProvider`, because the new provider was inserted under it.
- Real sound volume and feel on the tablet: Ken's check with the `v1.0` APK.

## Test diff review

Six new test files plus new cases in `test/data`. Two existing files changed: `migration_test.dart` (v1→v2 case expects `user_version` 3 because the schema moved to v3; all its other assertions kept) and `stats_repository_test.dart` (one added assertion). `quiz_harness.dart` gains the recording sound fake. Nothing removed, no `skip:`, no assertion loosened.
