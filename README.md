# Number Ninja

An offline Android tablet app that helps a Singapore primary school child practise maths: P1 revision, the P2 MOE syllabus and Olympiad-style puzzles. Every answer is timed, a PIN-protected parent dashboard shows accuracy and speed per topic (with PDF export), and a daily screen-time limit keeps sessions short.

- Requirements: [docs/01-requirements.md](docs/01-requirements.md)
- Design: [docs/02-design.md](docs/02-design.md)
- Plan and build order: [docs/03-plan.md](docs/03-plan.md)
- Where the build is: [docs/STATE.md](docs/STATE.md)

## Install on the tablet

1. Open the repo's **Actions** tab, pick the latest green **CI** run on `main` (or on a PR you want to try), and download the `number-ninja-apk` artifact. It is a zip holding `app-release.apk`.
2. Copy the APK to the tablet (download it there, or over USB), unzip it if needed, and allow **Install unknown apps** for the file manager or browser you open it with.
3. Tap the APK to install. On first launch, set your parent PIN.

Installing a newer APK over the old one keeps her progress. Uninstalling the app deletes it (there is no backup, by design).
