#!/usr/bin/env bash
# tools/check-sh.sh — Syntax-check all shell scripts via bash -n.
# Called by `make check-sh`. Exits non-zero on first syntax error.
#
# Scans: tools/*.sh, tools/lib/*.sh, tools/git-hooks/* (extensionless hooks
# included), and scripts/*.sh (content-pipeline scripts, still linted even
# though they live outside tools/).

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

{
  find "$REPO_ROOT/tools" -maxdepth 1 -name '*.sh'
  find "$REPO_ROOT/tools/lib" -maxdepth 1 -name '*.sh'
  find "$REPO_ROOT/tools/git-hooks" -maxdepth 1 -type f
  find "$REPO_ROOT/scripts" -maxdepth 1 -name '*.sh'
} | sort | while read -r f; do bash -n "$f"; done

ok "check-sh"
