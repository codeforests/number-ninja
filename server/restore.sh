#!/usr/bin/env bash
# Restores a PocketBase backup zip (FEAT-12, NFR-15, ADR-08).
#
#   On the droplet:  sudo server/restore.sh /opt/numberninja/pb_data/backups/<name>.zip
#   In CI (no systemd):  PB_HOME=build/pb_restore PB_SERVICE= PB_OWNER= server/restore.sh <zip>
#
# Stops PocketBase, keeps the current data as pb_data.before-restore-<time>,
# unzips the backup into a fresh pb_data, starts PocketBase and checks health.
#
#   PB_HOME        default /opt/numberninja
#   PB_SERVICE     systemd unit to stop/start; empty = caller runs PocketBase
#   PB_OWNER       owner of the restored files; empty = leave as is
#   PB_HEALTH_URL  default http://127.0.0.1:8090/api/health (checked only with PB_SERVICE)
set -euo pipefail

zip="${1:?usage: restore.sh <backup.zip>}"
home="${PB_HOME:-/opt/numberninja}"
service="${PB_SERVICE-numberninja-pb}"
owner="${PB_OWNER-numberninja}"
health="${PB_HEALTH_URL:-http://127.0.0.1:8090/api/health}"

[ -f "$zip" ] || { echo "No such backup: $zip" >&2; exit 1; }
unzip -l "$zip" | grep -qE '[[:space:]]data\.db$' || { echo "$zip has no data.db; not a PocketBase backup" >&2; exit 1; }

# The backup may sit inside pb_data/backups, which is about to move.
staged="$(mktemp -d)/backup.zip"
cp "$zip" "$staged"

if [ -n "$service" ]; then
  systemctl stop "$service"
fi

data="$home/pb_data"
if [ -d "$data" ]; then
  kept="$data.before-restore-$(date -u +%Y%m%dT%H%M%SZ)"
  mv "$data" "$kept"
  echo "Previous data kept in $kept"
fi
mkdir -p "$data"
unzip -q "$staged" -d "$data"
rm -f "$staged"
# Keep the old backups available after the restore.
if [ -n "${kept:-}" ] && [ -d "$kept/backups" ]; then
  cp -a "$kept/backups" "$data/"
fi
if [ -n "$owner" ]; then
  chown -R "$owner:$owner" "$data"
fi
echo "Restored $zip into $data"

if [ -n "$service" ]; then
  systemctl start "$service"
  for _ in $(seq 1 30); do
    if curl -fs "$health" >/dev/null; then echo "PocketBase is healthy"; exit 0; fi
    sleep 1
  done
  echo "PocketBase did not come back; see: journalctl -u $service" >&2
  exit 1
fi
