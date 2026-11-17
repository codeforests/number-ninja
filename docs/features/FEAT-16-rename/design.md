# FEAT-16: New name and v2.0

> Implements: D16 · Screens: SCR-02 (title), SCR-12 (intro text), launcher label and icon, PDF report, server sign-in return page and emails
> Status: designed · Branch: `claude/project-thread-1sd1wa` · 2026-11-17

## Scope

Everything a person sees says **BrainBubblz** instead of "Number Ninja": the launcher label, home title without a profile, the profile intro, the PDF report title, creator and footer, the CI release title and APK file name, README and docs. The launcher icon changes from the ninja face to bubbles on the same indigo. The "Ninja Master" badge is shown as "Bubble Master". Version becomes `2.0.0+3`, so it installs over every earlier APK. The server's app name (email sender name) and the Google return page say BrainBubblz after Ken's next "Deploy server". A tablet regression checklist for Ken is in `regression.md`.

Not in scope: Play Store listing, buying `brainbubblz.com` (the server stays on `api.brainbubblz.audiodenoiser.com`), the Google consent-screen app name (Ken's Google Cloud console).

## Design decisions (this feature)

1. **Display spelling "BrainBubblz"**, one word (Ken may switch to "Brain Bubblz" on the decision card; only the strings change).
2. **Kept on purpose, so sign-in and installs keep working:** application id and namespace `com.codeforests.number_ninja` (D16); Dart package `number_ninja` (imports only, never shown); the `numberninja://signin` deep-link scheme (the server return page, `deploy.sh`'s check and `SignInReturnActivity` agree on it, and changing it breaks Google sign-in for any app still on m6); server unit, nginx file names and keystore alias; badge id `ninja-master` (synced and stored by id); `AppColors.ninja` (code name only).
3. **Server app name** comes from a new migration `1763251205_rename.js` (the FEAT-12 settings migration has already run on the droplet, so editing it would do nothing); `config.pb.js` already copies `appName` into `senderName`.

## Acceptance criteria

- **AC-1** (D16 strings): no user-facing "Number Ninja" or "Ninja" text is left in `lib/`, `android/app/src/main/AndroidManifest.xml`, `server/nginx`, `server/pb_*`, README, CI release step (`grep -rn "Number Ninja\|'Ninja"` finds nothing there); `android:label="BrainBubblz"`; home greeting without a profile is "BrainBubblz"; report title "BrainBubblz progress report"; badge `ninja-master` is named "Bubble Master".
- **AC-2** (D16 kept ids): `applicationId`/`namespace` stay `com.codeforests.number_ninja`; the manifest and the return page still use `numberninja://signin`; badge id unchanged.
- **AC-3** (icon): `test/tool/icon_test.dart`: generator reproduces `assets/icon` with no diff; mipmap corners are indigo; adaptive icon present.
- **AC-4** (version): `pubspec.yaml` is `2.0.0+3`.
- **AC-5** (server): the new migration sets `meta.appName` to "BrainBubblz"; server tests pass in CI; the return page title and button say BrainBubblz.
- **AC-6** (regression): full `scripts/check.sh` passes and CI builds the APK; `regression.md` lists the tablet checks for Ken.

## Tasks

- [x] T1 — App strings, badge name, manifest label, version; tests that name them.
      Done when: AC-1 (app part), AC-2, AC-4: `flutter test test/domain test/features/home test/features/profile test/tool`.
- [x] T2 — Bubble icon in `tool/icon/draw.dart`, regenerate `assets/icon` and mipmaps.
      Done when: AC-3.
- [ ] T3 — Server: rename migration, return page text; README, CI release names, docs (D16, STATE, code-map), `regression.md`; full check; draft PR.
      Done when: AC-1, AC-5, AC-6.
