#!/usr/bin/env bash
# Renders numberninja.conf.template to stdout (FEAT-12, FEAT-20). Used by
# install.sh and the CI nginx -t step, so both render the same way.
#   SERVER_HOSTNAME         the API host (required), e.g. api.brainbubblz.com
#   SERVER_LEGACY_HOSTNAME  optional older host still served for installed
#                           apps; empty drops every line that names it
#   CERT_NAME               certificate folder under /etc/letsencrypt/live
#                           (default SERVER_HOSTNAME)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
host="${SERVER_HOSTNAME:?}"
legacy="${SERVER_LEGACY_HOSTNAME:-}"
cert="${CERT_NAME:-$host}"
args=()
[ -n "$legacy" ] || args+=(-e '/\${SERVER_LEGACY_HOSTNAME}/d')
sed "${args[@]}" \
  -e "s|\${CERT_NAME}|$cert|g" \
  -e "s|\${SERVER_HOSTNAME}|$host|g" \
  -e "s|\${SERVER_LEGACY_HOSTNAME}|$legacy|g" \
  "$here/numberninja.conf.template"
