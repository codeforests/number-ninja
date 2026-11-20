# Handoff: FEAT-25 — Siblings
Branch: feat/FEAT-25-siblings · PR: none · Updated: 2026-11-20 by build
Stage done: build (T1–T3 of 6)
Next: build — kickoff: "Build FEAT-25 (from T4) on branch feat/FEAT-25-siblings. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Auto mode: AD-1..14 in design.md are final (AD-14 = T2 build choices); add new ones there and as a D-row.
- Done: schema v9 (`children`, `child_id` everywhere, `_from8To9`, `_v8…` DDL), `ChildRepository` (`add`, `remove` incl. pending delete, `current`, `setCurrent`, `switchNeedsPin`), `currentChildProvider`/`startChildProvider`/`childrenProvider`, every repository per child (default `childId = 1`), SCR-17 + chip + lock button + SCR-11 PIN switch, `ScreenTimeController.switchChild`/`settled`, `lib/ui/avatars.dart` (8 ids in `domain/family.dart`).
- T4: SCR-18 `/parent/children`; SCR-12 `?child=<id>|new` uses `ProfileRepository(childId:)` / `ChildRepository.add`; avatar row `avatar-<id>`; `remove-child` (PIN, hidden for the last child). After add/remove/switch invalidate `childrenProvider` (no stream). Parent switcher `ChildSwitcher` calls `currentChildProvider.notifier.select(id)`; data providers rebuild by themselves (they watch the repos). Report header/file name nickname (AD-13).
- T5: `SyncService` still syncs local child 1 only (`_child1`, reads `sync_state.child_id/reset_epoch/pending_reset`): move those to `children` (AD-11), per-child loop with `matchChildren` (AD-9, not written yet: put it in `domain/family.dart`), pending-delete handling (AD-10), push/pull filtered by child, `avatar` field + server migration.
- `SyncService` writes `children` limit/sound now (no longer `app_settings`).
- Tests: `test/data/family_test.dart` (AC-2, AC-3 data), `test/features/family/who_test.dart` (AC-3, AC-4), migration v8→v9 (AC-1). Full suite 1,269 green at bba20a7.

## Left to CI or later
- Draft PR at the end of T6 (APK build in CI then). AC-10 two tablets: Ken, optional.

## Pending for Ken
- none
