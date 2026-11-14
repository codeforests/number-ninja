# FEAT-01: Verify

> Verified 2026-11-14 in a fresh thread that did not write the code · Commit under test: `bb2660e` · Verdict: **accepted**

## Checks re-run from a clean checkout

Clean worktree of `origin/feat/FEAT-01-walking-skeleton`, Flutter 3.50.0 (Dart 3.14.0), the version CI pins.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart format --output=none --set-exit-if-changed lib test` | 20 files, 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 26 passed, 0 failed, 0 skipped |
| `dart run build_runner build` | no diff: committed `database.g.dart` matches the tables |
| CI run [43602026462](https://github.com/codeforests/number-ninja/actions/runs/43602026462) (attempt 2, `bb2660e`) | success: format, analyze, test, signing, release build (55.1 MB APK), manifest check, artifact upload |

No Android SDK in the cloud session, so the APK build, its signing and the merged-manifest check come from CI.

**Signing:** the "Release signing key" step ran without its "No ANDROID_KEYSTORE_BASE64 secret" warning (the run's only annotations are GitHub's Node 20, setup-java v4 and Ubuntu notices), so the secrets were present and the release key was used. I could not download the APK here to compare its certificate with the keystore (SHA-256 `91:62:13:5C:…:48:80`, alias `number-ninja`): artifact storage is blocked from this session. Ken installing it on the tablet, and the next feature's APK installing over it, confirms it end to end.

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `pin_flow_test.dart` "fresh install opens PIN setup; mismatch saves nothing" (opens SCR-01, "PINs don't match", `hasPin` false) and "matching PINs save a salted hash and open home" (hash and salt stored, hash doesn't contain the digits, SCR-02 shown); `pin_repository_test.dart` first case. Code: `PinRepository.setPin` writes only `pin_hash` and `pin_salt`. | pass |
| AC-2 | `pin_flow_test.dart` AC-2: parent button → SCR-08, wrong PIN shows "Wrong PIN. 4 tries left.", right PIN → SCR-11; leaving and re-entering asks again. Router redirect test covers `/parent` and `/parent/change-pin`. | pass |
| AC-3 | `pin_flow_test.dart` AC-3 (5 wrong → keys disabled, countdown 60 s → 15 s → cleared with the fake clock, then the right PIN opens SCR-11) and "still shown after an app restart" (lockout written by one repository, shown by a fresh app on the same DB); `pin_repository_test.dart` lockout, restart and 60 s cases. | pass |
| AC-4 | `pin_flow_test.dart` AC-4 (wrong current PIN rejected, mismatch on confirm, then new PIN works and the old one is `PinWrong`); `pin_repository_test.dart` "changePin needs the current PIN". | pass |
| AC-5 | Main `AndroidManifest.xml` declares no `uses-permission`; `minSdk = 24` in `android/app/build.gradle.kts`; no network packages in `pubspec.yaml` and no `dart:io`/HTTP use in `lib/`. Merged release manifest (`merged_manifests/release/processReleaseManifest/AndroidManifest.xml`): CI step "Check release manifest" passed, no `INTERNET`, `android:minSdkVersion="24"`. The step also prints `android.permission.DUMP`: that is the `android:permission` attribute on AndroidX ProfileInstaller's receiver (a permission a caller needs, not one the app requests). | pass |
| AC-6 | CI runs format, analyze, test and `flutter build apk --release` on the PR; artifact `number-ninja-apk` uploaded (id 14117475107, 26.3 MB zip, expires 2027-02-12). | pass |
| AC-7 | `PinLockoutPolicy` takes `now`; `PinRepository` and `AppSession` take a `Clock`; every lockout test sets `now` by hand and none waits in real time (widget tests advance the fake clock and pump the ticker). | pass |

## Beyond the tests

- Layers (AGENTS.md): `lib/domain` imports only `dart:` and `crypto`; `lib/data` and `lib/ui` import nothing from `lib/features`.
- Theme: screens take colours, radii and text sizes from `lib/ui/theme.dart`. PIN keys are 72 dp (`AppSizes.pinKey`).
- Schema matches design §4 table by table, including `rounds.level`, `rounds.stars` and `pin_lockout`.

## Test diff review

`main` had no tests; the branch only adds four test files (420 lines). Nothing weakened, skipped or deleted, and no `skip:` anywhere. Tests use 10 hash iterations for speed, and `pin_test.dart` separately pins the production default at 10,000.

## Notes (not blocking)

1. Change PIN says "1 tries left" on the last attempt; PIN entry already says "1 try left". Cosmetic, fix in a later feature.
2. `ChangePinScreen` calls `context.go` inside a `setState` callback when locked out. Works, but better moved out of the callback.
3. `home_screen.dart` uses a literal icon size (96) and border width (3). AGENTS.md covers colours, radii and text sizes only, so not a rule break; worth moving to `AppSizes` when the real home screen lands in FEAT-03.
