#!/usr/bin/env bash
# Runs checks with full output going to log files and prints one result line
# per check, plus only the lines that explain a failure. Saves a session from
# reading pages of passing output (AGENTS.md, Token rules).
#
#   scripts/check.sh                       format, analyze, test (all)
#   scripts/check.sh 'flutter test test/domain'
#
#   CHECK_LINES=n   at most n explaining lines per failed check (default 40)
#
# Every check runs even if an earlier one fails. Exit 1 if any failed.
# Read a full log with `grep -n` on the path it prints, not whole.
set -uo pipefail
export PATH="${FLUTTER_ROOT:+$FLUTTER_ROOT/bin:}$PATH"

if [ $# -eq 0 ]; then
  set -- 'dart format --output=none --set-exit-if-changed lib test tool' \
    'flutter analyze' 'flutter test'
fi

LOG_DIR="$(mktemp -d "${TMPDIR:-/tmp}/checks.XXXXXX")"
MAX_LINES="${CHECK_LINES:-40}"
FAIL_PATTERN='(\[E\]|Expected:|Actual:|Which:|error •|warning •|info •|Error:|Changed |Some tests failed|Exception|FAILED|line [0-9]+)'

failed=0
n=0
for cmd in "$@"; do
  n=$((n + 1))
  slug=$(printf '%s' "$cmd" | tr -c 'A-Za-z0-9._-' '-' | tr -s '-' | cut -c1-50)
  log="$LOG_DIR/$(printf '%02d' "$n")-${slug%-}.log"
  start=$SECONDS
  bash -c "$cmd" >"$log" 2>&1
  rc=$?
  secs=$((SECONDS - start))
  if [ "$rc" -eq 0 ]; then
    total=$(grep -aoE '\+[0-9]+: All tests passed' "$log" | tail -1 | grep -oE '[0-9]+')
    printf 'PASS  %s (%ss)%s\n' "$cmd" "$secs" "${total:+  [$total tests]}"
  else
    failed=1
    printf 'FAIL  %s (%ss, exit %s)  log: %s\n' "$cmd" "$secs" "$rc" "$log"
    if ! grep -aE "$FAIL_PATTERN" "$log" | awk '!seen[$0]++' | head -n "$MAX_LINES" | sed 's/^/      /' | grep -q .; then
      tail -n 15 "$log" | sed 's/^/      /'
    else
      grep -aE "$FAIL_PATTERN" "$log" | awk '!seen[$0]++' | head -n "$MAX_LINES" | sed 's/^/      /'
    fi
  fi
done

[ "$failed" -eq 0 ] && echo "All $n checks passed." || echo "Logs: $LOG_DIR"
exit "$failed"
