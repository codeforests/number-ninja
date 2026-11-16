# FEAT-11: Verify

> Verified 2026-11-16 in a fresh thread that did not write the code · Commit under test: `390b66d` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone at `390b66d`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (schema v6) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 845 tests (846 with the one added here) |
| CI on the final head | see the PR checks (release APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `test/domain/revision_test.dart`: `typeOf`/`typeLabel`; 5/10 weak, 7/10 not, 4 at 0 % too few; only the latest 10 count; 1.6× slower at 90 % weak (`slow`), 1.4× not; lowest accuracy first, `topicId` filter; mistakes = latest wrong, later right removes, newest first; `offers` topic with 1 mistake, mixed 2 → false, 3 → true; `plan`: 5 newest mistakes then weak types round-robin (3 of the weaker, 2 of the other) at the topic's level 2, prefers not `recentCorrect`, mistake siblings fill, 10 with no repeats, topic scope stays in its topic, mixed spans, empty history → empty. | pass |
| AC-2 | `migration_test.dart` v5→v6 keeps data, old round reads `kind = 'normal'`, `user_version` 6. `round_repository_test.dart`: kind stored; a finished 3-star revision round leaves `finishedRounds`/`progress` empty, `levelFor` 1, `p1.bonds` locked; a normal 7/10 then opens it. `badges_test.dart`: revision rounds earn First Round, Perfect 10, Speedy, not School Explorer/Ninja Master. `revision_repository_test.dart`: 30-day cut by the clock, `levels`, 7-day `recentCorrect`. | pass |
| AC-3 | `test/features/revision/revision_test.dart`: SCR-14 title, "5 questions to try again", "Tricky kinds: T"; Go plays 10 questions of the topic containing the 5 mistakes, header "Revision: <topic>"; SCR-05 shows score and stars, no `level-up`/`play-again`; one `rounds` row kind `revision`, 15 attempts, `levelFor` stays 1 and `progress()` empty (what SCR-03 reads). Mixed: "Revision", row `topic_id = 'mixed'`, level 1. Nothing to revise → `revise-nothing`, no Go; stale quiz link saves no round; `/revise/` in `Routes.counts`. | pass |
| AC-4 | `entries_test.dart`: one wrong answer → `revise-topic` → SCR-14 "1 question to try again"; 10/10 fresh → none; 2 seeded mistakes → no `home-revise`; 3 → `home-revise` opens "Mixed revision". | pass |
| AC-5 | `weak_types_test.dart`: 2/6 topic shows `weak-<topic>.t` "T: 2/6 right · 5.0 s", the example prompt and "Last 30 days"; a clean topic shows "No weak types". | pass |
| AC-6 | `revision_layout_test.dart` (SCR-14 both scopes, SCR-02 with `home-revise`, SCR-05 with `revise-topic`, six sizes at 1.3, tap targets and text sizes) and `parent_layout_test.dart` (SCR-10 with the weak card, no overlap). Older tests unchanged apart from `user_version` 5 → 6. | pass |

## Beyond the tests

- **Added test:** `entries_test.dart` "a revision round that fixes the mistakes removes home-revise": 3 mistakes, home card → SCR-14 → 10/10 revision round → no `revise-topic` on SCR-05 → home shows no `home-revise`. End to end proof of REV-02's "right since" removal. (It still passes with the quiz's `ref.invalidate(revisionHistoryProvider)` removed, since the autoDispose history is disposed while SCR-02 is off screen; the invalidate is harmless belt and braces.)
- **Code read:** `RuleRevisionPlanner` matches the design's rules and order; the round-robin loop ends when every queue is empty; attempts get their topic from the bank question, not the round row, so mixed-round attempts land in the right topic's stats and weak types. `QuizController.startRevision` skips the lock guard and saves no row for an empty plan.
- **Nit (not blocking):** `offers` doesn't check that the plan is non-empty, so a mistake whose question left the bank (possible once FEAT-15 updates the bank) could show an entry that leads to "Nothing to revise right now". Handled gracefully; worth a look in FEAT-15.
- Look of SCR-14 and the home card with real fonts is Ken's check on the tablet at M5.

## Test diff review

Six new test files. Existing files changed: `migration_test.dart` (`user_version` 5 → 6 in four cases, plus the v5→v6 case), `round_repository_test.dart`, `badges_test.dart` and `parent_layout_test.dart` (additions only), `quiz_harness.dart` (`startRound` passes `kind` through). Nothing removed, no `skip:`, no assertion loosened.
