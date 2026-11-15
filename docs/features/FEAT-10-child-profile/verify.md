# FEAT-10: Verify

> Verified 2026-11-15 in a fresh thread that did not write the code · Commit under test: `c9cfb37` · Verdict: **accepted**

## Checks re-run from a clean checkout

Fresh clone at `c9cfb37`, Flutter 3.50.0, the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (schema v4) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS, 735 tests |
| CI on the final head (PR #14) | see PR checks (release APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `test/domain/profile_test.dart`: no profile / unknown topic → 1; years P1..P6 × P1, P2 and Olympiad topics give the rule's table; each override applies to its own track only; nickname rejects empty, spaces and 21 chars, accepts 1 and 20 after trim; `TopicProgress.fresh`. | pass |
| AC-2 | `profile_repository_test.dart`: new DB pending with no profile; save stores fields, `updated_at` = clock, clears pending; second save overwrites (clears overrides); reset keeps it. `migration_test.dart` v3→v4 keeps PIN hash, sound off and rounds, empty `child_profile`, `profile_pending` false. | pass |
| AC-3 | `profile_flow_test.dart`: SCR-01 → PIN twice → SCR-12 (no back button); Save disabled with no input, blank nickname, enabled with "Mia" + P2; save lands on home and persists; relaunch before the profile asks again; `redirectFor` sends `/`, `/play/school`, `/parent`, `/parent/pin`, `/badges`, `/setup` to `/setup/profile` while pending; neither profile route counts as screen time. Updated install opens home, SCR-11 shows "Not set yet", SCR-12 saves and returns with "Bee · P1", reopens with saved values. | pass |
| AC-4 | `start_level_test.dart` (real quiz controller): no profile → 1; P3 profile → P2 topic at 2; School override 3 → 3; after a 3-star round at 2 the next is 3 and a profile change no longer moves it. SCR-03 with a P2 profile shows `p1.place` Level 2, `p2.place` Level 1, Olympiad override Level 3. Deviation: the "P2 profile, `p1.place` round at 2" case is checked through the tile label and the domain table, because the fake quiz bank has only P2 topics; same rule, same code path (`startLevel` → `levelFor(start:)`). | pass |
| AC-5 | `start_level_test.dart`: `greeting` "Number Ninja" without a profile, "Hi, Mia!" after one. | pass |
| AC-6 | `profile_layout_test.dart`: SCR-12 at the six sizes and scale 1.3, scrolled through, no exceptions or overlap; SCR-02 with a 20-character nickname, no overlap, child tap sizes ok. All earlier layout tests pass unchanged. | pass |

## Beyond the tests

- **Code read:** the redirect puts the pending profile ahead of the PIN gate and the lock, and `/setup/profile` is unreachable once nothing is pending, so the child can't reopen it without the PIN. The quiz loads the profile on each `start`, so a parent's change applies to the next round without a restart; SCR-03 and home re-read it through the autoDispose provider.
- **Upgrade path:** v3→v4 adds the column then sets it false for the existing row; `onCreate` inserts the settings row with the default true. The v1.0 tablet will go straight home (PRO-02).
- **Nit (not blocking):** in `lib/providers.dart` the doc line "Daily screen-time usage and limit (TIM-01..05)." now sits above `profileRepositoryProvider` instead of `usageRepositoryProvider`. Fix with the FEAT-09 one in a later tidy.
- SCR-12 not rendered with real fonts here; look and feel is Ken's check on the tablet at M5.

## Test diff review

Four new test files plus new cases. Existing files changed: `migration_test.dart` (two cases expect `user_version` 4, other assertions kept), `round_repository_test.dart` (one case added), `parent_harness.dart` (`tapKey` scrolls to a tile not yet built; it still fails if the key never appears). Nothing removed, no `skip:`, no assertion loosened.
