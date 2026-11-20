# Handoff: FEAT-29 — Entitlements on the server
Branch: feat/FEAT-29-entitlements · PR: draft (see STATE) · Updated: 2026-11-20 by build
Stage done: build (T1–T6 of 6)
Next: verify — kickoff: "Verify FEAT-29 on branch feat/FEAT-29-entitlements. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- AD-3 works as designed on PocketBase 0.40.6 (two `@collection.entitlements` conditions join one row; AC-3 test passes): no `users.plus_until` fallback.
- Deviation: `tool/publish_bank.dart` now lists banks as the superuser and downloads the previous bank with a file token (the gate broke it; `bank_publish_test.dart` caught it). Not in design.md's task list.
- AC-7 runs in `run.sh`: a PocketBase on `build/server-test/founding` migrated with `PB_MIGRATIONS_DIR` (copies of ≤1763251207), `founding_grant_test.dart` with `PB_FOUNDING_PHASE=seed`, restart with all migrations, then `=check`.
- AC-5 503 case runs against the Resend PocketBase (8092, no secret) via `PB_URL_NO_BILLING`; `entitlement_test.dart` runs after it starts.
- Webhook: `$RCAnonymousID:` ids are skipped by "is a users id"; BILLING_ISSUE with no grace and SUBSCRIPTION_PAUSED keep the record's expiry (new record: event expiry, else now).
- `grant-plus.yml` uses flutter-action + `flutter pub get` like publish-bank (root package), main only.
- Full `scripts/check.sh` and `server/test/run.sh` passed locally at the build's last commit; CI not run yet (build commits `[skip ci]`).

## Left to CI or later
- CI on the PR head (verify subscribes). AC-9 live after `deploy-server.yml` (verify/merge thread).

## Pending for Ken
- none
