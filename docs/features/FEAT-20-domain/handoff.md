# Handoff: FEAT-20 — Own domain and new app id
Branch: claude/project-thread-wqok43 · PR: https://github.com/codeforests/number-ninja/pull/30 (draft) · Updated: 2026-11-20 by design+build
Stage done: build (T1–T3 of 3)
Next: verify — kickoff: "Verify FEAT-20 on branch claude/project-thread-wqok43. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Small feature: design and build in one thread. ACs in `design.md`; Ken's steps in `ken-steps.md`.
- App id is `com.brainbubblz.kids` (Ken chose it on 2026-11-20 over `.app`). It is a new app, not an update: data returns by sync.
- Nginx: `server/nginx/render.sh` is the only renderer (install.sh and CI). The `map` picks the return scheme by `$host`; the body's one `$` is that variable. Tested locally with nginx 1.24 (IPv6 listen lines stripped: the container has no IPv6).
- `install.sh` cert logic (SAN compare via `openssl x509 -ext subjectAltName`, interim site on the legacy cert, restore on certbot failure) can only be proven live by Deploy server; review it closely.
- Ran here: `flutter analyze`, `flutter test test/tool test/features/parent/account_screen_test.dart test/data/sync/account_repository_test.dart` (green). Not run: full `scripts/check.sh`, `server/test/run.sh` (no network for PocketBase), APK build.

## Left to CI or later
- APK build + merged-manifest check (package and scheme), server job `nginx -t` + return-page curl.
- AC-5 live: after Ken's steps, merge, Deploy server, release `v2.1.0`, tablet switch.

## Pending for Ken
- Steps 1–4 of `ken-steps.md` (DNS A `api`, Resend domain records, Google redirect URI + authorized domain, GitHub variables/secret) before merge.
