# Handoff: FEAT-29 — Entitlements on the server
Branch: feat/FEAT-29-entitlements · PR: none · Updated: 2026-11-20 by design
Stage done: design
Next: build — kickoff: "Build FEAT-29 (from T1) on branch feat/FEAT-29-entitlements. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Mostly server work (`server/`, migration `1763251208_entitlements.js`, hooks `entitlement.pb.js` + `pb_hooks/lib/entitlements.js`); the only app change is the file token in `PocketBaseServerClient.latestBank` (AD-4).
- Plus = any record with `expires_at > now`; `status` is display only (AD-1). FOREVER = 2099-12-31 23:59:59Z.
- AD-3 relies on two `@collection.entitlements` conditions joining the same row; AC-3 proves it. If it fails, use the `users.plus_until` fallback in AD-3 and record it here.
- The `banks` rule test changes on purpose (BNK-13 replaces "anyone lists banks"); `test/live/bank_live_test.dart` must sign in a verified, granted parent (it ran anonymously).
- Founding grant (AD-10) runs in the migration: every existing user gets FOREVER complimentary. AC-7 needs a data dir with users created before the migration (start PB once with `--migrationsDir` limited to ≤1763251207, add users, then restart with all).
- Webhook is off without `BILLING_WEBHOOK_SECRET` (503); tests set it on the test PocketBase in `run.sh`. RevenueCat payload shape: `{"api_version":"1.0","event":{...}}`.
- Plan row's Ken's hands (billing account, webhook secret) moved to FEAT-35 (AD-11).

## Left to CI or later
- AC-9 live check after the server deploy (deploy-server.yml is manual); the verify/merge thread deploys and checks Ken's account reports `plus true`.

## Pending for Ken
- none
