#!/usr/bin/env bash
# scripts/lint-sh.sh — Lint shell scripts with shellcheck.
# Called by `make lint-sh`. Exits non-zero on any shellcheck violation.
# Requires shellcheck in PATH (mise install).

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

command -v shellcheck >/dev/null \
  || { echo "shellcheck not in PATH — run: mise install" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

shellcheck --shell=bash -x "$REPO_ROOT"/scripts/*.sh "$REPO_ROOT"/scripts/lib/*.sh

ok "lint-sh"
