#!/usr/bin/env bash
# scripts/check-sh.sh — Syntax-check all shell scripts via bash -n.
# Called by `make check-sh`. Exits non-zero on first syntax error.
#
# Scans: scripts/*.sh and scripts/lib/*.sh.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

find "$REPO_ROOT/scripts" "$REPO_ROOT/scripts/lib" -maxdepth 1 -name '*.sh' \
  | sort | while read -r f; do bash -n "$f"; done

ok "check-sh"
