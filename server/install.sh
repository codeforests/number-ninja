#!/usr/bin/env bash
# Installs or upgrades the Number Ninja server on the droplet (FEAT-12,
# NFR-15, ADR-08). deploy.sh copies server/ to a staging dir and runs this
# as root, with settings on stdin as KEY=VALUE lines (so the password never
# shows in a process list):
#   SERVER_HOSTNAME  PB_SUPERUSER_EMAIL  PB_SUPERUSER_PASSWORD  CERT_EMAIL
# and, optional (FEAT-13; empty leaves email or Google sign-in off):
#   SMTP_HOST SMTP_PORT SMTP_USERNAME SMTP_PASSWORD MAIL_SENDER_ADDRESS RESEND_API_KEY
#   GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET
# Idempotent: re-running is the upgrade path.
#
# nginx: the droplet's nginx already serves other sites. This only ever
# writes /etc/nginx/sites-available/numberninja.conf (+ its sites-enabled
# link), runs nginx -t before any reload, and undoes its own change if the
# test fails, so the other sites keep working.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
home=/opt/numberninja
user=numberninja
site_avail=/etc/nginx/sites-available/numberninja.conf
site_link=/etc/nginx/sites-enabled/numberninja.conf
acme=/var/www/numberninja-acme

SERVER_HOSTNAME='' PB_SUPERUSER_EMAIL='' PB_SUPERUSER_PASSWORD='' CERT_EMAIL=''
pb_env_keys=(SMTP_HOST SMTP_PORT SMTP_USERNAME SMTP_PASSWORD MAIL_SENDER_ADDRESS RESEND_API_KEY GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET)
for k in "${pb_env_keys[@]}"; do printf -v "$k" '%s' ''; done
while IFS='=' read -r key value; do
  case "$key" in
    SERVER_HOSTNAME | PB_SUPERUSER_EMAIL | PB_SUPERUSER_PASSWORD | CERT_EMAIL | \
      SMTP_HOST | SMTP_PORT | SMTP_USERNAME | SMTP_PASSWORD | MAIL_SENDER_ADDRESS | RESEND_API_KEY | \
      GOOGLE_CLIENT_ID | GOOGLE_CLIENT_SECRET)
      printf -v "$key" '%s' "$value" ;;
    '') ;;
    *) echo "Unknown setting: $key" >&2; exit 2 ;;
  esac
done
host="$SERVER_HOSTNAME"
CERT_EMAIL="${CERT_EMAIL:-$PB_SUPERUSER_EMAIL}"
[[ "$host" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ && "$host" == *.* ]] || { echo "Bad SERVER_HOSTNAME: '$host'" >&2; exit 2; }
if [ -z "$PB_SUPERUSER_EMAIL" ] || [ -z "$PB_SUPERUSER_PASSWORD" ]; then
  echo "PB_SUPERUSER_EMAIL and PB_SUPERUSER_PASSWORD are required" >&2; exit 2
fi
[ "$(id -u)" -eq 0 ] || { echo "Run as root" >&2; exit 2; }
command -v nginx >/dev/null || { echo "nginx is not installed; this setup runs behind the droplet's nginx" >&2; exit 1; }
if [ ! -d /etc/nginx/sites-available ] || [ ! -d /etc/nginx/sites-enabled ]; then
  echo "Expected Debian/Ubuntu nginx layout (sites-available, sites-enabled)" >&2; exit 1
fi

step() { echo "==> $*"; }

# shellcheck source=/dev/null
. "$here/VERSION"

step "Packages"
missing=()
for pkg in certbot curl unzip; do
  command -v "$pkg" >/dev/null || missing+=("$pkg")
done
if [ ${#missing[@]} -gt 0 ]; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing[@]}"
fi

step "User and folders"
id -u "$user" >/dev/null 2>&1 || useradd --system --home-dir "$home" --shell /usr/sbin/nologin "$user"
install -d -o "$user" -g "$user" -m 0750 "$home" "$home/pb_data"
install -d -m 0755 "$acme"

step "PocketBase $PB_VERSION"
if [ "$("$home/pocketbase" --version 2>/dev/null || true)" != "pocketbase version $PB_VERSION" ]; then
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/pb.zip" "https://github.com/pocketbase/pocketbase/releases/download/v$PB_VERSION/pocketbase_${PB_VERSION}_linux_amd64.zip"
  echo "$PB_SHA256  $tmp/pb.zip" | sha256sum -c --quiet
  unzip -oq "$tmp/pb.zip" pocketbase -d "$tmp"
  install -o root -g root -m 0755 "$tmp/pocketbase" "$home/pocketbase.new"
  rm -rf "$tmp"
  replace_binary=1
fi

step "Migrations, hooks and web pages"
for d in pb_migrations pb_hooks pb_public; do
  rm -rf "$home/$d.new"
  cp -r "$here/$d" "$home/$d.new"
  chown -R root:root "$home/$d.new"
  chmod -R a+rX,go-w "$home/$d.new"
done

install -m 0755 "$here/restore.sh" "$home/restore.sh"

step "Service unit"
# Read by the unit; pb_hooks/config.pb.js applies it on every start. Holds
# the SMTP password and Google secret, so root-only (systemd reads it as root).
env_file=/etc/default/numberninja-pb
quote() { local v="${1//\\/\\\\}"; printf '"%s"' "${v//\"/\\\"}"; }
umask_old="$(umask)"; umask 077
{
  printf 'SERVER_HOSTNAME=%s\n' "$host"
  for k in "${pb_env_keys[@]}"; do
    if [ -n "${!k}" ]; then printf '%s=%s\n' "$k" "$(quote "${!k}")"; fi
  done
} >"$env_file.new"
umask "$umask_old"
chmod 0600 "$env_file.new"
mv "$env_file.new" "$env_file"
if [ -n "$RESEND_API_KEY" ] && [ -n "$MAIL_SENDER_ADDRESS" ]; then mail=on-resend
elif [ -n "$SMTP_HOST" ] && [ -n "$MAIL_SENDER_ADDRESS" ]; then mail=on-smtp
else mail=off; fi
echo "Email: $mail, Google sign-in: $([ -n "$GOOGLE_CLIENT_ID" ] && [ -n "$GOOGLE_CLIENT_SECRET" ] && echo on || echo off)"
install -m 0644 "$here/numberninja-pb.service" /etc/systemd/system/numberninja-pb.service
systemctl daemon-reload
systemctl enable --quiet numberninja-pb

# Writes our site file, tests nginx, reloads; on a failed test puts back what
# was there before (or removes our link) and stops.
apply_site() {
  local new="$1" prev link_existed=0
  prev="$(mktemp)"
  if [ -f "$site_avail" ]; then cp "$site_avail" "$prev"; else : >"$prev"; fi
  [ -L "$site_link" ] && link_existed=1
  install -m 0644 "$new" "$site_avail"
  ln -sfn "$site_avail" "$site_link"
  if ! nginx -t 2>&1; then
    echo "nginx -t failed; undoing the numberninja site change" >&2
    if [ -s "$prev" ]; then install -m 0644 "$prev" "$site_avail"; else rm -f "$site_avail"; fi
    [ "$link_existed" -eq 1 ] || rm -f "$site_link"
    rm -f "$prev"
    exit 1
  fi
  rm -f "$prev"
  systemctl reload nginx
}

render() { sed "s|\${SERVER_HOSTNAME}|$host|g" "$here/nginx/numberninja.conf.template"; }

host_re="${host//./\\.}"
others="$(grep -RlE "server_name[^;]*[[:space:]]${host_re}[[:space:];]" /etc/nginx/sites-enabled/ /etc/nginx/conf.d/ 2>/dev/null | grep -v "numberninja.conf" || true)"
if [ -n "$others" ]; then
  echo "Another nginx site already uses $host: $others. Remove it there first." >&2
  exit 1
fi

step "Certificate for $host"
if [ ! -f "/etc/letsencrypt/live/$host/fullchain.pem" ]; then
  # Port 80 only until the certificate exists.
  bootstrap="$(mktemp)"
  render | awk '/^server \{/{n++} n<2' >"$bootstrap"
  apply_site "$bootstrap"
  rm -f "$bootstrap"
  certbot certonly --webroot -w "$acme" -d "$host" \
    --non-interactive --agree-tos -m "$CERT_EMAIL" \
    --deploy-hook "systemctl reload nginx"
fi

step "nginx site"
full="$(mktemp)"
render >"$full"
apply_site "$full"
rm -f "$full"

step "Database migrations and superuser"
systemctl stop numberninja-pb || true
if [ "${replace_binary:-0}" -eq 1 ]; then mv "$home/pocketbase.new" "$home/pocketbase"; fi
for d in pb_migrations pb_hooks pb_public; do
  rm -rf "${home:?}/$d"
  mv "$home/$d.new" "$home/$d"
done
run_pb() { sudo -u "$user" env SERVER_HOSTNAME="$host" "$home/pocketbase" "$@" --dir="$home/pb_data"; }
run_pb migrate up --migrationsDir="$home/pb_migrations" >/dev/null
run_pb superuser upsert "$PB_SUPERUSER_EMAIL" "$PB_SUPERUSER_PASSWORD" >/dev/null
systemctl start numberninja-pb

step "Health"
for _ in $(seq 1 30); do
  if curl -fs http://127.0.0.1:8090/api/health >/dev/null; then echo "PocketBase is up on 127.0.0.1:8090"; exit 0; fi
  sleep 1
done
echo "PocketBase did not start: journalctl -u numberninja-pb" >&2
exit 1
