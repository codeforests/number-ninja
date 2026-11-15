# FEAT-09: Polish and v1.0 release

> Implements: PRC-11, NFR-10, NFR-02 · Screens: SCR-02..07 (look), SCR-05 (celebration), SCR-11 (sound switch)
> Status: designed · Branch: `feat/FEAT-09-polish` · 2026-11-15

## Scope

Ken's M1 feedback (D9) and the v1.0 release. Child screens (SCR-02..07) get coloured backgrounds per track and SCR-05 a short celebration (NFR-10). Four short sound effects play on right answer, wrong answer, round complete and 3 stars, bundled with the app, with a parent on/off switch on SCR-11 (PRC-11). The app gets its own launcher icon. A layout sweep confirms NFR-02 on the 12-inch tablet in landscape and portrait with the new look. Version 1.0.0 and the `v1.0` release APK after merge.

Not in scope: music, voice (D6), animations other than the SCR-05 celebration and the existing badge pop, a new look for parent screens (SCR-01, SCR-08..11 stay plain), new fonts.

## Design decisions (this feature)

- **Sounds are generated, not downloaded.** `tool/generate_sounds.dart` (pure Dart, no packages) synthesises four short mono 16-bit 22 050 Hz WAVs into `assets/sounds/`: `right.wav` (two rising notes, ~0.25 s), `wrong.wav` (one low soft "bonk", ~0.3 s, gentle, not a buzzer), `round.wav` (three-note arpeggio, ~0.6 s), `stars.wav` (round arpeggio plus a sparkle, ~1 s). Each well under 100 KB; no licensing question. Committed like the bank and regenerated, never hand-edited.
- **Playback:** the `audioplayers` plugin (Android, offline assets, low-latency mode). Wrapped in `lib/data/sound_player.dart`: `SoundEffect { right, wrong, round, stars }`, `abstract class SoundPlayer { Future<void> play(SoundEffect e); }`, `AudioSoundPlayer` (real) and `soundPlayerProvider`. Tests override it with a recording fake. A player error is caught and ignored: sound never breaks a round.
- **When sounds play:** `QuizController.check` plays `right` or `wrong` once the answer is checked. SCR-05 plays `stars` for a 3-star round, otherwise `round`, once when it opens (not on rebuild). Nothing plays on quit rounds, parent screens or the lock screen.
- **Off switch:** new column `app_settings.sound_on` (bool, default true), schema v3 with a migration and a `migration_test.dart` case. `SettingsRepository`-style accessors live next to the daily limit in `usage_repository.dart` (`soundOn()`, `setSoundOn(bool)`) and a `soundOnProvider`; the controller and SCR-05 check it before playing. SCR-11 gets a "Sound effects" switch (`sound-switch`) in its own small section. The PAR-10 reset keeps it, like the limit.
- **Backgrounds (NFR-10):** `lib/ui/kid_background.dart` `KidBackground({Track? track, child})` paints a soft vertical gradient in the track's colour (home and lock: a neutral sunny gradient) with a few faint rounded shapes (CustomPainter, no image assets) behind the screen's content. Colours are new `AppColors` entries (`bgP1Top/Bottom`, `bgP2…`, `bgOly…`, `bgHome…`), light enough that text keeps its contrast; cards stay white. Used by SCR-02..07; SCR-04 and SCR-05 take the track from the round's topic.
- **Celebration (SCR-05):** `lib/ui/celebration.dart` `Celebration` overlay: ~40 confetti pieces in the track and accent colours falling for `AppDurations.celebration` (2.5 s), in an `IgnorePointer` so buttons work at once; the stars scale in one after another. Shown for every finished round with 1+ stars; 0 stars gets no confetti but still the `round` sound. Animation timings are durations in `theme.dart`, driven by an `AnimationController` (not the app clock, NFR-08 is about dates and timers).
- **App icon:** `tool/generate_icon.dart` draws a ninja face (indigo `AppColors.ninja` background, white eye band, orange `AppColors.sun` headband) with the `image` package into `assets/icon/icon.png` (1024) and `icon_fg.png` (adaptive foreground); `flutter_launcher_icons` (dev dependency, config in `pubspec.yaml`) writes the Android mipmaps and the adaptive icon. Both PNGs and the mipmaps are committed.
- **Version:** `pubspec.yaml` `version: 1.0.0+2` (above the milestone builds, so it installs over `m3`). After Ken merges, the `v1.0` release runs as CI workflow_dispatch on main with release=v1.0.
- **CI:** adding a plugin means the APK build must prove it, so the draft PR opens at T1 (AGENTS.md, CI wakes).

## Acceptance criteria

- **AC-1** (PRC-11 assets): `test/tool/sounds_test.dart` runs the generator into a temp dir and checks each of the four files is a valid RIFF/WAVE, mono 16-bit, 0.1–1.2 s long, under 100 KB, and byte-identical to `assets/sounds/`; `pubspec.yaml` lists `assets/sounds/`.
- **AC-2** (PRC-11 switch): data test: `sound_on` defaults to true, `setSoundOn(false)` persists, survives `resetProgress`; migration v2→v3 keeps existing rows and adds `sound_on = true`. Widget test: SCR-11 `sound-switch` toggles it.
- **AC-3** (PRC-11 playback): widget tests with the recording fake: a right answer plays `right`, a wrong one `wrong`; SCR-05 plays `stars` once after a 10/10 round and `round` once after a 6/10 round; with sound off nothing plays; a player that throws still lets the round finish and SCR-05 show.
- **AC-4** (NFR-10): widget tests: SCR-02..07 each contain a `KidBackground`, SCR-03/04/05 with the round's track colour; SCR-05 shows `celebration` for a 1+ star round and not for 0 stars, and `play-again` taps through during it; no screen file hard-codes a `Color(` (grep check in the test or `scripts/check.sh` analyze).
- **AC-5** (NFR-02, NFR-03, NFR-09): the existing layout tests pass unchanged with the backgrounds; SCR-05 with the celebration running and SCR-11 with the switch pass `layout_checks.dart` at the six sizes and text scale 1.3; SCR-04 still doesn't scroll at 1280×800 and 800×1280.
- **AC-6** (icon, version): `android/app/src/main/res/mipmap-*/ic_launcher.png` and the adaptive icon XML exist and differ from the Flutter default; `tool/generate_icon.dart` reproduces `assets/icon/*.png` with no diff; `pubspec.yaml` is `1.0.0+2`; CI builds the release APK.

## Tasks

- [ ] T1 — `audioplayers` dependency, `tool/generate_sounds.dart`, `assets/sounds/*.wav`, `sound_player.dart` + provider; open the draft PR so CI proves the plugin in the APK.
      Done when: AC-1 passes (`flutter test test/tool/sounds_test.dart`) and the draft PR's CI builds the APK.
- [ ] T2 — `sound_on` column (schema v3, migration, build_runner), repository accessors, `soundOnProvider`, SCR-11 switch; sound hooks in `QuizController.check` and SCR-05.
      Done when: AC-2 and AC-3 pass (`flutter test test/data test/features/quiz test/features/parent`).
- [ ] T3 — `AppColors` backgrounds and `AppDurations.celebration`, `KidBackground` on SCR-02..07, `Celebration` on SCR-05.
      Done when: AC-4 passes and the touched layout tests still pass (`flutter test test/features test/ui`).
- [ ] T4 — Icon generator, `flutter_launcher_icons` config, mipmaps; version 1.0.0+2.
      Done when: AC-6's local parts pass (generator reruns with no diff, mipmaps present).
- [ ] T5 — AC-5 layout checks; PRC-11, NFR-02, NFR-10 Feature cells; design §4 (`sound_on`) and §9 rows; code-map lines; full `scripts/check.sh`; PR ready for verify.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
