# FEAT-15: Verify

Verdict: **accepted** (2026-11-17, code `3a12da2`). CI on the verify head is the last check (AC-7).

## Checks re-run from a clean checkout

Fresh clone at `78065ef` (code `3a12da2`), Flutter 3.50.0, PocketBase 0.40.6. `build_runner` and `generate_bank.dart` leave no diff.

| Check | Result |
|---|---|
| `scripts/check.sh` (format, analyze, test) | all PASS, 993 tests (2 skipped: the live tests without `SYNC_LIVE_URL`) |
| `server/test/run.sh` (rules, auth, sync, bank publish, backup, live sync + live bank, restore) | PASS, 36 + 2 + 2 tests |
| CI (APK build, `server` job, shellcheck) | on PR #20 at the verify head |

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `bank_validator_test.dart` (retired duplicates/minimums, `missingIds`, `byTopic` vs `byId`); `generator_test.dart` (retired ids marked, unknown id fails, header); bank diff vs main is only `"format":1` in line 1; `revision_test.dart` never serves retired; `retired_question_test.dart` SCR-10 shows a retired question from history. |
| AC-2 | pass | `server/test/test/bank_publish_test.dart` on real PocketBase: dry run uploads nothing; v2 uploaded with file sha256 and version; v2 and v1 refused "not higher"; dropped id refused (names it); validator failure refused; nothing else uploaded; retired v3 accepted; anyone downloads. `api_rules_test.dart`: only a superuser creates. Committed-file mismatch and validator: `publish_bank_test.dart`. |
| AC-3 | pass | `bank_updater_test.dart`: download+save; up to date; 24 h skip and `force`; no URL no request; checksum, parse, validator, dropped id keep current with note; `maxFormat` asked; offline leaves `bankCheckedAt` and retries; one check at a time. |
| AC-4 | pass | `bank_store_test.dart`: newest good wins and prunes; missing and damaged file fall back and remove the row; newer bundled wins (equal also deleted: `row.version > base.version`). `bank_switch_test.dart`: mid-round download leaves the round's questions (same list), next `start` uses v2. |
| AC-5 | pass | `bank_row_test.dart`: no server → "Version 1 (built in) · not checked yet", no button; Check now → "Version 2 (downloaded) · checked today, 9:00 am · downloaded version 2"; layout at 1.3. |
| AC-6 | pass | `test/live/bank_live_test.dart` in `run.sh` against local PocketBase (publish v2 with `tool/publish_bank.dart`, `BankUpdater` + `PocketBaseServerClient` download, `BankStore` loads it). |
| AC-7 | pass locally, CI pending | check.sh green; `migration_test.dart` v7 → v8 (settings kept, new fields null, `bank_files` empty); FEAT-14's v6 test now expects `schemaVersion` (8). |

## Beyond the tests

- Migration `1763251204_banks.js` clears `banks.indexes` before re-adding the version index; `banks` had only that index (FEAT-12), so nothing else is lost. The live server has no bank records, so the field swap is safe; "Deploy server" applies it.
- Publish workflow runs only on `main`, needs `fetch-depth: 0` for the release-tag baseline (set), and refuses the first publish only if the committed bank breaks a rule: publishing v1 now is allowed but no tablet takes it (its bundled bank is also v1).
- A failed check keeps the last success time, so SCR-11 can read "checked today, 9:00 am · offline": intended (D7, D9).
- Nit (not blocking): in `server_client.dart` the `PushOp` doc comment "One record to send…" now sits above `BankInfo`'s comment.

## Test diff review

No test removed or weakened. `migration_test.dart` FEAT-14 case: `7` → `db.schemaVersion` (the upgrade target moved). `quiz_harness.dart`, `parent_harness.dart`, `fake_server_client.dart` gain bank options. Only new `skip:` is the live test's `SYNC_LIVE_URL` guard, as in FEAT-14.
