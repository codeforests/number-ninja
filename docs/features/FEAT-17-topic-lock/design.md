# FEAT-17: School topic lock

> Implements: PRC-12..14 (D17) · Screens: SCR-03 (padlocks), SCR-04 (guard), SCR-09 (padlock mark), SCR-10 (parent opens a topic)
> Status: designed · Branch: `feat/FEAT-17-topic-lock` · 2026-11-16

## Scope

School topics open in the design §2 order: within a year, a topic opens when the one before it is passed (a finished round with 7+ of 10 right, any level); the first topic of a year opens when every topic of the year before is passed (PRC-12). Years below her profile year are open; passed, played and parent-opened topics stay open (PRC-13). A locked tile shows a padlock and the topic to pass first, and doesn't start a round; the parent can open any topic from SCR-10 (PRC-14). Olympiad topics are never locked.

Not in scope: syncing parent-opened topics (FEAT-14 maps the table to `children.unlocked_topics`, `04-architecture.md`); revision rounds (FEAT-11 decides whether they count as a pass; this design counts every finished round of the topic, as only normal rounds exist).

## Design decisions (this feature)

- **Derived, not stored.** Like levels (§5), lock state is worked out from finished rounds, the profile and the parent's openings each time; only the parent's openings are stored. So changing the profile year re-derives the map at once.
- **Pass** = a finished round of the topic with `score >= 7` (`passScore`), at any level. A quit round never counts. Mix-in questions count in the score, as they do for stars.
- **A topic she has finished any round of stays open**, even below 7. Reason: v1 installs already played topics out of order, and a profile year lowered later must not take away a topic she was playing. This is wider than PRC-13's "passed" and keeps its intent (nothing she reached closes again).
- **Her year.** The first topic of year Y is open when Y ≤ her school year, or every topic of year Y − 1 is passed. No profile (updated install, PRO-02) counts as P1. School year P3+ opens all of P1 and P2.
- **Which topic to pass first** (PRC-14): within a year, the topic just before it; for the first topic of a year, the first not-yet-passed topic of the year before. The tile says "Pass <name> first".
- **Parent opening** lives on SCR-10 (reachable for every topic from SCR-09, already behind the PIN): a card "Topic lock" with the state and one button, "Open for her" when locked, "Lock again" when open only because the parent opened it. Topics open by the rules show the reason and no button. The parent can't lock a topic she has passed or played. SCR-09 topic rows show a small padlock icon for locked topics so the parent sees which.
- **Table `topic_unlocks`** (schema v5): `topic_id` text primary key, `opened_at`. Kept by the PAR-10 reset (a setting, like the profile); a reset clears rounds, so passed topics close again.
- **Guard.** The router doesn't watch providers (code-map gotcha), so `/quiz/:id` for a locked topic is stopped in `QuizController.start`: it sets `RoundState.locked` without starting a round, and SCR-04 then goes to `/play/school`. A tile tap on a locked topic doesn't navigate at all.

## Design

- **Domain** (`lib/domain/topic_lock.dart`): `const passScore = 7`; `sealed class TopicLock` with `TopicOpen(OpenReason reason)` (`olympiad`, `first`, `belowYear`, `previousPassed`, `passed`, `played`, `parent`) and `TopicLocked(String passFirstId)`; `Map<String, TopicLock> topicLocks({required List<Topic> topics, required List<FinishedRound> rounds, int? schoolYear, Set<String> opened = const {}})`, walking `topics` in list order per year. `FinishedRound` gains `score` (from `rounds.score`).
- **Data**: `database.dart` schema 5, table `TopicUnlocks` (`topic_unlocks`), migration `from < 5` creates it. `lib/data/topic_lock_repository.dart`: `TopicLockRepository(AppDatabase db, {required Clock clock})` with `Future<Set<String>> opened()`, `Future<void> open(String id)` (insert or ignore, stamped `clock()`), `Future<void> close(String id)`. Providers in `providers.dart`: `topicLockRepositoryProvider`, `topicLocksProvider` (FutureProvider.autoDispose combining `finishedRounds()`, the profile and `opened()`; invalidated by SCR-10 after a change, and by the same places that invalidate `topicProgressProvider`).
- **SCR-03** (`topic_map_screen.dart`): `_TopicTile` takes a `TopicLock`. Locked: muted card, `Icons.lock` key `topic-<id>-lock` in place of the topic icon, stars row replaced by "Pass <name> first" key `topic-<id>-hint` (ellipsized, 2 lines), `onTap` null, semantics "Locked". Same tile height. While the provider loads, tiles show as now (no padlocks), and the guard covers a fast tap.
- **SCR-04** (`quiz_controller.dart`, `quiz_screen.dart`): `RoundState.locked`; `start` reads `topicLocksProvider.future` first and returns early when locked; the screen `context.go(Routes.play(TrackSlug.school))` in a post-frame callback.
- **SCR-10** (`topic_detail_screen.dart`): for School topics a `StatsCard` "Topic lock" at the top, key `lock-card`, text key `lock-state` ("Locked: pass Money first" / "Open: passed" / "Open: her school year is above P1" / "Open: opened by you" …), button key `lock-open` or `lock-close`.
- **SCR-09** (`dashboard_screen.dart`): topic rows show `Icons.lock` key `topic-row-<id>-lock` when locked.
- **Theme**: any new colour (locked card fill, padlock) goes in `theme.dart` (`AppColors.locked`, `lockedText`).

## Acceptance criteria

- **AC-1** (PRC-12, PRC-13 rules): `test/domain/topic_lock_test.dart`: no rounds, no profile → only `p1.place` and every `oly.*` open, `p1.bonds` locked with pass-first `p1.place`, `p2.place` locked with pass-first `p1.place`; a 7/10 `p1.place` round opens `p1.bonds`, a 6/10 one doesn't (but `p1.place` stays open, reason `played`); every P1 topic passed opens `p2.place` only; profile P2 → all P1 open (`belowYear`), `p2.place` open (`first`), `p2.regroup` locked; profile P3 → all P1 and P2 open; a played-but-not-passed `p1.money` stays open and doesn't open `p1.time`; `opened` opens any topic (`parent`) without opening the next one; with all P1 but `p1.graphs` passed, `p2.place`'s pass-first is `p1.graphs`.
- **AC-2** (storage): `test/data/topic_lock_repository_test.dart`: `open` is stored with `opened_at` = clock and is idempotent, `close` removes it, `resetProgress` keeps it; `finishedRounds` returns `score`. `migration_test.dart`: v4 → v5 keeps data and adds an empty `topic_unlocks`.
- **AC-3** (PRC-14 child side): widget tests: a fresh profile-less app shows `topic-p1-bonds-lock` and hint "Pass Numbers to 100 first", tapping it stays on SCR-03; after a seeded 7/10 `p1.place` round the lock is gone; going to `/quiz/p1.bonds` while locked saves no round and lands on `/play/school`; Olympiad tiles never show a padlock.
- **AC-4** (PRC-14 parent side): SCR-10 for locked `p1.money` shows `lock-state` "Locked: pass …" and `lock-open`; tapping it stores the opening, the state becomes "Open: opened by you" with `lock-close`, and SCR-03 shows `p1.money` open; `lock-close` locks it again; a passed topic shows no button; SCR-09 shows `topic-row-p1.money-lock` only while locked.
- **AC-5** (NFR-03, NFR-09): SCR-03 with locked tiles and SCR-10 with the lock card pass the six FEAT-04 sizes at text scale 1.3 (`layout_checks.dart`; child rules for SCR-03, parent rules for SCR-10). Existing tests pass unchanged, except test setups that now need a profile or rounds to reach a topic past the first (they seed them; no assertion changes).

## Tasks

- [ ] T1 — `lib/domain/topic_lock.dart`, `FinishedRound.score`.
      Done when: AC-1 passes: `scripts/check.sh 'flutter test test/domain'`.
- [ ] T2 — Schema v5, `TopicLockRepository`, `finishedRounds` score, providers.
      Done when: AC-2 passes: `flutter test test/data`.
- [ ] T3 — SCR-03 padlock tiles, quiz guard.
      Done when: AC-3 passes: `flutter test test/features/topics test/features/quiz`.
- [ ] T4 — SCR-10 lock card, SCR-09 padlock mark.
      Done when: AC-4 passes: `flutter test test/features/parent`.
- [ ] T5 — AC-5 layout checks; PRC-12..14 Feature cells; design §4/§5/§9 rows; code-map lines; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
