# FEAT-02: Verify

> Verified 2026-11-14 in a fresh thread that did not write the code · Commit under test: `43ee587` · Verdict: **accepted**

## Checks re-run from a clean checkout

Clean worktree of `origin/feat/FEAT-02-question-bank`, Flutter 3.50.0 (Dart 3.14.0), the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart format --output=none --set-exit-if-changed lib test tool` | 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 61 passed, 0 failed, 0 skipped |
| `dart run tool/generate_bank.dart`, then `git diff --exit-code assets/` | clean; two more runs give the same MD5 (`0ad24e8a…5f5f`) |
| `dart run build_runner build` | no diff in tracked files |
| CI run [43605859362](https://github.com/codeforests/number-ninja/actions/runs/43605859362) (`43ee587`) | success: format, analyze, 61 tests, "Question bank is up to date", release signing (secrets present, no debug-key warning), release build (55.2 MB APK), manifest check (no `INTERNET`, minSdk 24), artifact `number-ninja-apk` (id 14118093900) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `pubspec.yaml` lists `assets/questions/bank_v1.json`; file has `"version":1`. `question_bank_test.dart` "is bundled, version 1, and loadBank returns every question" (count equals the file's question lines) and "loadBank reads from any AssetBundle" (asks for `bankAsset`). `lib/` loads questions only through `loadBank`. | pass |
| AC-2 | `question_bank_test.dart` AC-2 test; generator output: 23 topics, 60–71 each, every level present (smallest level count 18). | pass |
| AC-3 | Byte-identical regeneration (above, and the "committed file is what the generator writes" test). `bank_validator_test.dart` has one test per rule: wrong `check`, duplicate id, MCQ with zero and with two correct options, duplicate prompt in a topic, topic under 40. Shipped bank: validator returns zero problems. | pass |
| AC-4 | Id pattern test on the shipped bank (and the topic prefix equals `topic`). `generator_test.dart` AC-4 adds a dummy template to `p1.place` and checks every existing id maps to identical JSON, with exactly 5 new questions. | pass |
| AC-5 | `question_bank_test.dart` AC-5: every explanation non-empty after trimming. | pass |
| AC-6 | `answers_test.dart`: `3.6`, `3.60` and ` 3.60 ` accepted for `3.60`, `3.06`/empty/junk rejected; wrong MCQ option rejected; drag accepted only in the right order and full length. | pass |
| AC-7 | `generator_test.dart` "p2.regroup: every question regroups or has two steps" (parses `check`, positive answers) and the D2 test on bare P2 sums (more than 20 cases, all regroup). | pass |

## Beyond the tests

- **Independent answer audit.** A separate Python script (not the repo's evaluator) re-evaluated every `check` with exact fractions against `answer`, and re-checked MCQ (3–4 unique options, exactly one equal to the answer) and drag structure (answer length = slots, every item listed). 1,394 questions, 0 problems.
- **Questions without `check`** (634, mostly time, shapes, fractions, graphs, logic): spot-checked about 40 across every topic by hand, including the hand-written counting ones (3-digit numbers with digit sum 3 = 6; ways to make 20¢ from 5¢ and 10¢ = 3). All correct.
- **D2 sweep.** Every P2 question whose `check` is a single `a ± b` without regrouping is a word problem, picture-graph reading, "10/100 more or less" place value, or a time conversion; none is a plain drill, which D2 allows. P1 `p1.bonds` missing-number items match design §2 ("Number bonds and missing numbers"), and D2 targets P2 drills, so the handoff's question on bonds is a pass.
- **Layers.** `lib/domain` imports only `dart:` libraries, `crypto` and itself; `tool/` imports only `lib/domain`, so it runs with plain `dart run`.

## Test diff review

The branch only adds five test files (465 lines); no existing test changed. No `skip:` anywhere (the `.skip(1)` hits are `Iterable.skip`).

## Notes (not blocking)

1. **Format mix** is mcq 29%, number 62%, drag 9% against the design §3 target of about 45/40/15. The design says this is reported, not enforced, so it passes; Ken may want more MCQ and drag in a later bank version (new templates only, BNK-05).
2. P2 fraction answers are not simplified (`3/4 − 1/4 = 2/4`). That matches P2 (like fractions, no simplifying); FEAT-03 should keep MCQ option text as is.
3. Handoff deviation (outfit/menu counting instead of grid paths) is fine for FEAT-02; it doesn't change any requirement.
