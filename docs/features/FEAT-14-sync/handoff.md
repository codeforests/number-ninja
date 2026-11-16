# Handoff: FEAT-14 — Progress sync
Branch: feat/FEAT-14-sync · PR: see STATE (draft) · Updated: 2026-11-16 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-14 on branch feat/FEAT-14-sync. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Tests: `test/data/migration_test.dart` (AC-1), `test/domain/sync_merge_test.dart` (AC-2), `test/data/sync/sync_service_test.dart` (AC-3), `test/data/sync/sync_controller_test.dart` + `test/features/parent/account_sync_test.dart` (AC-4, AC-5), `account_screen_test.dart` layout (six sizes, 1.3), `server/test/test/sync_test.dart` (AC-6), `test/live/sync_live_test.dart` (AC-7, run by `server/test/run.sh`; locally first sync 34 s).
- Deviations: (1) rate limits: each request in a PocketBase batch counts, so `1763251203_sync.js` sets `*:create` 5000/5 s and `/api/batch` 10/s for signed-in users (`users:create` and guests stay 20/5 s); `SyncService` resends a batch after 1 s on 429. (2) `backup_test.dart` now expects batch on (it asserted off for FEAT-12). (3) An account switch gives local rounds/attempts new uuids (server uuids are unique across accounts). (4) The child record is read in step 2 only, not pulled again in step 4. (5) Data providers watch `syncDataVersionProvider` instead of being invalidated by the controller (keeps data → features layering). (6) A badge duplicate found on push is only overwritten when the local date is earlier.
- AC-7 second sync pulls the new records plus the ones at the last cursor (`>=`), so the test allows up to 100 extra; it saw 2 + 3.
- Widget tests sync only with `serverConfigProvider` overridden (gotcha in code-map).

## Left to CI or later
- CI `server` job runs AC-6/AC-7 (shellcheck not installed here; run.sh change is small). APK build only in CI.
- AC-9 on Ken's tablets with the M6 APK; the live server needs the new migration and hook (Deploy server workflow) before sync works there.

## Pending for Ken
- none (after verify: merge, deploy the server, then the M6 release APK with SERVER_URL).
