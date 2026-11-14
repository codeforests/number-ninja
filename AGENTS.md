# AGENTS.md

Guidance for coding agents and people working in this repo. `CLAUDE.md` only points here.

## What this is

Number Ninja: an offline Flutter app for an Android tablet that helps one child practise P1/P2 and Olympiad maths, with timed answers, a PIN-protected parent dashboard and a daily screen-time limit. Requirements, design and plan are in `docs/`; `docs/STATE.md` says where the build is.

## Commands

```sh
flutter pub get
dart run build_runner build      # after changing Drift tables
dart run tool/generate_bank.dart # regenerate the question bank (FEAT-02)
dart format .
flutter analyze
flutter test
flutter build apk --release      # output: build/app/outputs/flutter-apk/app-release.apk
```

## Rules

- Work one feature at a time as in `docs/03-plan.md` §2: design → build → verify (fresh thread) → PR. Don't start the next feature until Ken says so.
- Cite ids (BNK-03, PAR-02, D5, SCR-04) instead of restating requirements. Ids are permanent.
- Layers: `lib/domain` is pure Dart (no Flutter, no Drift); `lib/data` wraps Drift and the bank; `lib/features` holds screens; `lib/ui` shared widgets and the theme. Code calls downwards only.
- Colours, radii and text sizes come from `lib/ui/theme.dart`; never hard-code them in screens.
- Dates and timers take the clock as a parameter (NFR-08).
- Generated files (`*.g.dart`, the bank JSON) are committed; regenerate them, never edit by hand.
- Never weaken, skip or delete a test to get green.
- Every feature PR fills the Feature and Verified by cells in `docs/01-requirements.md` and updates `docs/STATE.md`.
