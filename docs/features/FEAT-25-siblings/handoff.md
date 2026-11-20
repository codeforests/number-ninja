# Handoff: FEAT-25 — Siblings
Branch: feat/FEAT-25-siblings · PR: https://github.com/codeforests/number-ninja/pull/32 (draft) · Updated: 2026-11-20 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-25 on branch feat/FEAT-25-siblings. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Auto mode: AD-1..16 in design.md are final (AD-15 = T4 build choices, AD-16 = T5 sync choices); D20 cites them.
- AC → tests: AC-1 `test/data/migration_test.dart` (v8→v9); AC-2 `test/data/family_test.dart`; AC-3/AC-4 `test/features/family/who_test.dart`; AC-5/AC-6 `test/features/family/children_test.dart` + `test/domain/report_test.dart` (nickname title/file name); AC-7 `test/data/sync/family_sync_test.dart` + `matchChildren` in `test/domain/family_test.dart`; AC-8 `server/test/test/api_rules_test.dart` group `siblings`; AC-9 `test/features/family/family_layout_test.dart`.
- Deviations: SCR-11 keeps "Child profile" (current child) and adds "Children" (AD-15); `ChildSwitcher` is in `lib/features/family/` (layer rule); remove confirms on `/parent/remove-child?child=<id>`; pull cursors per child (AD-16); a blank child on a fresh tablet takes the account's first child (AD-16, added to AD-9).
- T6 fixed a T3 overflow: the home child chip is avatar-only on a phone and its label capped elsewhere.
- Test setup changed only where the new SCR-11 row moved tiles (`who_test` tap helper, `pin_flow_test` ensureVisible) and `migration_test` count now follows `syncFieldNames` (avatar is a new sync field).
- Full `scripts/check.sh` green at the build's last commit (1,318 tests). Server `api_rules_test.dart` ran green locally against PocketBase 0.40.6 with the new migration.

## Left to CI or later
- APK build and the full server job (`server/test/run.sh`) run in CI on the PR. AC-10 two tablets: Ken, optional.

## Pending for Ken
- none
