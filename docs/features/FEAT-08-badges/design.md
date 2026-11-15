# FEAT-08: Badges and badge shelf

> Implements: BDG-01..03 · Screens: SCR-05 (new badge), SCR-06 (badge shelf), SCR-02 (latest badge)
> Status: designed · Branch: `feat/FEAT-08-badges` · 2026-11-15

## Scope

The app awards the 20 badges of design §7 by rules in code and records each one once in `badges_earned` with the clock's time (BDG-01). When a round finishes, any badge earned by it is celebrated on SCR-05 (BDG-02). A new child screen SCR-06 shows all 20 badges: earned ones in colour with the date, unearned ones as grey silhouettes with a hint (BDG-03). SCR-02 shows the latest badge and opens the shelf. No schema change: `badges_earned (badge_id PK, earned_at)` exists since FEAT-01, and the PAR-10 reset already empties it.

Not in scope: sound or confetti (PRC-11 and NFR-10, FEAT-09), badges in the PDF report or dashboard, taking a badge away (once earned it stays until a parent reset).

## Design decisions (this feature)

- **Rules are evaluated from scratch.** `evaluateBadges(BadgeFacts)` in the domain returns every badge id whose rule holds over all finished rounds and all attempts; the repository inserts the ones not yet in `badges_earned`. No counters are stored, so the rules can't drift from the records, and badges from rounds played before FEAT-08 are awarded at the first round after the update (SCR-05 then shows several). A few thousand attempts evaluate in well under 100 ms.
- **When:** only after a round's last answer is saved (`QuizController.check`, after `finishRound`). Quit rounds award nothing at the time, but their attempts count towards the attempt-based rules at the next finished round (same counting as FEAT-06 stats). A badge failure is caught: the round is already saved and SCR-05 shows without badges.
- **Rule details** (ids are permanent, like topic ids). "Finished round" = a `rounds` row with `finished_at`; "day" = local calendar date of `finished_at`; attempts are `AttemptRecord`s (all time, topic from the bank, unknown ids skipped, as in `StatsRepository.records`).

| Id | Name | Rule | Hint (SCR-06) |
|---|---|---|---|
| `first-round` | First Round | 1 finished round | Finish your first round |
| `perfect-10` | Perfect 10 | a finished round with 3 stars (10/10, design §5) | Get 10 out of 10 |
| `streak-3` | 3-Day Streak | finished rounds on 3 consecutive days (any run, not only ending today) | Play 3 days in a row |
| `streak-7` | 7-Day Streak | 7 consecutive days | Play 7 days in a row |
| `streak-30` | 30-Day Streak | 30 consecutive days | Play 30 days in a row |
| `questions-100` | 100 Questions | 100 attempts | Answer 100 questions |
| `questions-500` | 500 Questions | 500 attempts | Answer 500 questions |
| `speedy` | Speedy | a 3-star round with `duration_ms` < 120 000 | Get 10 out of 10 in under 2 minutes |
| `times-hero` | Times Table Hero | mastery of `p2.times` | Get 27 of your last 30 times table answers right |
| `division-dojo` | Division Dojo | mastery of `p2.divide` | Get 27 of your last 30 division answers right |
| `fraction-friend` | Fraction Friend | mastery of `p2.fractions` | Get 27 of your last 30 fraction answers right |
| `money-master` | Money Master | mastery of `p1.money` + `p2.money` | Get 27 of your last 30 money answers right |
| `time-keeper` | Time Keeper | mastery of `p1.time` + `p2.time` | Get 27 of your last 30 time answers right |
| `shape-spotter` | Shape Spotter | mastery of `p1.shapes` + `p2.shapes` | Get 27 of your last 30 shape answers right |
| `pattern-finder` | Pattern Finder | mastery of `oly.patterns` | Get 27 of your last 30 pattern answers right |
| `puzzle-master` | Puzzle Master | 20 correct `oly.logic` attempts | Solve 20 logic puzzles |
| `counting-star` | Counting Star | 20 correct `oly.counting` attempts | Solve 20 counting puzzles |
| `bar-model-builder` | Bar Model Builder | 20 correct `oly.models` attempts | Solve 20 bar model questions |
| `school-explorer` | School Explorer | a finished round in every P1 and P2 topic (19) | Finish a round in every School topic |
| `ninja-master` | Ninja Master | best stars 3 in all 23 topics (`progressByTopic`) | Get 3 stars in every topic |

- **Mastery** = at least 30 attempts in the topic(s) and at least 27 correct among the latest 30 by `answered_at` (ties by question id). This reads design §7's "90%+, 30+ attempts" as the latest 30 rather than all time, so early mistakes while learning never block the badge. Recorded in design §9.
- **Streak days** are walked with `DateTime(y, m, d + 1)`, not `+ Duration(days: 1)`, so a DST change can't break a run (NFR-08: the clock is injected, nothing reads `DateTime.now()`).
- **Order:** the table order is the shelf order and the order new badges are shown on SCR-05. `earned_at` is the clock at award time; badges awarded together share it. "Latest" on SCR-02 = greatest `earned_at`, ties broken by the later table position.
- **Icons and colours** live in the UI layer (`lib/ui/badge_icons.dart`, like `topic_icons.dart`): one Material icon per id and a colour from `AppColors`. Unearned = a silhouette: the same icon in `AppColors.muted` on `AppColors.chartGrid`. New sizes (`AppSizes.badge` 96, `badgeSmall` 48) and the pop duration (`AppMotion.badgePop` 600 ms) go in `theme.dart`.
- **SCR-06 counts as screen time** (child screen): `/badges` is added to `Routes.counts`, so the lock applies there too (TIM-01/02).

## Design

- **Domain** (`lib/domain/badges.dart`, pure Dart): `class Badge {id, name, hint}`; `const badges = <Badge>[...]` (20, table order); `class BadgeRound {topicId, stars, durationMs, finishedAt}`; `class BadgeFacts {rounds: List<BadgeRound>, attempts: List<AttemptRecord>}`; `Set<String> evaluateBadges(BadgeFacts f)`; `bool mastered(Iterable<AttemptRecord> a, Set<String> topicIds)`; `int longestStreak(Iterable<DateTime> days)`. `ninja-master` uses `progressByTopic` from `progress.dart` (needs `FinishedRound`; build those from `BadgeRound` with id/level placeholders, or add a small best-stars helper, build's choice).
- **Data** (`lib/data/badge_repository.dart`): `BadgeRepository(AppDatabase db, StatsRepository stats, {required Clock clock})`. `Future<Map<String, DateTime>> earned()`; `Future<List<Badge>> awardNew()` loads finished rounds (`score`, `duration_ms`, `stars`, `finished_at`) and `stats.records()`, evaluates, inserts the new ids with `insertOrIgnore` in one transaction stamped `clock()`, returns them in table order. Providers in `providers.dart`: `badgeRepositoryProvider` (FutureProvider, like `statsRepositoryProvider`) and `earnedBadgesProvider` (FutureProvider.autoDispose of `earned()`).
- **Quiz** (`quiz_controller.dart`): after `finishRound`, `newBadges = await (await ref.read(badgeRepositoryProvider.future)).awardNew()` in a try/catch (empty on error); kept on `RoundState` and passed as `RoundSummary.newBadges` (`List<Badge>`, default const []).
- **SCR-05** (`result_screen.dart`): when `newBadges` is non-empty, below the stars and level-up line: "New badge!" (or "New badges!") heading key `new-badges`, then a `Wrap` of tiles key `new-badge-<id>` (badge icon at `AppSizes.badge` in a coloured circle, name below) that pop in with a `TweenAnimationBuilder` scale 0 → 1 over `AppMotion.badgePop`; and a third button "My badges" key `see-badges` going to `/badges`. Stays inside the existing `SingleChildScrollView`.
- **SCR-06** (`lib/features/badges/badge_shelf_screen.dart`, route `Routes.badges = '/badges'`): AppBar-free child screen: back button key `badges-back` (64 dp, goes home), title "My badges", count "N of 20" key `badge-count`; a `GridView` with `SliverGridDelegateWithMaxCrossAxisExtent` (max extent 220) of 20 tiles key `badge-<id>`; earned: coloured icon, name, "Earned 15 Nov" (`d MMM`); unearned: silhouette, name, hint, semantic label "<name>, not earned yet". Scrolls on small screens (NFR-09).
- **SCR-02** (`home_screen.dart`): a badge button key `badges-button` beside `minutes-left` (64 dp tall): with badges it shows the latest badge's small icon and name ("Latest: Perfect 10"), without "My badges"; both open `/badges`.

## Acceptance criteria

- **AC-1** (BDG-01 rules): `badges_test.dart` with an injected clock: each of the 20 rules has a just-below and a just-at test (e.g. 99 vs 100 attempts, 2 vs 3 consecutive days incl. a month boundary and a gap, 26 vs 27 of the last 30 with older wrong answers ignored, 29 attempts not enough, 119.9 s vs 120 s for Speedy, 18 vs 19 School topics, 22 vs 23 topics at 3 stars); empty facts give no badges; quit-round attempts count, quit rounds don't; ids are unique and the list has 20.
- **AC-2** (BDG-01 recording): `badge_repository_test.dart` on an in-memory DB: `awardNew` inserts new badges once with `earned_at` = clock, returns them in table order, returns [] on a second call with no new facts, keeps the original `earned_at` later; after `resetProgress` the shelf is empty and badges can be earned again.
- **AC-3** (BDG-02): widget test: finishing a first round 10/10 shows `new-badges` with `new-badge-first-round` and `new-badge-perfect-10` on SCR-05; a following round that earns nothing shows no `new-badges`; a repository that throws still shows SCR-05 with score and stars; `see-badges` opens SCR-06.
- **AC-4** (BDG-03): widget test: SCR-06 with 2 seeded badges shows `badge-count` "2 of 20", the earned tiles with their names and dates, and the other 18 with their hints; `badges-back` goes home.
- **AC-5** (SCR-02, TIM-01): home shows "My badges" with none and "Latest: <name>" after one is earned; `badges-button` opens SCR-06; `/badges` redirects to `/locked` when time is up (`redirectFor` test).
- **AC-6** (NFR-03, NFR-09): SCR-06 and SCR-05 with three new badges at the six FEAT-04 sizes and text scale 1.3 pass `test/ui/layout_checks.dart` (child screens: 64 dp taps, 20 sp text, no overflow). Existing tests pass unchanged.

## Tasks

- [x] T1 — `lib/domain/badges.dart` (badge list, `evaluateBadges`, `mastered`, `longestStreak`).
      Done when: AC-1 passes: `scripts/check.sh 'flutter test test/domain/badges_test.dart'`.
- [ ] T2 — `BadgeRepository`, providers; open the draft PR so CI runs.
      Done when: AC-2 passes with `flutter test test/data/badge_repository_test.dart`.
- [ ] T3 — Quiz controller hook, `RoundSummary.newBadges`, SCR-05 celebration, `badge_icons.dart`, theme sizes.
      Done when: AC-3 tests pass with `flutter test test/features/quiz`.
- [ ] T4 — SCR-06 shelf and `/badges` route (counts as screen time); SCR-02 badge button.
      Done when: AC-4 and AC-5 pass with `flutter test test/features/badges test/features/topics test/features/screen_time` (home tests go in `test/features/badges` if none exist).
- [ ] T5 — AC-6 layout checks; BDG-01..03 Feature cells; design §9 build row if anything deviated; full `scripts/check.sh`; draft PR ready for verify.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
