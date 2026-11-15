# Handoff: FEAT-05 — Screen-time lock
Branch: feat/FEAT-05-screen-time · PR: [#6](https://github.com/codeforests/number-ninja/pull/6) (ready) · Updated: 2026-11-15 by verify
Stage done: verify (accepted)
Next: PR — Ken reviews and merges; then publish release `m2` and Ken's M2 tablet check.

## What the next stage needs
- `verify.md` here: all 7 ACs pass, 507 tests, CI 43673301798 green on `b9f74cb`, mutation checks caught.
- After merge: run the CI workflow on `main` with input `release` = `m2` (plan §1) → `number-ninja-m2.apk`.

## Left to CI or later
- M2 tablet check by Ken (lock after the limit, PIN unlock, NFR-09 on a small device).

## Pending for Ken
- Approve the merge of PR #6. Next feature (FEAT-06) waits for Ken.
