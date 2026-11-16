# FEAT-14: Verify

> Verified 2026-11-16 in a fresh thread that did not write the code · Commit under test: `f47a334` · Verdict: **rework** (one SYN-06 bug, below; AC-1..AC-7 otherwise pass)

## Rework

- **Reset before the first successful sync is half done (SYN-06).** In `SyncService._child` (`lib/data/sync/sync_service.dart`), the `state.childId == null` branch runs before the `pendingReset` branch, so a reset made while signed in but before any run reached the child (first sync after sign-in failed: offline, 5xx) is skipped on that run: the run pulls the account's old rounds back onto this tablet, and the next run resets the server and stores the new epoch, so this tablet keeps the old rounds while the server and the other tablets are cleared. Reproduced with a two-device test (B syncs a round; A's first sync throws offline; A resets locally and `markPendingReset()`; A runs twice, B runs once): server 0 rounds, B 0, A 1.
  Fix: when `childId` is null and `pendingReset` is set, link the child and call the reset route in the same run (before push/pull). Add that case as a test in `sync_service_test.dart` (the `reset` group): after A's runs, A, B and the server all hold 0 old rounds.

## Checks re-run from a clean checkout

Fresh clone at `f47a334`, Flutter 3.50.0, PocketBase 0.40.6. `build_runner` and `generate_bank.dart` leave no diff.

| Check | Result |
|---|---|
| `scripts/check.sh` (format, analyze, test) | all PASS, 955 tests (1 skipped: the live test without `SYNC_LIVE_URL`) |
| `server/test/run.sh` (rules, auth, sync, backup, live sync, restore) | PASS, 35 + 1 + 2 tests |
| shellcheck | not installable here; runs in the CI `server` job |
| CI | not run: the re-verify runs it once on the fixed head |

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `migration_test.dart` v6 → v7: distinct 32-hex uuids, attempts keep their rounds, usage under the device id, all dirty, `sync_fields` backfill; fresh v7 has a device id. |
| AC-2 | pass | `sync_merge_test.dart`: finish only empty → set, unfinished remote never clears; badge earliest both ways; later field time wins, ties keep server; attempts by uuid; usage max per row, sum per day. |
| AC-3 | pass except the case in Rework | `sync_service_test.dart`: A → B for rounds, attempts, badges, profile, limit, sound, topics, usage; union with counts checked on both and the server; late finish arrives, never cleared; later limit wins; usage adds to 900/300 then 1000; no PIN, salt, `failed_count`, `locked_until` in any body; reset online and offline-then-online; account switch; duplicate batch → row by row; round finished mid-push sent next run. |
| AC-4 | pass | `sync_controller_test.dart` with fake timers: start, resume, round, 5 min, Sync now; one extra run for a request during a run; backoff 30 s/1/2/4 min, reset after success, cap 15; none signed out or without URL; expired signs out. `account_sync_test.dart`: resume trigger; a round finishes with no wait while a sync is slow. |
| AC-5 | pass | `account_sync_test.dart`: last sync, "Syncing…", each error text, Sync now; reset note only when signed in. `account_screen_test.dart` six sizes at 1.3 now include `account-last-sync` and `account-sync-now`. |
| AC-6 | pass | `server/test/test/sync_test.dart` against real PocketBase: reset clears rounds/attempts/badges, keeps usage, bumps epoch, sets `reset_at`; B → 403, anonymous → 401; batch of 100 works, one duplicate fails it. |
| AC-7 | pass | Live: first sync 20,000 attempts / 1,000 rounds in 29.3 s; second pushed exactly 1 round + 10 attempts, pulled 2 rounds + 11 attempts (the `>=` cursor's boundary records); B pulled 1,001 / 20,010. |
| AC-8 | pending CI | check.sh green, analyze clean; CI on the re-verified head. |
| AC-9 | pending | Ken's tablets with the M6 APK, after "Deploy server". |

## Beyond the tests

- **Rate limits (deviation 1):** `*:create` for any signed-in user is now 5000 per 5 s, and anyone can sign up, so one account could create records fast. Acceptable for a private server (records stay under that user's own child); worth a look if the server is ever opened wider.
- **Account switch (deviation 3):** local rounds/attempts get new uuids, so the old account keeps its copies and the new one gets its own; matches SYN-03.
- Reset route deletes by SQL inside one transaction and checks `owner = auth id`; migration's down step removes `reset_at` and turns batch off (rate-limit rules are not restored; harmless).

## Test diff review

`backup_test.dart` flips batch from off to on and adds `maxRequests == 100` (FEAT-14 turns batch on; stronger, not weaker). `account_screen_test.dart` adds two keys to the overlap check. `fake_server_client.dart` grows. No test removed, no `skip:` added except the env-gated live test.
