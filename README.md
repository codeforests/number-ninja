# Number Ninja

An offline Android tablet app that helps a Singapore primary school child practise maths: P1 revision, the P2 MOE syllabus and Olympiad-style puzzles. Every answer is timed, a PIN-protected parent dashboard shows accuracy and speed per topic (with PDF export), and a daily screen-time limit keeps sessions short.

- Requirements: [docs/01-requirements.md](docs/01-requirements.md)
- Design: [docs/02-design.md](docs/02-design.md)
- Plan and build order: [docs/03-plan.md](docs/03-plan.md)
- Where the build is: [docs/STATE.md](docs/STATE.md)

## Install on the tablet

Each CI run on `main` uploads `app-release.apk` as a build artifact. Download it on the tablet (or copy it over USB), allow "Install unknown apps" for your file manager, and open the APK.
