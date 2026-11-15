# FEAT-03: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `86bef49` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone of `feat/FEAT-03-quiz-engine`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff in tracked files |
| `dart run tool/generate_bank.dart` | no diff (bank unchanged by FEAT-03) |
| `scripts/check.sh` (format, analyze, test) | all PASS, 240 tests |
| CI run [43664365573](https://github.com/codeforests/number-ninja/actions/runs/43664365573) (`86bef49`) | success |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `round_builder_test.dart`: 10 distinct at the level; recent-correct only after fresh (7 + 3); nearest-level fill, lower first on a tie; same seed same round; no repeats. `round_repository_test.dart`: `recentCorrectIds` over 5 rounds in two topics returns exactly the last 3 of the topic. | pass |
| AC-2 | `answer_widgets_test.dart`: MCQ tap submits; keypad with `.`, a second `.` ignored, backspace, 6-char cap; drag by dragging and by tapping, tapping a filled box returns its chip (duplicate items). `quiz_screen_test.dart`: each format right then wrong on SCR-04, and drag by dragging on SCR-04. | pass |
| AC-3 | `quiz_screen_test.dart`: with the write held by a gate, no Next and no feedback show and `attempts` is empty; after release the row has id, `3.6`, correct, `time_ms` 4200 from the fake clock. Disposing the tree after 3 answers keeps all 3 attempts, round score 0. | pass |
| AC-4 | Same tests: "Right!" with no answer line; "Not quite", "The answer is …" and the explanation. | pass |
| AC-5 | `result_flow_test.dart`: 7 right gives `7 / 10`, `1:35` (feedback reading time excluded), 1 star, and the `rounds` row matches; 10/9/0 right give 3/2/0 stars. `stars_test.dart` covers 0, 5–10. | pass |
| AC-6 | `layout_test.dart`: longest prompt of each of the 109 templates on SCR-04 at 1280 × 800, answered wrongly so feedback lays out, no exception or overflow; a portrait sample per visual kind and per format; all 9 kinds present. An independent script confirmed the harness's wrong answer is really wrong for all 109 (so every one shows the explanation). | pass |
| AC-7 | `layout_test.dart`: `MinimumTapTargetGuideline(64 × 64)` and text ≥ 20 sp on SCR-04 (three formats, answering and feedback, filled drag box) and SCR-05. | pass |
| AC-8 | `quiz_screen_test.dart`: `next()` returns `void`, the state moves to the next question at once and the repository call count is unchanged. On-tablet 300 ms is Ken's M1 check. | pass (tablet timing pending) |
| AC-9 | `result_flow_test.dart`: home → School → topic → full round → Play again starts a fresh round of the same topic (2 rows); Home returns to SCR-02. | pass |

## Beyond the tests

- **Mutation checks** (in a scratch clone, reverted): showing feedback before `saveAttempt` fails the AC-3 test; dropping the recent-correct preference fails the AC-1 builder test; reading 4 rounds instead of 3 fails the `recentCorrectIds` test.
- **Rules.** `lib/domain` imports no Flutter or Drift; screens and visuals take colours from `AppColors` (only `Colors.transparent` appears); the clock is injected (NFR-08).

## Test diff review

The branch only adds test files (10 files under `test/`); no existing test changed. No `skip:` (the hits are `Iterable.skip` and a local set named `skip`).

## Notes (not blocking)

1. `QuizController.check` has no error handling: if `saveAttempt` throws (disk full), the screen stays in "saving" with no way forward but Quit. Rare on a tablet; worth a try/catch when FEAT-05 or later touches the controller.
2. The recent-correct preference works per level: a recent question at the round's level is used before a fresh one at another level. This matches design.md ("same preference" within each level) and only matters once FEAT-04 adds levels.
