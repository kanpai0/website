#!/usr/bin/env bash
# scripts/check-pw-version.sh — Fail if the pinned Playwright version drifts.
#
# Compares the version declared in three places:
#   1. package.json        → .devDependencies["@playwright/test"]
#   2. package.json        → .scripts.pw image tag
#   3. .github/workflows/ci.yml → container image tag
#
# Source of truth: package.json devDependencies. All three must match.
# Requirements: jq.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# 1. package.json devDependencies — strip leading ^ or ~
v_pkg=""
v_pkg="$( jq -r '.devDependencies["@playwright/test"]' "$REPO_ROOT/package.json" | sed 's/^[~^]//' )"

# 2. package.json scripts.pw — extract X.Y.Z from the playwright:vX.Y.Z-jammy image tag
v_pw=""
v_pw="$( jq -r '.scripts.pw' "$REPO_ROOT/package.json" | grep -oE 'playwright:v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/.*v//' )"

# 3. .github/workflows/ci.yml — same pattern
v_ci=""
v_ci="$( grep -oE 'playwright:v[0-9]+\.[0-9]+\.[0-9]+' "$REPO_ROOT/.github/workflows/ci.yml" | head -1 | sed 's/.*v//' )"

if [[ "$v_pkg" == "$v_pw" && "$v_pkg" == "$v_ci" ]]; then
  ok "check-pw-version"
  exit 0
fi

{
  echo "FAIL: Playwright version drift detected"
  echo "  package.json devDependencies : $v_pkg"
  echo "  package.json scripts.pw      : $v_pw"
  echo "  .github/workflows/ci.yml     : $v_ci"
  echo "Source of truth is package.json devDependencies. Align scripts.pw and ci.yml to v${v_pkg}."
} >&2
exit 1
