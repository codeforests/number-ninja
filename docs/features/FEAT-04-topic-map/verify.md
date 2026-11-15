# FEAT-04: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `3de6b1f` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone of `feat/FEAT-04-topic-map`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff in tracked files (`database.g.dart` matches schema v2) |
| `dart run tool/generate_bank.dart` | no diff (bank unchanged by FEAT-04) |
| `scripts/check.sh` (format, analyze, test) | all PASS, 464 tests, none skipped (AC-7 found Roboto and ran) |
| CI run [43670495919](https://github.com/codeforests/number-ninja/actions/runs/43670495919) (`3de6b1f`) | success (incl. APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `progress_test.dart`: `nextLevel` for stars 0–3 at levels 1, 2, 3 with clamping; `progressByTopic` takes the latest round by `startedAt` (then `id`) and best stars across levels, topics kept apart. | pass |
| AC-2 | `round_repository_test.dart` "progress": a quit round changes neither level nor best stars; `finishRound` stamps `finished_at` from the injected clock. `migration_test.dart`: a v1 database (FEAT-03 `CREATE TABLE`s, `user_version` 1) opens as v2 with the column added, the 10-answer round backfilled to its last `answered_at`, the quit round left null. | pass |
| AC-3 | `result_flow_test.dart` "AC-3": 3 stars at level 1 shows "Level up! Now level 2"; Play again's `rounds.level` is 2 and all its questions are level 2; then 0 stars shows no banner and the next round is level 1 (`[1, 2, 1]`). 2 stars shows no banner. | pass |
| AC-4 | `topic_map_test.dart`: School shows sections P1 and P2 with the 19 School topics in order, each with icon and name; Olympiad shows the 4 `oly.*` topics in one section; a tile starts a round of that topic; back returns home; every topic has an icon and a name of ≤ 4 words. | pass |
| AC-5 | Same file: rounds of 2 then 1 stars give 2 filled stars and "Level 1"; an unplayed topic shows 0 stars and "Level 1"; a quit round counts for nothing; home totals `2 / 57` and `3 / 12`; map and home update after a played round. | pass |
| AC-6 | `responsive_test.dart`: SCR-04 per format, longest prompt and longest with a visual, at the six sizes and 1280 × 800 at 1.3, answering and feedback: no exception, `prompt` / `visual-box` / `answer-area` present and not overlapping. `child_screens_layout_test.dart`: SCR-02, SCR-03 (every tile scrolled into view), SCR-05 with level up at the same 7 cases; NFR-03 tap ≥ 64 dp and text ≥ 20 sp on SCR-02, SCR-03, SCR-05 at 640 × 360, 800 × 1280 and the scaled case. | pass |
| AC-7 | `no_scroll_test.dart`: Roboto loaded; the longest prompt of each of 110 templates at 1280 × 800 has no scrollable with scroll extent. FEAT-03 `layout_test.dart` is unchanged and passes. | pass |

## Beyond the tests

- **Mutation checks** (scratch clone, reverted): level up at 2 stars fails AC-1; counting quit rounds (dropping the `finished_at` filter) fails AC-2; a non-scrolling left half on SCR-04 fails AC-6 at small sizes; a visual box 200 dp taller than the free space fails AC-7 ("scrolls by 200.0 dp"); a missing `level-up` key fails AC-3.
- **Rules.** `lib/domain/progress.dart` imports nothing; new screens take colours from `AppColors` (the 96 dp home icon was already there); `finished_at` uses the injected clock (NFR-08); `topic_list_screen.dart` deleted as designed.

## Test diff review

Seven test files added; `round_repository_test.dart` and `result_flow_test.dart` only gained lines. No existing test changed or removed; no `skip:` (hits are `Iterable.skip`, a local set named `skip` and the AC-7 font guard, which did not fire).

## Notes (not blocking)

1. `expectNoOverlap` ignores keys not on screen; SCR-04 and the SCR-05 `level-up` tests assert presence first, but `result-score` / `result-time` are not asserted present. Cheap to tighten in a later feature.
2. AC-7's no-scroll check covers the answering phase; on 1280 × 800 the feedback phase is covered for overflow (FEAT-03 AC-6) but not for zero scroll. NFR-02 is FEAT-09's to close on the tablet.
3. NFR-03 on SCR-03 checks only the tiles the lazy grid has built; tiles are identical, so this is representative.
4. M2 is FEAT-04 + FEAT-05 (plan §1): merging this PR does not publish a release; the `m2` release follows FEAT-05.
