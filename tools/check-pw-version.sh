#!/usr/bin/env bash
# tools/check-pw-version.sh — Fail if the pinned Playwright version drifts.
#
# Compares the version declared in three places:
#   1. package-lock.json   → version actually installed for @playwright/test
#   2. package.json        → .scripts.pw image tag
#   3. .github/workflows/ci.yml → container image tag
#
# Source of truth: package-lock.json, i.e. the version actually installed —
# not the semver range in package.json devDependencies. A caret range (e.g.
# "^1.62.1") can resolve to a newer installed version without package.json
# itself changing, so checking package.json alone can pass while the install
# has drifted.
# Requirements: jq.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# 1. package-lock.json — resolved/installed version (lockfileVersion 2/3 uses
#    .packages, lockfileVersion 1 uses .dependencies; try both)
v_pkg=""
v_pkg="$( jq -r '
    .packages["node_modules/@playwright/test"].version
    // .dependencies["@playwright/test"].version
    // empty
  ' "$REPO_ROOT/package-lock.json" )"

if [[ -z "$v_pkg" ]]; then
  echo "check-pw-version: could not find @playwright/test in package-lock.json" >&2
  exit 1
fi

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
  echo "  package-lock.json (installed) : $v_pkg"
  echo "  package.json scripts.pw       : $v_pw"
  echo "  .github/workflows/ci.yml      : $v_ci"
  echo "Source of truth is the installed version (package-lock.json). Align scripts.pw and ci.yml to v${v_pkg}."
} >&2
exit 1
