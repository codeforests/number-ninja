#!/usr/bin/env bash
# Deploys the server from this repo to the droplet (FEAT-12, ADR-08).
# Run by .github/workflows/deploy-server.yml, or by hand from the repo root.
#
#   DEPLOY_HOST            droplet address
#   DEPLOY_USER            SSH user with sudo without a password
#   SSH_KEY                path to the private deploy key
#   SSH_KNOWN_HOSTS        known_hosts file holding the droplet's key (default ~/.ssh/known_hosts)
#   SERVER_HOSTNAME        e.g. api.brainbubblz.com
#   SERVER_LEGACY_HOSTNAME optional older host still served (FEAT-20), e.g.
#                          api.brainbubblz.audiodenoiser.com
#   PB_SUPERUSER_EMAIL     PocketBase admin login
#   PB_SUPERUSER_PASSWORD
#   CERT_EMAIL             Let's Encrypt notices (default PB_SUPERUSER_EMAIL)
# Optional (FEAT-13; unset leaves the feature off):
#   SMTP_HOST SMTP_PORT SMTP_USERNAME SMTP_PASSWORD MAIL_SENDER_ADDRESS RESEND_API_KEY
#   GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET
#   CRASH_DIGEST_TO        daily crash digest recipient (FEAT-24)
#   BILLING_WEBHOOK_SECRET RevenueCat webhook Authorization value (FEAT-29; empty = off)
# Remote paths expand locally on purpose (stage is a path we created).
# shellcheck disable=SC2029
set -euo pipefail

for v in DEPLOY_HOST DEPLOY_USER SSH_KEY SERVER_HOSTNAME PB_SUPERUSER_EMAIL PB_SUPERUSER_PASSWORD; do
  [ -n "${!v:-}" ] || { echo "Missing $v" >&2; exit 2; }
done
here="$(cd "$(dirname "$0")" && pwd)"
known="${SSH_KNOWN_HOSTS:-$HOME/.ssh/known_hosts}"
ssh_opts=(-i "$SSH_KEY" -o "UserKnownHostsFile=$known" -o StrictHostKeyChecking=yes -o BatchMode=yes)
target="$DEPLOY_USER@$DEPLOY_HOST"

echo "==> Copying server/ to $DEPLOY_HOST"
stage="$(ssh "${ssh_opts[@]}" "$target" 'mktemp -d /tmp/numberninja-deploy.XXXXXX')"
tar -C "$here" --exclude=./test -czf - . | ssh "${ssh_opts[@]}" "$target" "tar -C '$stage' -xzf -"

echo "==> Installing"
status=0
printf '%s\n' \
  "SERVER_HOSTNAME=$SERVER_HOSTNAME" \
  "SERVER_LEGACY_HOSTNAME=${SERVER_LEGACY_HOSTNAME:-}" \
  "PB_SUPERUSER_EMAIL=$PB_SUPERUSER_EMAIL" \
  "PB_SUPERUSER_PASSWORD=$PB_SUPERUSER_PASSWORD" \
  "CERT_EMAIL=${CERT_EMAIL:-}" \
  "SMTP_HOST=${SMTP_HOST:-}" \
  "SMTP_PORT=${SMTP_PORT:-}" \
  "SMTP_USERNAME=${SMTP_USERNAME:-}" \
  "SMTP_PASSWORD=${SMTP_PASSWORD:-}" \
  "MAIL_SENDER_ADDRESS=${MAIL_SENDER_ADDRESS:-}" \
  "RESEND_API_KEY=${RESEND_API_KEY:-}" \
  "GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}" \
  "GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}" \
  "CRASH_DIGEST_TO=${CRASH_DIGEST_TO:-}" \
  "BILLING_WEBHOOK_SECRET=${BILLING_WEBHOOK_SECRET:-}" |
  ssh "${ssh_opts[@]}" "$target" "sudo bash '$stage/install.sh'" || status=$?
ssh "${ssh_opts[@]}" "$target" "rm -rf '$stage'" || true
[ "$status" -eq 0 ] || exit "$status"

echo "==> Checking https://$SERVER_HOSTNAME"
for _ in $(seq 1 30); do
  if curl -fsS "https://$SERVER_HOSTNAME/api/health" >/dev/null 2>&1; then
    admin="$(curl -s -o /dev/null -w '%{http_code}' "https://$SERVER_HOSTNAME/_/images/")"
    if [ "$admin" != 404 ]; then
      echo "Admin UI answered $admin, expected 404" >&2; exit 1
    fi
    # /_/ itself is the Google sign-in result page, not the admin UI.
    if ! curl -fsS "https://$SERVER_HOSTNAME/_/" | grep -q 'Close this tab'; then
      echo "/_/ is not the sign-in result page" >&2; exit 1
    fi
    if ! curl -fsS "https://$SERVER_HOSTNAME/signin/google" | grep -q 'brainbubblz://signin/google'; then
      echo "/signin/google is not the Google return page" >&2; exit 1
    fi
    # Apps built for the legacy host are the old app id with numberninja://.
    if [ -n "${SERVER_LEGACY_HOSTNAME:-}" ]; then
      legacy="https://$SERVER_LEGACY_HOSTNAME"
      if ! curl -fsS "$legacy/api/health" >/dev/null; then
        echo "$legacy/api/health did not answer 200" >&2; exit 1
      fi
      if ! curl -fsS "$legacy/signin/google" | grep -q 'numberninja://signin/google'; then
        echo "$legacy/signin/google does not hand back to the old app" >&2; exit 1
      fi
      echo "Legacy host $SERVER_LEGACY_HOSTNAME answers too and hands back to the old app"
    fi
    echo "Deployed: https://$SERVER_HOSTNAME/api/health is 200, /_/ is the sign-in page, /signin/google hands back to the app, /_/images/ is 404"
    exit 0
  fi
  sleep 2
done
echo "https://$SERVER_HOSTNAME/api/health did not answer 200 within 60 s" >&2
exit 1
