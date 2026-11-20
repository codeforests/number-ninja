# FEAT-16: Verify

Verdict: **accepted** (2026-11-17, code `c4d7222`). CI on the verify head is the last check (AC-5 server job, AC-6 APK).

## Checks re-run from a clean checkout

Fresh clone at `c4d7222`, Flutter 3.50.0.

| Check | Result |
|---|---|
| `scripts/check.sh` (format, analyze, test) | all PASS |
| `progress_bar_test.dart` with the new keypad test | PASS, 3 tests |
| CI (APK build, `server` job: migrations apply, `nginx -t`) | on PR #27 at the verify head |

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `grep -rn "Number Ninja\|'Ninja"` over `lib`, manifest, `server/nginx`, `server/pb_*`, README, CI finds only the "Formerly" note in README and the comment on the already-applied FEAT-12 migration. Manifest `android:label="BrainBubblz"`; home greeting, `MaterialApp.title`, report title/creator/footer, profile intro say BrainBubblz; `ninja-master` is "Bubble Master". |
| AC-2 | pass | `namespace`/`applicationId` `com.codeforests.number_ninja`; `numberninja://signin` in manifest and both nginx pages; badge id unchanged. |
| AC-3 | pass | `test/tool/icon_test.dart` (generator reproduces `assets/icon`, mipmaps indigo, adaptive icon) in the full run. |
| AC-4 | pass | `pubspec.yaml` `2.0.0+3`; `icon_test.dart` checks it. |
| AC-5 | pass locally, CI pending | `1763251205_rename.js` sets `meta.appName = "BrainBubblz"` and saves (same calls as `1763251201`); the old migration is not edited in effect (comment only). Return page title, heading and button say BrainBubblz, link unchanged. |
| AC-7 | pass | `progress_bar_test.dart`: at 360×720 and 1280×800 the steps row and `progress-count` end inside the screen, count goes 1/10 → 2/10. Verify added a test that digit keys are `keyFace` with `ninja` ink and delete is `keyDelete` with `keyDeleteInk`. Colours and sizes are in `theme.dart`. |
| AC-6 | pass locally, CI pending | check.sh green; `regression.md` lists 9 tablet checks. |

## Beyond the tests

- Exported PDF file name was still `number-ninja-report-…`; renamed to `brainbubblz-report-<date>-<range>.pdf` on Ken's ask (2026-11-20), `report_test` and `report_export_test` updated and passing.
- No requirement row names FEAT-16 (D16 is a decision row), so there are no Verified by cells to fill.

## Test diff review

No test weakened, skipped or deleted. `report_test`, `start_level_test`, `icon_test` change only the expected name and version. The AC-7 test claimed keypad colours but didn't assert them; verify added that case.
