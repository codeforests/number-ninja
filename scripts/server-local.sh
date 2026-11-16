#!/usr/bin/env bash
# Runs the pinned PocketBase locally for the server tests (FEAT-12).
#
#   scripts/server-local.sh start [dir]   download (cached), migrate up, superuser,
#                                         serve on 127.0.0.1:${PB_PORT:-8090} in the background
#   scripts/server-local.sh stop  [dir]
#   scripts/server-local.sh bin           print the binary path (downloads if needed)
#
# Superuser: PB_SUPERUSER_EMAIL / PB_SUPERUSER_PASSWORD (test defaults below).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
. "$root/server/VERSION"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/pocketbase/$PB_VERSION"
bin="$cache/pocketbase"
port="${PB_PORT:-8090}"
email="${PB_SUPERUSER_EMAIL:-admin@test.local}"
password="${PB_SUPERUSER_PASSWORD:-test-password-123}"

fetch() {
  [ -x "$bin" ] && return
  mkdir -p "$cache"
  zip="$cache/pb.zip"
  curl -fsSL -o "$zip" "https://github.com/pocketbase/pocketbase/releases/download/v$PB_VERSION/pocketbase_${PB_VERSION}_linux_amd64.zip"
  echo "$PB_SHA256  $zip" | sha256sum -c --quiet
  unzip -oq "$zip" pocketbase -d "$cache"
  rm "$zip"
}

cmd="${1:-start}"
dir="${2:-$root/build/pb_local}"
case "$cmd" in
  bin) fetch; echo "$bin" ;;
  start)
    fetch
    mkdir -p "$dir"
    "$bin" migrate up --dir="$dir/pb_data" --migrationsDir="$root/server/pb_migrations" >"$dir/migrate.log" 2>&1
    "$bin" superuser upsert "$email" "$password" --dir="$dir/pb_data" >/dev/null
    "$bin" serve --http="127.0.0.1:$port" --dir="$dir/pb_data" \
      --migrationsDir="$root/server/pb_migrations" --hooksDir="$root/server/pb_hooks" --publicDir="$root/server/pb_public" \
      >"$dir/serve.log" 2>&1 &
    echo $! >"$dir/pid"
    for _ in $(seq 1 50); do
      curl -fs "http://127.0.0.1:$port/api/health" >/dev/null && { echo "PocketBase $PB_VERSION on 127.0.0.1:$port ($dir)"; exit 0; }
      sleep 0.2
    done
    echo "PocketBase did not start; see $dir/serve.log" >&2; exit 1 ;;
  stop)
    if [ -f "$dir/pid" ]; then kill "$(cat "$dir/pid")" 2>/dev/null || true; fi
    rm -f "$dir/pid" ;;
  *) echo "usage: $0 start|stop|bin [dir]" >&2; exit 2 ;;
esac
