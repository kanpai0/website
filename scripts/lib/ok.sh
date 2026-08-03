#!/usr/bin/env bash
# scripts/lib/ok.sh — Sourced by scripts/check-*.sh and scripts/lint-sh.sh.
# Sets _OK_START at source time and exposes ok() to print a timed success line.
#
# Usage:
#   . "$(dirname "$0")/lib/ok.sh"
#   ...
#   ok "check-foo"
#
# Output: \033[32m✓\033[0m check-foo \033[90mXms\033[0m

if [[ -n ${EPOCHREALTIME+x} ]]; then
  _OK_START=$(awk "BEGIN{printf \"%d\", $EPOCHREALTIME * 1000}")
  ok() {
    local elapsed
    elapsed=$(awk "BEGIN{printf \"%d\", $EPOCHREALTIME * 1000 - $_OK_START}")
    printf '\033[32m✓\033[0m %s \033[90m%dms\033[0m\n' "$1" "$elapsed"
  }
else
  _OK_START=$(node -p "Date.now()")
  ok() {
    local now elapsed
    now=$(node -p "Date.now()")
    elapsed=$(( now - _OK_START ))
    printf '\033[32m✓\033[0m %s \033[90m%dms\033[0m\n' "$1" "$elapsed"
  }
fi
