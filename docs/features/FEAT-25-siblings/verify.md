# FEAT-25: Verify

> Verdict: **accepted** (2026-11-20, auto mode). Code verified at `8bf24e5`; this stage added one test assertion (revision history per child, AC-2) and the docs. CI on the final head of PR #32 runs the APK build and `server/test/run.sh` (AC-8). AC-10 is live-only and optional for Ken.

## Checks re-run here

- Fresh clone of the branch: `flutter pub get`, `build_runner build` and `tool/generate_bank.dart` left no diff (generated files are current).
- `scripts/check.sh` (format, analyze, full `flutter test`) on the clean clone: all PASS (see "Run").
- Not run here: APK build (no Android SDK), `server/test/run.sh` (PocketBase download): both in CI.

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `test/data/migration_test.dart` v8 → v9: profile, rounds, attempts, badges, two devices' usage, unlocks, sync fields and linked sync state all child 1, nickname/limit/sound/remote id/epoch copied, counts unchanged; no-profile install gets an empty nickname; fresh database has child 1. |
| AC-2 | pass | `test/data/family_test.dart`: rounds, levels, recent-correct ids, stats, `day()`, `firstDay`, mix-in, badges, topic locks and reset per child. Revision history was only covered indirectly (it reads the per-child stats and rounds repositories); verify added a direct assertion that each child's `RevisionRepository.history()` holds only her own levels, attempts and recent-correct ids. |
| AC-3 | pass | `test/features/family/who_test.dart`: Mia's 30 running seconds flush to her on the switch, Leo shows his own minutes, Mia locked offers `lock-change-child`, Leo's play counts to Leo; Mia's limit and extra time leave Leo at 20 min. Data part also in `family_test.dart`. |
| AC-4 | pass | `who_test.dart`: cold launch with 2 shows SCR-17, picking Leo greets Leo, chip reopens it, leaving the parent area shows it, one child shows neither; PIN option keeps the last child and the chip goes through SCR-08 without unlocking the parent area. Router redirect keeps `/who` closed unless `choosingChild` (reviewed `lib/app.dart`). |
| AC-5 | pass | `test/features/family/children_test.dart` (add with nickname, year, avatar shows in SCR-18 and SCR-17, hidden at 4; edit one child; remove needs PIN, absent for the last, deletes only her rows; removing the playing child makes the first current) and `family_test.dart` (limit of 4, last child kept). |
| AC-6 | pass | `children_test.dart`: switcher absent with one child; switching on SCR-09 changes the dashboard, SCR-16 and the PDF; `test/domain/report_test.dart` nickname title (ASCII) and file-name slug. |
| AC-7 | pass | `test/data/sync/family_sync_test.dart`: two tablets on `FakeSyncServer`; "mia" merges, Leo added with his rounds; field change per child; Leo's reset clears only Leo on both; removal reaches the other tablet; offline removal waits as `pending_delete`; one-and-one merge with different nicknames; a new child on tablet 2 goes up as her own record. `matchChildren` unit tests in `test/domain/family_test.dart`. |
| AC-8 | pass (CI) | `server/test/test/api_rules_test.dart` group `siblings` (two children, records for each, other owner refused, delete cascades, avatar stored). Build ran it green against PocketBase 0.40.6; CI's server job re-runs it on the final head. Migration `1763251206_siblings.js` only adds `children.avatar`; no unique index on `children.owner` blocks a second child. |
| AC-9 | pass | `test/features/family/family_layout_test.dart`: SCR-17 with 4 children, SCR-18, SCR-12 with avatar row and remove, parent switcher on SCR-09/11, at the FEAT-04 sizes, text scale 1.3 and phone sizes. Existing-test changes reviewed in the diff: only child-id setup, moved-tile taps (`ensureVisible`) and the sync field count; no assertion weakened or test removed. |
| AC-10 | pending (live, optional) | Two tablets, two children, FEAT-14 AC-9 per child: Ken, after the release. |

## Beyond the tests

- Reviewed `SyncService._children` (AD-9/10/11/16): offline removal deletes the server record only if it still exists; a child gone from the account is deleted locally unless she is the last (kept, unlinked, re-uploaded, AD-2); siblings added elsewhere are inserted with their server avatar. A removed child's unsynced rounds on another tablet are lost by design (AD-10).
- Removing a child is irreversible on every device once synced; it sits behind the PIN confirm (`RemoveChildScreen`).

## Run

- Clean clone at `8bf24e5`: regen no diff; `scripts/check.sh` format PASS, analyze PASS, `flutter test` PASS (246 s). The added `family_test.dart` assertion passed on its own (8 tests).
