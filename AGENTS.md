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

## How a session starts and ends (handoffs)

Each stage of a feature (design, build, verify) runs in its own fresh thread and hands off through files, never through chat history.

- **Read first, and only:** `docs/STATE.md`, then the feature's `handoff.md`, then the sections of `design.md` the current task needs. Never read old threads or conversations; if a fact is missing from the files, ask Ken.
- **End every stage** by overwriting `docs/features/FEAT-NN-<slug>/handoff.md` (template below, under 40 lines), updating `docs/STATE.md`, pushing the branch, and asking the coordinator to start the next stage's thread with the exact kickoff from the handoff. Only a decision for Ken, a ready PR (merge) or the next feature waits for him.
- A build stops at a task boundary after about 6 tasks or when the session feels long, and hands off to a fresh build thread the same way.

```
# Handoff: FEAT-NN — <name>
Branch: feat/FEAT-NN-<slug> · PR: <link or none> · Updated: <date> by <stage>
Stage done: design | build (T1–Tn of N) | verify (<verdict>)
Next: <stage> — kickoff: "<exact prompt>"

## What the next stage needs
- <facts not obvious from design.md: decisions, deviations, gotchas, file names>

## Left to CI or later
- <what wasn't run here and why>

## Pending for Ken
- <questions or checks, or "none">
```

## Token rules

- Run checks through `scripts/check.sh` (one PASS/FAIL line each, failure lines only). Open a failed log with `grep -n`, never whole.
- Read by section: `grep -n '^#' file` then `sed -n 'A,Bp'`. Don't read a file over ~300 lines whole; never read generated files (`*.g.dart`, `assets/questions/*.json`).
- Batch: per task, edit → check → commit in one shell call where possible.
- Code you call but don't change: read its signature, not its body.
- While building, run only the tests the task touches; the full `scripts/check.sh` runs once at the end of the build and in verify.
- Keep replies to Ken short; details go in the files.

## Rules

- Work one feature at a time as in `docs/03-plan.md` §2: design → build → verify (fresh thread) → PR. Don't start the next feature until Ken says so.
- Cite ids (BNK-03, PAR-02, D5, SCR-04) instead of restating requirements. Ids are permanent.
- Layers: `lib/domain` is pure Dart (no Flutter, no Drift); `lib/data` wraps Drift and the bank; `lib/features` holds screens; `lib/ui` shared widgets and the theme. Code calls downwards only.
- Colours, radii and text sizes come from `lib/ui/theme.dart`; never hard-code them in screens.
- Dates and timers take the clock as a parameter (NFR-08).
- Generated files (`*.g.dart`, the bank JSON) are committed; regenerate them, never edit by hand.
- Never weaken, skip or delete a test to get green.
- Every feature PR fills the Feature and Verified by cells in `docs/01-requirements.md` and updates `docs/STATE.md`.
