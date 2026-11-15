# FEAT-08: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `cd786a2` (build `bcdcb1c` + merge of main `9af967f`) · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone at `cd786a2`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (no schema change, as designed) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 667 tests |
| CI run [43702128514](https://github.com/codeforests/number-ninja/actions/runs/43702128514) (`15d6888`, final head) | success (incl. APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `badges_test.dart`: 20 unique ids, empty facts none; below/at for every rule: 2 vs 3 stars, 2 vs 3 days across a month boundary, gap, any run, same day once, 6 vs 7, 29 vs 30; 99 vs 100 and 499 vs 500 attempts; 119.9 s vs 120 s and 2 stars for Speedy; 26 vs 27 of the last 30 for all 7 mastery badges, older wrong answers ignored, 29 attempts not enough, other topics don't count; 19 vs 20 correct for the 3 puzzle badges; quit-round attempts count, quit rounds don't; 18 vs 19 School topics; 22 vs 23 topics at 3 stars. | pass |
| AC-2 | `badge_repository_test.dart` (in-memory DB): first call [], then `first-round, perfect-10, speedy` in shelf order stamped with the clock; [] on repeat; original `earned_at` kept; quit rounds' attempts count at the next finished round; after `resetProgress` empty and earned again. | pass |
| AC-3 | `badges_result_test.dart`: first 10/10 round shows `new-badges` with `first-round` and `perfect-10`, next round none; single badge says "New badge!" and pops in; throwing repository still shows score and stars; `see-badges` opens SCR-06. | pass |
| AC-4 | `badge_shelf_test.dart`: "2 of 20", names and "Earned 15/16 Nov", 18 hints, silhouette semantics label, `badges-back` goes home. | pass |
| AC-5 | `badge_shelf_test.dart`: "My badges", then "Latest: Perfect 10" (tie to later slot, plus `latestBadge` unit test); `badges-button` opens SCR-06; `Routes.counts(/badges)` and `redirectFor` → `/locked`. | pass |
| AC-6 | `badges_layout_test.dart`: SCR-06, SCR-05 with three badges and SCR-02 at the six sizes and scale 1.3, no overlap; 64 dp / 20 sp on all three. All earlier tests pass unchanged. | pass |

## Beyond the tests

- **Rendered screens** (scratch test with Roboto and Material icons loaded, goldens at 1280×800 and 640×360, not committed): shelf shows coloured earned tiles with dates and grey silhouettes with hints, long hints grow the tile as the design §9 build row says; SCR-05 shows "New badges!" with three tiles and the "My badges" button; SCR-02 shows "Latest: School Explorer" beside the minutes left. Nothing clipped.
- **Mutation checks** (scratch clone, reverted): 10 of 12 caught at first (Speedy `<=`, mastery over the oldest 30, streak `>`, streak step 2 days, puzzle target 19, repository re-awarding, unfinished rounds counted, quiz not awarding). **Survived:** School Explorer counting Olympiad topics (every test case also had Olympiad rounds) and Ninja Master accepting 2 stars (the below case had 1 star). Verify added two assertions to `badges_test.dart` (19 School rounds alone award; 22 at 3 stars + one at 2 doesn't); both mutations are now caught. Production code unchanged.
- **Rules.** `lib/domain/badges.dart` imports only domain files; colours and sizes from `theme.dart` (`AppSizes.badge/badgeSmall`, `AppMotion.badgePop`); clock injected into `BadgeRepository` (NFR-08); badge failure caught in `_awardBadges`.
- `earnedBadgesProvider` is autoDispose and home is left with `context.go`, so SCR-02 re-reads the latest badge after a round without an explicit invalidate.

## Test diff review

Five new test files against `main`, no existing test file touched by the build. Nothing removed, no `skip:`, no assertion loosened. Verify's own change only adds assertions.
