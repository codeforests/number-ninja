#!/usr/bin/env bash
# FEAT-12 server tests (AC-2, AC-3): starts the pinned PocketBase, runs the
# API rule and backup tests and the FEAT-14 live sync test, restores the
# backup into a second, fresh
# PocketBase with server/restore.sh and checks it (started without the
# FEAT-13 env, so it also proves mail and Google stay off). CI and locally.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
work="$root/build/server-test"
rm -rf "$work" && mkdir -p "$work"

cleanup() {
  "$root/scripts/server-local.sh" stop "$work/main"
  "$root/scripts/server-local.sh" stop "$work/restored"
  "$root/scripts/server-local.sh" stop "$work/resend"
}
trap cleanup EXIT

cd "$here"
dart pub get >/dev/null
# FEAT-15: bank_publish_test.dart runs tool/publish_bank.dart from the root.
(cd "$root" && flutter pub get >/dev/null)

# FEAT-24: the crash digest mails CRASH_DIGEST_TO through the same sink and,
# with CRASH_KEEP_DAYS=0, deletes every report it has read.
# FEAT-13: mail goes to the sink that auth_test.dart opens on PB_SMTP_PORT;
# Google secrets are dummies (auth-methods only lists the provider).
export PB_SMTP_PORT=2526 PB_TEST_HOST=api.example.test
SERVER_HOSTNAME=$PB_TEST_HOST SMTP_HOST=127.0.0.1 SMTP_PORT=$PB_SMTP_PORT \
  MAIL_SENDER_ADDRESS=noreply@example.test \
  GOOGLE_CLIENT_ID=dummy-id GOOGLE_CLIENT_SECRET=dummy-secret \
  CRASH_DIGEST_TO=crashes@example.test CRASH_KEEP_DAYS=0 \
  PB_PORT=8090 "$root/scripts/server-local.sh" start "$work/main"
PB_URL=http://127.0.0.1:8090 PB_BACKUP_OUT="$work/backup.zip" \
  CRASH_DIGEST_TO=crashes@example.test \
  dart test --concurrency=1 test/api_rules_test.dart test/auth_test.dart test/sync_test.dart test/bank_publish_test.dart test/backup_test.dart test/crash_digest_test.dart

# Email through Resend's HTTPS API (mail.pb.js): a second PocketBase with
# RESEND_API_KEY and the API URL on resend_test.dart's sink. The SMTP host
# points at a closed port, so a mail sent over SMTP would fail the test.
export PB_RESEND_PORT=2527
SERVER_HOSTNAME=$PB_TEST_HOST SMTP_HOST=127.0.0.1 SMTP_PORT=1 \
  MAIL_SENDER_ADDRESS=noreply@example.test \
  RESEND_API_KEY=test-key RESEND_API_URL=http://127.0.0.1:$PB_RESEND_PORT/emails \
  PB_PORT=8092 "$root/scripts/server-local.sh" start "$work/resend"
PB_URL=http://127.0.0.1:8092 dart test test/resend_test.dart

# FEAT-14 AC-7 (NFR-16): the app's sync against this server; FEAT-15 AC-6:
# a published bank reaches the app.
(cd "$root" && flutter pub get >/dev/null &&
  SYNC_LIVE_URL=http://127.0.0.1:8090 flutter test test/live/sync_live_test.dart test/live/bank_live_test.dart test/live/crash_live_test.dart)

PB_HOME="$work/restored" PB_SERVICE='' PB_OWNER='' \
  "$root/server/restore.sh" "$work/backup.zip"
PB_PORT=8091 "$root/scripts/server-local.sh" start "$work/restored"
PB_URL=http://127.0.0.1:8091 PB_RESTORE_MARKER="$work/backup.zip.json" \
  dart test test/restore_check_test.dart
