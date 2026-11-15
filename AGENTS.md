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

Each stage of a feature runs in its own fresh thread and hands off through files, never through chat history. This file is already in every thread's context (through `CLAUDE.md`): don't read it again.

- **Read first, and only:** `docs/STATE.md`, then the feature's `handoff.md`, then the sections of `design.md` the current task needs, then `docs/code-map.md` sections for the code the task touches. Never read old threads or conversations; if a fact is missing from the files, ask Ken.
- **End every stage** by overwriting `docs/features/FEAT-NN-<slug>/handoff.md` (template below, under 25 lines), updating `docs/STATE.md`, pushing the branch, appending one line to the token log (below), and asking the coordinator to start the next stage's thread with the exact kickoff from the handoff. Only a decision for Ken, a ready PR (merge) or the next feature waits for him.

### Stages (kickoffs in `docs/STATE.md`)

| Stage | Reads | Ends with |
|---|---|---|
| Design | plan row (`grep -n FEAT-NN docs/03-plan.md`), the cited requirement rows and `02-design.md` sections, `code-map.md` | `design.md`, handoff. **Small feature** (≤5 tasks, nothing pending for Ken): carry straight on into the build in the same thread instead of handing off. |
| Build | handoff, `design.md` sections for the task, `code-map.md` | one commit per task; after ~6 tasks or a long session, stop at a task boundary and hand off to a fresh build. Last session opens the draft PR. |
| Verify | handoff, `design.md` ACs, `git diff origin/main...HEAD` | `verify.md`, Verified by cells, STATE; PR ready. |
| Rework fix | handoff, `verify.md` "Rework" section only | fix commits; handoff to re-verify naming the verified commit. |
| Re-verify | handoff, `verify.md` "Rework" section, `git diff <verified sha>..HEAD` | re-check only the failed ACs and the tests the fix touched, then `scripts/check.sh` and CI once; a short section at the top of `verify.md`. Don't redo the clean-clone or the ACs that already passed. |

Don't load the `agentic-sdlc-kit` skills: this file and the previous feature's documents read by heading are the format. When you take a format from an earlier feature, read its headings (`grep -n '^#'`) and one section, never a whole `design.md` or `verify.md`.

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

### Token log

Each stage appends one line to `/mnt/project-files/reviews/token-use.md` (create it with the header if missing; re-read it just before writing): `| date | FEAT-NN | stage | minutes | tool calls | context at end (if shown, else "n/a") | biggest reads |`. One line, no prose: the log is for spotting a heavy stage, not for analysis.

## Token rules

Every tool call re-sends the whole context, and a thread starts with a large fixed prompt, so the number of threads, the number of calls and the size of what you read all cost.

- Run checks through `scripts/check.sh` (one PASS/FAIL line each, failure lines only). Open a failed log with `grep -n`, never whole.
- Read by section: `grep -n '^#' file` then `sed -n 'A,Bp'`. Don't read a file over ~300 lines whole; never read generated files (`*.g.dart`, `assets/questions/*.json`). `docs/code-map.md` says where code lives: use it instead of listing or surveying `lib/`.
- Code you call but don't change: read its signature, not its body. For a test, copy the setup of one neighbouring test and one case, not the whole file (`test/features/quiz/quiz_harness.dart`, `test/ui/layout_checks.dart` are the helpers).
- Batch: several reads in one shell call, and per task edit → check → commit in one shell call where possible. Set up the Flutter SDK, `flutter pub get` and `build_runner` in one call at the start.
- Diff against the remote: `git fetch origin main` then `git diff origin/main...HEAD` (local `main` is stale in a fresh clone).
- While building, run only the tests the task touches; the full `scripts/check.sh` runs once at the end of the build and in verify.
- **CI wakes cost a full context re-read each.** Build commits carry `[skip ci]` except the session's last push. Open the draft PR at the end of the build, or at T1 only when the feature adds a plugin or Android config the APK build must prove. Only the verify thread subscribes to the PR, and it runs CI once on the final head.
- `docs/STATE.md` holds the current state only: the "In progress" bullet names the current feature and stage in one line, and "Merged" lists ids and PR numbers only. History lives in the PRs and `verify.md`.
- Gotchas worth keeping go in `docs/code-map.md` ("Gotchas"), not in chat or memory.
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
