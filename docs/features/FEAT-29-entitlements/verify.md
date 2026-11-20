# FEAT-29: Verify

> Verdict: **accepted** (2026-11-20, auto mode). Verified at build head `0f32290`; this stage only adds docs.

## Checks re-run here

- `build_runner build` left no diff.
- `scripts/check.sh` on `0f32290`: format, analyze and the full `flutter test` PASS.
- `server/test/run.sh` (PocketBase 0.40.6): api rules/auth/sync/bank publish/grant plus/backup/crash digest 50 pass, Resend 3, entitlement endpoint + webhook 14, founding grant seed 1 and check 1 (each phase skips the other by `PB_FOUNDING_PHASE`), live sync/bank/crash 3, restore 2.
- APK build and manifest check: CI on the final head (PR #35).
- Not run: AC-9 (live, needs `deploy-server.yml`; see handoff).

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `api_rules_test.dart` group `entitlements`: own records only, guest none; parent create 403, update/delete 403/404; superuser writes; user delete cascades; `(user, source)` unique. |
| AC-2 | pass | group `banks`: guest and free parent list none; complimentary-until-tomorrow lists and downloads with a file token; bare URL and a free parent's token refused; past expiry empties the list. |
| AC-3 | pass | parent A expired, B active: A lists 0 banks (same-row join holds on 0.40.6, no fallback needed). |
| AC-4 | pass | `entitlement_test.dart` endpoint group: 401, none, FOREVER, expired store + active complimentary → complimentary, only expired → `ended_at`, `checked_at` near now. |
| AC-5 | pass | webhook group: 503 on the no-secret server (8092), 401 wrong/missing, purchase → `will_renew true`, renewal, cancellation, refund, expiration, duplicate and older event, ignored cases, anonymous id, TRANSFER. |
| AC-6 | pass | `grant_plus_test.dart`: forever → until (same record) → revoke; unknown email non-zero, nothing written; email not in stdout. |
| AC-7 | pass | `founding_grant_test.dart` seed on migrations ≤1763251207, check after all: one FOREVER founding record each, later account none. |
| AC-8 | pass | `server_client_bank_test.dart` token call and `token=` signed in, none signed out; `bank_live_test.dart` with a granted parent. |
| AC-9 | live, later | needs the server deploy; not required to merge. |

## Beyond the tests

- Changed older tests: `api_rules_test.dart` drops "anyone lists banks" (BNK-13 replaces BNK-08's open list; the new test asserts the guest sees none); `bank_publish_test.dart` lists as superuser and downloads with a file token. No assertion weakened or skipped.
- Read the migration, `entitlements.js`, `entitlement.pb.js`, the `latestBank` change and `publish_bank.dart`: Plus check uses `expires_at` only (AD-1); webhook answers 200 for everything it ignores (AD-7); stale/duplicate checks per record (AD-8). Down migration deletes the whole collection rather than only founding records (fine: it's the collection's own down step).
- Deploy order: a signed-in v2.2.0 tablet with founding Plus would see the bank but has no file token, so its download fails and it keeps its current bank (BankUpdater already keeps the bank on errors). Deploy with the M9 release so the tablet gets the token-aware app at the same time.
