# Handoff: FEAT-36 — Invitation codes
Branch: feat/FEAT-36-invite-codes · PR: none · Updated: 2026-11-20 by design
Stage done: design
Next: build — kickoff: "Build FEAT-36 (from T1) on branch feat/FEAT-36-invite-codes. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Invitation Plus is the existing `entitlements` row with `source = invite` (FEAT-29 AD-1, unique per user+source): redeem upserts it; reuse `lib/entitlements.js` (`activeEntitlement`, `pbDate`, `ms`) and test helpers `grant()`, `pbDateIn()` in `server/test/lib/fixtures.dart`.
- The repo is public: CI logs are public, so `make-invites.yml` never prints codes (IC-6). Codes go by email (`send_to` input masked, else `INVITE_MAIL_TO`, else `CRASH_DIGEST_TO`) or Ken reads them in the admin.
- Email in tests: the admin endpoint mails through the normal mail path; `test/auth_test.dart` / `lib/mail_sink.dart` show how to catch it.
- Redeem needs a verified account (403 `unverified`), like child create in `1763251202_auth.js`.
- SCR-20 is `lib/features/parent/plus_screen.dart`; after a redeem store the returned entitlement (`PlusRepository.storeEntitlement`) then call `plusControllerProvider.notifier.check()`. Gate rows on `plusProvider`, and tests set Plus via `QuizHarness.plus`/`setPlus`.
- IC-12: `checkBank` in `lib/providers.dart` awaits `plusCacheProvider.future` before reading `bankUpdaterProvider`; update the FEAT-30 gotcha in `code-map.md`.
- D25 and INV-01..07 are already in `01-requirements.md`; SCR-20 row and change log in `02-design.md` done.

## Left to CI or later
- AC-11 live check (make a code on `api.brainbubblz.com`, redeem on a tablet) goes with the M9 release, after `deploy-server.yml` ships FEAT-29 and FEAT-36 together.

## Pending for Ken
- none (choosing who gets codes and running the workflow happens after release).
