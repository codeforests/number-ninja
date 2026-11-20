# Handoff: FEAT-30 — Free tier and Plus in the app
Branch: feat/FEAT-30-plus-in-app · PR: https://github.com/codeforests/number-ninja/pull/36 (draft) · Updated: 2026-11-20 by build
Stage done: build (T1–T7 of 7)
Next: verify — kickoff: "Verify FEAT-30 on branch feat/FEAT-30-plus-in-app. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Tests by AC: AC-1 `test/domain/plus_test.dart`; AC-2 `test/data/plus_repository_test.dart` + `migration_test.dart` group v12; AC-3 `test/features/parent/plus_gates_test.dart`, `test/features/revision/revision_free_test.dart`; AC-4 `test/features/family/siblings_free_test.dart` + setup case in `setup_flow_test.dart`; AC-5 `revision_free_test.dart`; AC-6/AC-7 `test/features/parent/plus_screen_test.dart`; AC-8 `bank_updater_test.dart` ("free: no server call").
- Deviations (recorded in `02-design.md` change log): `PlusCard` is in `features/parent/plus_screen.dart`, not `lib/ui` (layering); SCR-16 also shows a Plus card on free; `revisionDueProvider` added for the lock card; the parent-side child switcher still changes the active child on free; SCR-07 "Change child" is hidden on free like the chip.
- Two old tests adapted, not weakened: `sound_switch_test` scrolls to its row and `parent_time_test`'s tap helper pumps after `ensureVisible` (the new SCR-11 Plus row pushed rows down).
- `main.dart` reads the cache with `readPlusCache(db)` to decide the cold-launch picker.

## Left to CI or later
- APK build and manifest check run in CI only (no Android SDK here). No new plugin or Android config.
- AC-9 live check with the M9 release, after `deploy-server.yml` ships FEAT-29.

## Pending for Ken
- none to verify. At the M9 release: every family tablet must be signed in to keep Plus features (PD-2); say so in the release note.
