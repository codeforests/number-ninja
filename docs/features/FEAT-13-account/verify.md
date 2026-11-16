# FEAT-13: Verify

> Verified 2026-11-16 in a fresh thread that did not write the code · Commit under test: `0ee851e` (code as of `470a402`, plus handoff notes) · Verdict: **accepted** (AC-1..AC-5 pass; AC-6 live flows wait for Ken's Brevo and Google setup)

## Checks re-run from a clean checkout

Fresh clone at `0ee851e`, Flutter 3.50.0, PocketBase 0.40.6. `build_runner` and `generate_bank.dart` leave no diff.

| Check | Result |
|---|---|
| `scripts/check.sh` (format, analyze, test) | all PASS, 917 tests |
| `server/test/run.sh` (rules, auth with SMTP sink, backup, restore, restored check) | PASS, 32 + 2 tests |
| shellcheck | not installable here; runs in the CI `server` job |
| CI on the final head | see the PR checks (server job + APK build + manifest check) |

## Acceptance criteria

| AC | Result | Evidence |
|---|---|---|
| AC-1 | pass | `account_repository_test.dart` over a mock HTTP client: stored value has the token and not the password; a second client over the same store is signed in with zero requests; unverified sign-in stores nothing; refresh 401 → expired and cleared, offline keeps it; error mapping; no URL → notConfigured with no request. Repository: starts signed in from store, refresh-on-open expired/offline. `token_store_test.dart` round-trips `SecureTokenStore` on the plugin mock. |
| AC-2 | pass | `auth_test.dart`: sign-up mail link `https://api.example.test/verify.html?token=…`, unverified create child 400/403, confirm then child create works; reset link `…/reset.html?token=…`, old password 400, new works; 7 characters refused with a `password` error; both pages 200 HTML, `noindex`, no external `src`/`href`; dummy Google secrets → `auth-methods` lists google. `restore_check_test.dart`: a server started without the env has SMTP off and no providers. |
| AC-3 | pass | `auth_test.dart`: deleting A removes A's user, children and all four per-child collections (superuser lists empty); B's child and records still read. |
| AC-4 | pass | `account_screen_test.dart`: direct `/parent/account` lands on PIN entry; create → inbox text; unverified → verify text and Resend logs `requestVerification`; each `AuthError` text; client-side checks make no request; forgot neutral; Google hidden/opens browser/cancelled; refresh once on open, expired → form, offline stays; sign out and delete keep local rounds; wrong PIN → no delete call; delete offline keeps session; privacy note; no-server build shows no form; six sizes at 1.3. No existing test changed. |
| AC-5 | pass (CI part on the PR checks) | Plugins in `pubspec.yaml`; manifest adds only `<queries>`, no permission; analyze and check.sh green; CI green on `470a402` (build thread) and re-run on the final head. |
| AC-6 | pending | Needs Brevo SMTP + Google OAuth secrets, "Deploy server", and the M6 test APK (Ken). |

## Beyond the tests

- **Real server answers match the mapping** (probed PocketBase 0.40.6): duplicate email → 400 `data.email.code = validation_not_unique` (emailTaken); wrong password → 400 with empty data (wrongCredentials); unverified password sign-in returns a token (the app discards it); `request-verification` → 204.
- **Code read:** password goes only to the request (controller cleared after sign-in); session is token + record JSON in `flutter_secure_storage`; `accountProvider` is read only in the parent area, and loading it is a local read (NFR-11). `config.pb.js` saves only on change and turns SMTP/Google off when the env is empty. `install.sh` writes the env file 0600 with quoted values; `IFS='=' read` keeps `=` in a secret. nginx has `proxy_buffering off`, so PocketBase's realtime stream (used by the Google flow) passes through.
- **Nit (before handing out a SERVER_URL APK):** with SMTP off, `request-verification` still returns 204, so "Check your inbox" shows and no mail ever comes. Add the Brevo secrets before the M6 test APK.
- **Nit:** if the parent closes the Google tab without finishing, SCR-13 stays busy until the 3-minute timeout (design choice). Could cancel on app resume later.

## Test diff review

All test files are new except `fake_server_client.dart`, which only grows (constructor keeps `result` default; FEAT-12 tests unchanged). `restore_check_test.dart` gains one test. No `skip:` added.
