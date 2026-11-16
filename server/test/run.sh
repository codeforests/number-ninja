#!/usr/bin/env bash
# FEAT-12 server tests (AC-2, AC-3): starts the pinned PocketBase, runs the
# API rule and backup tests, restores the backup into a second, fresh
# PocketBase with server/restore.sh and checks it. Used by CI and locally.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$root/build/server-test"
rm -rf "$work" && mkdir -p "$work"

cleanup() {
  "$root/scripts/server-local.sh" stop "$work/main"
  "$root/scripts/server-local.sh" stop "$work/restored"
}
trap cleanup EXIT

cd "$here"
dart pub get >/dev/null

PB_PORT=8090 "$root/scripts/server-local.sh" start "$work/main"
PB_URL=http://127.0.0.1:8090 PB_BACKUP_OUT="$work/backup.zip" \
  dart test test/api_rules_test.dart test/backup_test.dart

PB_HOME="$work/restored" PB_SERVICE='' PB_OWNER='' \
  "$root/server/restore.sh" "$work/backup.zip"
PB_PORT=8091 "$root/scripts/server-local.sh" start "$work/restored"
PB_URL=http://127.0.0.1:8091 PB_RESTORE_MARKER="$work/backup.zip.json" \
  dart test test/restore_check_test.dart
