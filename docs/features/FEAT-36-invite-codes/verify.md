# FEAT-36: Verify

> Verdict: **accepted** (2026-11-20, auto mode). Verified at build head `58c9cef`; this stage only adds docs.

## Checks re-run here

- `build_runner build` left no diff.
- `scripts/check.sh` on `58c9cef`: format, analyze and the full `flutter test` PASS.
- `server/test/run.sh` PASS (main, restored, Resend and founding PocketBases); `dart analyze` in `server/test` clean.
- APK build and manifest check: CI on the final head (PR #37). No new plugin or Android config.
- Not run: AC-11 (live, with the M9 release after the server deploy).

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `api_rules_test.dart` group `invites`: guest and parent get empty list / 403 / 404 on list, view, create, update, delete for both collections; superuser can; `code` and `(code, user)` unique; deleting a user removes the redemption, the code keeps `uses 1`. |
| AC-2 | pass | `invite_test.dart` "12 months": typed ` abcd - efgh ` (lower case, spaces, dash), 200, `source invite`, until between now+12 months before and after the call, `uses 1`, one redemption with the same date, `GET /api/nn/entitlement` agrees, note kept, bank list visible. |
| AC-3 | pass | "failures write nothing": guest 401, unverified 403 `unverified`, unknown / short / revoked `not_found`, `expired`, `used_up` on a 2-use code, `already_used`, `already_plus` for FOREVER gift and `google_play`; uses, redemptions and entitlements unchanged. |
| AC-4 | pass | "a second code extends": old end + 3 months exactly; lapsed invite → now + 2 months, status back to `active`; 31 Jan + 1 month → 28 Feb. |
| AC-5 | pass | 5 × 400 then 429 from one client IP. |
| AC-6 | pass | admin endpoint: parent refused, superuser count 10 → unique alphabet codes with months, uses, note, `redeem_by`; `send_to` → one email in the sink with the codes and none in the answer. `make_invites_test.dart`: `--print`, no codes without it, `--list --note` with `0/5`, `--revoke` → `not_found`. |
| AC-7 | pass | `invite_code_test.dart`: row when free, button off until 8 valid characters, success closes and shows the invite line and opens Plus features, each refusal line keeps the dialog, no row signed out or with complimentary Plus, "Have another invitation code?" with invite Plus. |
| AC-8 | pass | same file, `inviteCodesAllowedProvider` false: no row. |
| AC-9 | pass | `domain/plus_test.dart` "invitation; free after Plus ended". |
| AC-10 | pass | `bank_updater_test.dart` group "checkBank at launch": Plus cache loading → server called and downloaded; free → `noPlus`, no call. |
| AC-11 | live, later | with the M9 release, not required to merge. |

## Beyond the tests

- Read `lib/invites.js`, `invite.pb.js`, the migration, `redeemInvite`, `storeEntitlement`, the dialog and the workflow. Redeem is one transaction; the workflow passes inputs through env (no shell injection), masks `send_to` and never passes `--print`/`--list`. Changed older tests: only `quiz_harness.dart` gained `realPlus`; no assertion weakened or skipped.
- Notes (not fails): `already_plus` and `activeEntitlement` judge by `expires_at` only, not `status` (same as FEAT-29). The dialog's pop falls back to `DateTime.now()` only if the server omits `until` (it never does). `--revoke` puts the typed code into a filter string; it's a superuser-only local tool, but normalising the code first would be tidier.
- Follow-up kept for FEAT-35: the FEAT-29 rate-limit rule `/api/nn/billing/` never applies (needs `POST ` prefix; code-map gotcha).
