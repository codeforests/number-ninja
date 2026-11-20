# FEAT-19: Verify

> Verified 2026-11-20 in a fresh thread that did not write the code · Commit under test: `27eff7b` · Verdict: **accepted**

## Merge with FEAT-18 (2026-11-20)

PR #28 merged first; main merged into this branch. Conflicts: plan rows (both kept), STATE, `parent_layout_test.dart` (kept `openParent(size:)`; FEAT-18's resize-after workaround dropped, and its code-map gotcha replaced by FEAT-19's). SCR-16 and the "By day" card now run in `parent_layout_test` at all six sizes. `scripts/check.sh` all PASS after the merge.

After that, the build thread's own merge of main added a test-only fix (`4fb1d4b`): the account, server and bank layout tests set the view size before `openParent` too, so they lost it; their `open` helpers now pass `size:`. They pass at their real sizes; full `scripts/check.sh` PASS.

## Checks re-run from a clean checkout

Fresh checkout of `27eff7b`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 1230 tests, 2 skipped (`SYNC_LIVE_URL` live tests, as before) |
| CI on the final head | see the PR #29 checks (release APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `phone_layout_test.dart`: at 360 × 640 and 640 × 360 with Roboto, for the longest prompt of every template, every MCQ option or Check is inside the view and hit-testable (`expectInView`), and after answering so is Next; prompt and answer area don't overlap where they show. | pass |
| AC-2 | `compact` false at 960 × 600, 600 × 960, 1280 × 800 (same file). Tablet branches in `quiz_screen.dart`, `ScreenFrame`, `PinPad`, the dashboard and SCR-11 are the old code behind `compact`; `no_scroll_test.dart` changed only to share the Roboto loader and passes. | pass |
| AC-3 | `parent_phone_test.dart`: SCR-08 and change PIN, keys 1, 3, 0 and back in view at both phone sizes; SCR-08 message, dots and pad don't overlap. | pass |
| AC-4 | `parent_phone_test.dart`: Done ≤ 56 dp high and narrower than 3 × 64 dp on phones, ≥ 3 × 64 dp at 1280 × 800; SCR-09 cards two to a row reaching the right padding in portrait, three in a row in landscape, 192 dp on the tablet; SCR-15 icon starts at the row's left edge. | pass |
| AC-5 | `parent_layout_test.dart` now passes `size:` to `openParent`, so it really runs at the six sizes (640 × 360 … 1280 × 800) and at text scale 1.3; child-size checks pass; `pubspec.yaml` is `2.0.1+4` (`icon_test.dart`). APK build: CI. | pass |

## Beyond the tests

- **Probe (not committed, 444 cases, all pass):** the AC-1 check for every template at 360 × 640 and 640 × 360 with text scale 1.3, and at 412 × 915 and 915 × 412 (a common phone) at scale 1; SCR-11, SCR-12 profile, SCR-13 account and change PIN at both phone sizes, scrolled to the end, with no layout exception.
- **Test diff review:** `expectNoOverlap` now compares each rect clipped to its nearest scroll view. That is a looser check, but only for parts scrolled out of sight, which can't overlap on screen; widgets outside any scroll view are checked as before. `parent_layout_test` got stronger (it used to run at 2560 × 1600 only). Nothing removed, no `skip:`, no other assertion loosened.
- **Conflict note:** PR #28 (FEAT-18) fixes the same `openParent` size bug another way (commit `34efbdb`); whichever merges second must rebase `parent_harness.dart`, `parent_layout_test.dart` and the code-map Gotchas.
- Real-phone look (portrait, landscape) and the tablet regression are Ken's check on the test APK.
