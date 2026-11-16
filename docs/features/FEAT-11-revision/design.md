# FEAT-11: Revision module

> Implements: REV-01..06 (D12, ADR-06) · Screens: SCR-14 (new: revision start), SCR-04/SCR-05 (revision mode), SCR-02 (home entry), SCR-05 (topic entry), SCR-10 (weak types)
> Status: built · Branch: `feat/FEAT-11-revision` · 2026-11-16

## Scope

Rule-based weak-spot analysis and revision rounds, fully offline. The app works out her weak question types (REV-01) and recent mistakes (REV-02); SCR-05 offers a revision round for the topic just played and SCR-02 offers a mixed one across all topics (REV-03); the round is built from mistakes and weak types and played on the normal SCR-04/SCR-05 with the normal feedback, timing, screen time, stats and badges, but never changes a topic's level, best stars or lock (REV-04); SCR-10 lists the topic's weak types (REV-05). All analysis and building sit behind `RevisionPlanner` in `lib/domain` (REV-06, ADR-06).

Not in scope: syncing `rounds.kind` (FEAT-14 maps it to the server's `kind` field, `04-architecture.md`); an AI planner (later phase, D12); a parent switch to turn revision off.

## Design decisions (this feature)

- **Question type** = the question id without its `.nnn` suffix, i.e. `<topic>.<template>` (`p1.place.tens`); the bank validator already enforces that id shape. About 12 questions per type in `bank_v1` (min 10), spread over levels 1–3.
- **Window.** The planner looks at attempts answered in the last 30 days (same window as the mix-in, design §5), from rounds of any kind, quit rounds included.
- **Weak type (REV-01).** Per type, take its latest 10 attempts in the window. Weak when it has at least 5 of them and accuracy is below 70 %, or its average time (capped at `timeCap`, as in stats) is more than 1.5× the average of all the topic's attempts in the window. Order: lowest accuracy first, then slowest, then type id. Constants: `weakMinAttempts = 5`, `weakLatest = 10`, `weakBelow = 0.7`, `slowFactor = 1.5`. These are defaults Ken can tune later; they change no data.
- **Recent mistake (REV-02).** A question whose latest attempt in the window is wrong ("wrong recently and not right since"). Answering it right in any round (revision or normal) takes it off the list. Newest first.
- **Building a round.** Up to 10 questions, no repeats, in this order: (1) up to 5 recent mistakes, newest first, the exact questions at any level; (2) questions of the weak types, weakest first, taken round-robin one per type, at the topic's current level with the nearest-level fill of `buildRound` and preferring questions not answered right in the last 7 days; (3) if still short, other questions of the mistakes' types, same preference. Then shuffled with the injected `Random`. Mixed scope: the same over every topic (both tracks); topic scope: that topic only.
- **When it is offered (REV-03).** Topic scope: the topic has at least one weak type or one recent mistake. Mixed (home): at least one weak type, or at least 3 recent mistakes, in total. A plan that comes out empty is never offered.
- **Kind on `rounds`** (schema v6): `kind` text, `normal` (default, also for existing rows) or `revision`. Topic scope stores the topic id and its current level; mixed scope stores `topic_id = 'mixed'` (`mixedScopeId`) and level 1.
- **What a revision round counts for (REV-04).** Attempts are saved as usual, so stats (PAR-05..08), the mix-in, the PDF and the attempt-based badges include them; play time counts as screen time (its routes are in `Routes.counts`). `finishedRounds()` returns normal rounds only, so levels (PRC-09), best stars (PRC-07) and the topic lock (PRC-12, the open question in FEAT-17's handoff) ignore revision rounds: a revision round is never a pass. Badges: round rules (First Round, Perfect 10, Speedy, streaks) count revision rounds; topic-map rules (School Explorer, Ninja Master) use normal rounds only, since they mirror the map's stars.
- **Locks.** Mistakes and weak types come only from topics she has answered, which FEAT-17 keeps open, so the planner doesn't filter by lock. `QuizController` skips the lock guard for revision.
- **Weak types on SCR-10 (REV-05)** use the planner's fixed 30-day window (the dashboard's 7/30/all choice doesn't apply; the card says "Last 30 days"). Each row: a label from the template slug (`tens-ones` → "Tens ones"), accuracy and average seconds of its latest 10, and one example prompt (the latest attempted question of the type), ellipsized to 2 lines. "No weak types" when empty.

## Design

- **Domain** (`lib/domain/revision.dart`, pure Dart):
  - `String typeOf(String questionId)`, `String typeLabel(String typeId)`, `const mixedScopeId = 'mixed'`.
  - `sealed class RevisionScope` with `TopicScope(String topicId)` and `MixedScope()`; `String get id` (topic id or `mixed`).
  - `class RevisionHistory({required List<AttemptRecord> attempts, required Map<String,int> levels, required Set<String> recentCorrect})` (attempts already cut to the window; `levels` = current level per topic; `recentCorrect` = ids right in the last 7 days).
  - `class WeakType({typeId, topicId, Tally tally, bool slow})`; `class RevisionPlan({scope, List<Question> questions, List<String> mistakeIds, List<WeakType> weakTypes})` with `isEmpty`.
  - `abstract interface class RevisionPlanner { List<WeakType> weakTypes(RevisionHistory h, {String? topicId}); List<String> mistakes(RevisionHistory h, {String? topicId}); bool offers(RevisionHistory h, RevisionScope s); RevisionPlan plan(RevisionHistory h, QuestionBank bank, RevisionScope s, Random random); }`
  - `class RuleRevisionPlanner implements RevisionPlanner` with the rules above; constants as top-level `const`s.
- **Data:** `database.dart` schema 6, `Rounds.kind` (text, default `'normal'`), migration `from < 6` adds the column. `RoundRepository.startRound(topicId, level, {String kind = 'normal'})`; `finishedRounds` filters `kind = 'normal'`. `BadgeRound` gains `kind`; `badge_repository.dart` fills it. `lib/data/revision_repository.dart`: `RevisionRepository(StatsRepository stats, RoundRepository rounds, {required Clock clock})` with `Future<RevisionHistory> history()`. Providers in `providers.dart`: `revisionPlannerProvider` (`RuleRevisionPlanner`, tests can override), `revisionRepositoryProvider`, `revisionHistoryProvider` (FutureProvider.autoDispose, invalidated wherever `topicProgressProvider` is). While there, fix the `topicLocksProvider` doc comment (says SCR-10, means SCR-15).
- **Routes** (`app.dart`): `Routes.revise(scopeId)` = `/revise/<scopeId>` (SCR-14) and `Routes.reviseQuiz(scopeId)` = `/revise/<scopeId>/quiz` (SCR-04 in revision mode); `Routes.counts` adds `/revise/`. code-map line.
- **SCR-14** (`lib/features/revision/revision_start_screen.dart`, `RevisionStartScreen(scopeId)`): child screen in `KidBackground`, back key `back-home` (to SCR-02 for mixed, SCR-03 of the topic's track otherwise). Title key `revise-title`: the topic name, or "Mixed revision". Key `revise-mistakes`: "N questions to try again" (hidden at 0); key `revise-types`: "Tricky kinds: <label>, <label>…" (up to 3 labels, then "and N more"). Go button key `revise-go` → `Routes.reviseQuiz`. Nothing to revise (stale link) → text "Nothing to revise right now" and a Home button, no Go.
- **SCR-04/SCR-05:** `QuizScreen({required String topicId, bool revision = false})`; `QuizController.startRevision(String scopeId)` builds the plan from `revisionHistoryProvider` and `bankProvider`, calls `startRound(scopeId, level, kind: 'revision')`, and from there the round runs as now. An empty plan sets `RoundState.empty` and the screen goes to `/`. The quiz header shows "Revision" instead of the topic name for mixed (and "Revision: <topic>" for a topic). `RoundSummary` gains `bool revision`; SCR-05 hides `level-up` and `play-again` for a revision round.
- **Entries:** SCR-05 after a normal round of a topic the planner `offers` for: a button key `revise-topic` "Practise tricky ones" → `Routes.revise(topicId)`. SCR-02: when `offers(MixedScope)`, a card key `home-revise` "Revision: practise your tricky ones" under the track cards → `Routes.revise('mixed')`; absent otherwise (no empty state).
- **SCR-10** (`topic_detail_screen.dart`): a `StatsCard` key `weak-types` after `topic-tally`, rows key `weak-<typeId>` with label, "x/y right · z s" and the example prompt; text "No weak types" when empty.
- **Theme:** any new colour (revision card) goes in `theme.dart` (`AppColors.revision`).

## Acceptance criteria

- **AC-1** (REV-01, REV-02, REV-06): `test/domain/revision_test.dart`: `typeOf('p1.place.tens.004') == 'p1.place.tens'`, `typeLabel`; a type with 5 of its latest 10 right is weak, 7/10 is not, 4 attempts at 0 % is not (too few); older attempts beyond the latest 10 don't count; a type 1.6× slower than its topic average at 90 % is weak (`slow`), 1.4× is not; order lowest accuracy first; mistakes = latest attempt wrong, a later right answer removes it, newest first; `offers`: topic with one mistake → true, mixed with 2 mistakes and no weak type → false, with 3 → true; `plan` (fixed `Random`): ≤ 5 mistakes first, then weak-type questions round-robin at the topic's level with nearest-level fill, preferring not `recentCorrect`, then siblings of mistakes, ≤ 10, no repeats; topic scope never contains another topic's question; empty history → empty plan.
- **AC-2** (storage, REV-04): `round_repository_test.dart`/`migration_test.dart`: v5 → v6 keeps data and existing rounds read `kind = 'normal'`; `startRound(kind: 'revision')` stores it; `finishedRounds`, `levelFor`, `progress` and `topicLocks` ignore a finished 3-star or 7/10 revision round; `badges_test.dart`: a revision round earns First Round and Perfect 10 but doesn't count towards School Explorer or Ninja Master; `revision_repository_test.dart`: `history()` cuts attempts to 30 days by the clock and fills `levels` and `recentCorrect` (7 days).
- **AC-3** (REV-04 round): widget tests with `QuizHarness`: `/revise/<topic>` shows the title, mistake count and tricky kinds; `revise-go` plays a round whose questions are the planner's, saves a `rounds` row with `kind = 'revision'` and its attempts, SCR-05 shows score and stars but no `level-up` or `play-again`, and the topic's level on SCR-03 is unchanged; screen time counts on `/revise/` routes (`Routes.counts`); `/revise/mixed` with nothing to revise shows "Nothing to revise right now" and no `revise-go`.
- **AC-4** (REV-03 entries): after a normal round with a wrong answer, SCR-05 shows `revise-topic` and it opens SCR-14 for that topic; after a 10/10 round with no history it doesn't; SCR-02 shows `home-revise` with 3 seeded mistakes and not with 2; tapping it opens `/revise/mixed`.
- **AC-5** (REV-05): SCR-10 for a topic with a seeded weak type shows `weak-types` with its `weak-<typeId>` row (label, "x/y right", example prompt); a topic without shows "No weak types".
- **AC-6** (NFR-03, NFR-09): SCR-14, SCR-02 with `home-revise`, SCR-05 with `revise-topic` and SCR-10 with weak types pass the six FEAT-04 sizes at text scale 1.3 (`layout_checks.dart`). Existing tests pass with no assertion changes (`QuizHarness` gets no revision history unless a test seeds attempts).

## Tasks

- [x] T1 — `lib/domain/revision.dart` (`RevisionPlanner`, `RuleRevisionPlanner`, scope, plan, weak types, mistakes).
      Done when: AC-1 passes: `scripts/check.sh 'flutter test test/domain'`.
- [x] T2 — Schema v6 `rounds.kind`, `startRound(kind)`, `finishedRounds` normal only, `BadgeRound.kind` and the two topic badge rules, `RevisionRepository`, providers, `topicLocksProvider` comment.
      Done when: AC-2 passes: `flutter test test/data test/domain`.
- [x] T3 — Routes, SCR-14, `QuizController.startRevision`, revision mode on SCR-04/SCR-05.
      Done when: AC-3 passes: `flutter test test/features/revision test/features/quiz`.
- [x] T4 — Entries on SCR-05 (`revise-topic`) and SCR-02 (`home-revise`).
      Done when: AC-4 passes: `flutter test test/features/home test/features/quiz test/features/revision`.
- [x] T5 — SCR-10 weak types card.
      Done when: AC-5 passes: `flutter test test/features/parent`.
- [x] T6 — AC-6 layout checks; REV-01..06 Feature cells; design §4 (`rounds.kind`), §5 (revision rule), §6 (SCR-14 row), §9 rows; code-map lines; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
