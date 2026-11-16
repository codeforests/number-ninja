# Handoff: FEAT-14 — Progress sync
Branch: feat/FEAT-14-sync · PR: none · Updated: 2026-11-16 by design
Stage done: design
Next: build — kickoff: "Build FEAT-14 (from T1) on branch feat/FEAT-14-sync. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- 6 tasks, schema v7. Merge rules are pure (`lib/domain/sync_merge.dart`); `SyncService` does push then pull; `syncProvider` schedules.
- Push uses `dirty` counters (clear only if unchanged since read), not timestamps; pull uses `updated >= cursor` with idempotent merges.
- `daily_usage` becomes keyed by (day, device_id); `UsageRepository.status` sums over devices.
- Reset: new route `POST /api/nn/children/{id}/reset` in `server/pb_hooks/reset.pb.js`; migration `1763251203_sync.js` adds `children.reset_at` and turns the batch API on (FEAT-12 settings had it off).
- No new plugins, so the draft PR can wait for T6. Hook point: `accountProvider` (FEAT-13); `refresh()` at the start of each run.
- NFR-16 live test runs in the CI `server` job (Flutter is already set up there) with `SYNC_LIVE_URL`.

## Left to CI or later
- AC-7 timing only in CI; AC-9 on Ken's tablets with the M6 APK.

## Pending for Ken
- none (after verify: merge, then the M6 release APK with SERVER_URL).
