# FEAT-01: Walking skeleton

> Implements: PAR-01, PAR-02, PAR-03, PAR-04, NFR-01, NFR-06, NFR-07, NFR-08 · Screens: SCR-01, SCR-02 (placeholder), SCR-08, SCR-11 (change PIN only)
> Status: developer-done · Branch: `feat/FEAT-01-walking-skeleton` · 2026-11-14

## Scope

The app shell every later feature builds on: the Flutter project and its layers (design §1), the full Drift schema from design §4, the theme, first-run PIN setup, PIN entry with lockout, a parent area holding only "Change PIN", and CI that tests and builds the APK. The home screen is a placeholder with the two track cards disabled ("Coming soon") and a parent button.

Not in scope: questions, quiz, screen time, dashboard (FEAT-02..08). The daily-limit setting exists in the schema but has no screen yet.

## Design

- **Routing** (go_router): `/setup` (SCR-01), `/` (SCR-02), `/parent/pin` (SCR-08), `/parent` (SCR-11). A redirect sends every route to `/setup` until a PIN exists, and `/parent` to `/parent/pin` unless the parent was unlocked in the last 5 minutes (in memory only).
- **Domain** (`lib/domain/pin.dart`): `PinHasher` (random 16-byte salt, SHA-256 iterated 10,000 times, hex output, constant-time compare), `isValidPin` (exactly 4 digits), `PinLockoutPolicy` (5 failures → locked for 60 s; takes `now`).
- **Data** (`lib/data/pin_repository.dart`): `PinRepository(db, clock)` with `hasPin`, `setPin`, `verify` → `PinResult.ok | wrong(attemptsLeft) | locked(until)`, `changePin(current, next)`. Failed count and `locked_until` live in `pin_lockout`, so killing the app doesn't reset the lockout.
- **Clock** (`lib/domain/clock.dart`): `typedef Clock = DateTime Function();` provided through Riverpod; tests override it (NFR-08).
- **UI** (`lib/ui/`): `theme.dart` (colours, radii, text sizes), `pin_pad.dart` (big 0–9 keypad with 4 dots, 72 dp keys).
- **Android:** `minSdk = 24`; the main `AndroidManifest.xml` declares no permissions (NFR-01, NFR-06). Landscape and portrait both allowed.
- **CI** (`.github/workflows/ci.yml`, on push to `main` and on pull requests): Java 17, Flutter stable pinned to 3.50.0, `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, `flutter build apk --release`, upload the APK as artifact `number-ninja-apk` (NFR-07).
- **Release signing** (added in build): `android/app/build.gradle.kts` signs release builds with the key described by `android/key.properties` when present. CI writes that file from the repo secrets `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEYSTORE_PASSWORD` (alias `number-ninja`), so every APK has the same signature and installs over the previous one, keeping her progress. Without the secrets CI warns and falls back to the runner's debug key.

## Acceptance criteria

- **AC-1** (PAR-01, PAR-02): On a fresh install the app opens SCR-01. Two different PINs show "PINs don't match" and nothing is saved. Two matching PINs save a salted hash (the database never holds the PIN digits) and open SCR-02.
- **AC-2** (PAR-02): From SCR-02 the parent button opens SCR-08. A correct PIN opens SCR-11; a wrong one shows "Wrong PIN" with attempts left.
- **AC-3** (PAR-03): After 5 wrong PINs, entry is blocked for 60 s with a countdown, even after an app restart; after 60 s a correct PIN works.
- **AC-4** (PAR-04): In SCR-11, Change PIN asks for the current PIN, then the new one twice; afterwards the new PIN opens the parent area and the old one doesn't.
- **AC-5** (NFR-01, NFR-06): The merged release manifest has no `INTERNET` permission, and `minSdk` is 24.
- **AC-6** (NFR-07): CI runs format, analyze and tests and builds a release APK on the PR, and the APK is downloadable as an artifact.
- **AC-7** (NFR-08): Lockout logic takes the clock as a parameter; its tests use a fake clock and no real waiting.

## Tasks

- [x] T1 — Project: Flutter app `number_ninja` (org `com.codeforests`, Android only), dependencies, layer folders, `analysis_options.yaml`, minSdk 24, app label "Number Ninja", no permissions in the main manifest.
      Done when: `flutter analyze` is clean and `flutter test` passes.
- [x] T2 — Database: all tables in design §4 (incl. `rounds.level`, `rounds.stars`, `pin_lockout`), settings row on create, generated code committed.
      Done when: `test/data/database_test.dart` passes (fresh DB has one settings row with limit 20 and no PIN; lockout row starts at 0).
- [x] T3 — Domain: `clock.dart`, `pin.dart` (`PinHasher`, `isValidPin`, `PinLockoutPolicy`).
      Done when: `test/domain/pin_test.dart` passes (hash ≠ PIN, verify right/wrong, two salts differ, policy locks on the 5th failure and unlocks at +60 s with a fake clock).
- [x] T4 — Data: `PinRepository`.
      Done when: `test/data/pin_repository_test.dart` passes (set/verify, wrong → attemptsLeft, 5 wrong → locked, still locked from a new repository on the same DB, unlocked after 60 s, success resets the count, changePin needs the current PIN).
- [x] T5 — UI: theme, PIN pad, router with redirects, SCR-01, SCR-02 placeholder, SCR-08, SCR-11 with Change PIN.
      Done when: `test/features/pin_flow_test.dart` passes AC-1, AC-2, AC-4 and the lockout message of AC-3 on an in-memory DB with a fake clock.
- [x] T6 — CI workflow and README install note.
      Done when: the workflow passes on the PR and the APK artifact exists (AC-5 checked from the build's merged manifest).
      Note (build): no Android SDK in the cloud session, so the APK build, signing and manifest check run only in CI. Local evidence: `flutter analyze` clean, `flutter test` 26 passed.
