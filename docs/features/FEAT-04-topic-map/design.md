# FEAT-04: Home, topic map and difficulty steps

> Implements: PRC-01, PRC-07, PRC-09, NFR-09 · Screens: SCR-02, SCR-03, SCR-04 (layout), SCR-05 (level up)
> Status: designed · Branch: `feat/FEAT-04-topic-map` · 2026-11-15

## Scope

She picks a track on home (SCR-02), then a topic on a real topic map (SCR-03) that shows her best stars and level per topic. Each topic's level steps up after a 3-star round and down after a 0–1-star round (PRC-09), and the result screen says "Level up!". From Ken's M1 check (D9): every child screen fits smaller screens without overlapping (NFR-09); the quiz screen's answer area no longer covers the question.

Not in scope: minutes left on home (TIM-06, FEAT-05), latest badge on home (FEAT-08), needs-practice mix-in (FEAT-06), kid-friendly backgrounds and sounds (NFR-10, PRC-11, FEAT-09). She can't pick a level herself.

## Design

- **Domain** (`lib/domain/progress.dart`, pure Dart):
  - `nextLevel(int level, int stars)`: 3 stars → +1, 0–1 → −1, 2 → same, clamped to 1–3 (design §5).
  - `FinishedRound {topicId, level, stars, startedAt, id}` and `TopicProgress {bestStars, level, rounds}` (`TopicProgress.none` = 0 stars, level 1, 0 rounds).
  - `progressByTopic(Iterable<FinishedRound>)` → `Map<String, TopicProgress>`: per topic, best stars = max stars; level = `nextLevel` of the latest round (by `startedAt`, then `id`). Topics with no rounds are absent (callers use `TopicProgress.none`).
- **Data:**
  - `rounds.finished_at` (nullable `DateTime`), `schemaVersion` 2. Migration `from1To2`: add the column, then backfill `finished_at` = latest `answered_at` of the round's attempts for rounds with 10 or more attempts (Ken's M1 rounds; earlier rounds were always 10 questions). Migration test: build a v1 database with the v1 `CREATE TABLE` statements and `PRAGMA user_version = 1` in `NativeDatabase.memory(setup:)`, insert a finished and a quit round, open `AppDatabase` on it, check the column and the backfill.
  - `RoundRepository.finishRound` also writes `finished_at = clock()`.
  - `RoundRepository.finishedRounds({String? topicId})` → `List<FinishedRound>` (only `finished_at` not null). `progress()` → `progressByTopic(await finishedRounds())`; `levelFor(topicId)` → that topic's level or 1. `recentCorrectIds` is unchanged.
  - `topicProgressProvider` (`FutureProvider.autoDispose<Map<String, TopicProgress>>`) in `lib/providers.dart`, so the map re-reads after every round.
- **Flow** (`quiz_controller.dart`): remove `playLevel`. `start` reads `levelFor(topicId)` and builds and starts the round at that level. `RoundSummary` gains `level` (played) and `nextLevel` (`nextLevel(level, stars)`); `levelUp` = `nextLevel > level`.
- **SCR-05:** when `levelUp`, a banner under the stars: "Level up! Now level N" (`AppColors.sun`, key `level-up`). A step down shows nothing (don't discourage). Play again uses the new level automatically.
- **SCR-02 home** (`home_screen.dart`): unchanged content; cards sit side by side in landscape and stack in portrait (`width < height`); each card shows the stars earned on that track out of the maximum, e.g. "12 / 57 ★" (key `track-stars-<track>`), from `topicProgressProvider`.
- **SCR-03 topic map** (`lib/features/topics/topic_map_screen.dart`, route `/play/:track` kept; delete `lib/features/quiz/topic_list_screen.dart`): back button and track title; School shows two sections "P1" and "P2", Olympiad one. Each section is a responsive grid (`SliverGrid` with `maxCrossAxisExtent` 300, tiles at least `AppSizes.minTap * 2` tall) inside one `CustomScrollView`. A tile (key `topic-<id>`): a topic icon, the short name (`topics.dart`; rename `p2.regroup` to "Add and subtract" so every name is at most 4 words; ids don't change), three stars (key `topic-<id>-star-<i>`, `Icons.star` filled up to best stars, `Icons.star_border` after) and "Level N" (≥ `AppText.small`). Icons come from one map `topicIcons` in `lib/features/topics/topic_icons.dart` (Material icons), with a test that every topic id has one. Tapping a tile opens `/quiz/<id>`.
- **Responsive layout (NFR-09)**, `lib/ui/layout.dart`: `bool sideBySide(Size s) => s.width > s.height && s.width >= 600` (replaces `QuizScreen.wideLayout`). SCR-04:
  - Side by side: left and right halves are each their own `SingleChildScrollView`; the left holds the prompt then the visual in a box of height `max(160, free height)` (free = half's height minus prompt), so a long prompt pushes the visual down and the half scrolls instead of overflowing. The right is the answer area (or feedback panel), centred when it fits.
  - Stacked: the whole body is one `SingleChildScrollView`: prompt, visual box (height = clamp(0.35 × screen height, 160, 400)), answer area. Nothing is `Expanded` against unbounded height.
  - Keys for the layout tests: `prompt` (exists), `visual-box`, `answer-area` (wraps the answer widget or the feedback panel).
  - On 1280 × 800 dp (landscape tablet) nothing scrolls during a question (NFR-02 still holds).
- **Layout test helper** (`test/ui/layout_checks.dart`): `expectNoOverlap(tester, keys)` checks the global rects of the keyed widgets don't intersect pairwise and each lies within the screen's width; plus `tester.takeException()` is null (catches RenderFlex overflow). Sizes in dp: 640 × 360, 360 × 640, 960 × 600, 600 × 960, 1280 × 800, 800 × 1280; and 1280 × 800 at text scale 1.3. For the no-scroll check at 1280 × 800, load Roboto from `~/sdk/flutter/bin/cache/artifacts/material_fonts` (or the `FLUTTER_ROOT` equivalent) with `FontLoader` so text has real widths (Ahem is wider), and skip only that check with a printed reason if the font file is missing.

## Acceptance criteria

- **AC-1** (PRC-09): `nextLevel` unit-tested for every stars value at levels 1, 2, 3 (clamped); `progressByTopic` takes the latest round by `startedAt` and best stars over all levels.
- **AC-2** (PRC-09): a quit round (no `finished_at`) changes neither level nor best stars (Drift test); the v1→v2 migration test passes with the backfill.
- **AC-3** (PRC-09): widget test: a 3-star round of a topic at level 1 shows "Level up! Now level 2" and Play again starts a round whose `rounds.level` is 2 and whose questions are level 2; a 0-star round at level 2 shows no banner and the next round is level 1.
- **AC-4** (PRC-01): home → School shows P1 and P2 sections with all 19 School topics; home → Olympiad shows the 4 `oly.*` topics; tapping a tile starts a round of that topic; back returns home. Every tile has an icon and a label of at most 4 words.
- **AC-5** (PRC-07): after finished rounds with 2 and then 1 stars in a topic, its tile shows 2 filled stars and the level from the latest round; a topic never played shows 0 stars and "Level 1"; the home card's star total matches.
- **AC-6** (NFR-09): SCR-02, SCR-03, SCR-04 (longest-prompt question of each format, answering and feedback phases) and SCR-05 at the six sizes and the text-scale case: no exception, and on SCR-04 `prompt`, `visual-box` and `answer-area` don't overlap. Every tappable on SCR-02 and SCR-03 is ≥ 64 × 64 dp and every text ≥ 20 sp (NFR-03).
- **AC-7** (NFR-02): at 1280 × 800 dp with Roboto, the longest-prompt question of every template shows on SCR-04 with no scrollable having scroll extent (nothing scrolls). The existing AC-6/AC-7 layout tests of FEAT-03 still pass unchanged.

## Tasks

- [ ] T1 — Domain: `progress.dart` (`nextLevel`, `FinishedRound`, `TopicProgress`, `progressByTopic`).
      Done when: `scripts/check.sh 'flutter test test/domain'` passes with the AC-1 tests.
- [ ] T2 — Data: `rounds.finished_at`, schema v2 with migration and backfill, `finishRound` stamps it, `finishedRounds`, `progress`, `levelFor`, `topicProgressProvider`; `dart run build_runner build`.
      Done when: the AC-2 Drift and migration tests and the existing `test/data` tests pass.
- [ ] T3 — Controller plays at `levelFor`; `RoundSummary.level/nextLevel`; SCR-05 level-up banner; remove `playLevel`.
      Done when: the AC-3 widget tests and the existing `test/features/quiz` tests pass.
- [ ] T4 — SCR-03 topic map with sections, icons, stars, level; SCR-02 track star totals and portrait stacking; delete the placeholder list.
      Done when: AC-4 and AC-5 widget tests pass and `flutter test test/features` passes.
- [ ] T5 — Responsive SCR-04 (`lib/ui/layout.dart`, scrolling halves, stacked scroll, layout keys) and the `layout_checks.dart` helper.
      Done when: the SCR-04 part of AC-6 passes at all six sizes and the FEAT-03 layout tests still pass.
- [ ] T6 — AC-6 for SCR-02, SCR-03, SCR-05 and the NFR-03 sizes; AC-7 no-scroll test with Roboto; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
