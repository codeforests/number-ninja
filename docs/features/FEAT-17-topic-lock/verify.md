# FEAT-17: Verify

> Verified 2026-11-16 in a fresh thread that did not write the code · Commit under test: `07cf47e` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone at `07cf47e`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (schema v5) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 777 tests (776 + 1 added here) |
| CI on the final head | see the PR checks (release APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `test/domain/topic_lock_test.dart`: fresh → only `p1.place` (`first`) and every `oly.*` open, `p1.bonds`/`p2.place` locked behind `p1.place`; 7 passes and opens the next, 6 leaves `p1.place` open as `played` and `p1.bonds` locked; all P1 passed opens `p2.place` only; profile P2 → P1 `belowYear`, `p2.place` `first`, `p2.regroup` locked; P3 opens P1+P2; played `p1.money` doesn't open `p1.time`; parent opening opens one topic only; pass-first for `p2.place` is `p1.graphs`. | pass |
| AC-2 | `topic_lock_repository_test.dart`: `opened_at` = clock, idempotent, `close` removes, `resetProgress` keeps; `finishedRounds` carries `score`. `migration_test.dart` v4→v5 keeps data, empty `topic_unlocks`. | pass |
| AC-3 | `topic_lock_map_test.dart`: fresh app shows `topic-p1.bonds-lock`, hint "Pass Numbers to 100 first", tap stays on SCR-03 with no round; seeded 7/10 removes the lock; `/quiz/p1.bonds` saves no round and lands on `/play/school`; Olympiad never locked. | pass |
| AC-4 | `topic_locks_test.dart`: SCR-11 `open-topic-locks` → SCR-15 and back; `p1.money` "Locked: pass Equal groups first" → open → "Open: opened by you", stored, `p1.time` still locked; lock-close removes it; SCR-03 shows `p1.money` open; passed `p1.place` and following `p1.bonds` show no button. | pass |
| AC-5 | `child_screens_layout_test.dart` (SCR-03 with locks) and `parent_layout_test.dart` (SCR-15) at the six sizes, scale 1.3. Older tests pass with `QuizHarness.lockTopics` false. | pass |

## Beyond the tests

- **Added test:** `topic_lock_map_test.dart` "a pass while the app runs opens the topic on return": the map locks, a 7/10 round is recorded, going back to SCR-03 shows the next topic open. Confirms the autoDispose provider re-derives (nothing invalidates it after a round; SCR-03 and SCR-04 are sibling routes, so the map is disposed during a round).
- **Code read:** rule order in `topicLocks` matches the design (passed > below year > played > previous passed / parent > first-of-year). The quiz guard listens to the future before reading, so a deep link to a locked topic never creates a round row. Profile changes re-derive on the next SCR-03 visit.
- **Nit (not blocking):** the doc comment on `topicLocksProvider` (`lib/providers.dart`) says "SCR-10 invalidates it"; it's SCR-15 since the build change. Fix in a later tidy.
- Padlock look with real fonts is Ken's check on the tablet at M5.

## Test diff review

Four new test files. Existing files changed: `migration_test.dart` (`user_version` 4 → 5 in three cases, plus the v4→v5 case), `progress_test.dart` (`score: 0` in a constructor), `quiz_harness.dart` (`lockTopics`, default false, overrides locks to open), `mix_in_test.dart` (opens its topic through the repository), `pin_flow_test.dart` (scrolls SCR-11 to `change-pin`). Nothing removed, no `skip:`, no assertion loosened.
