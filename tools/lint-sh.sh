#!/usr/bin/env bash
# tools/lint-sh.sh — Lint shell scripts with shellcheck.
# Called by `make lint-sh`. Exits non-zero on any shellcheck violation.
# Requires shellcheck in PATH (mise install).
#
# Scans: tools/*.sh, tools/lib/*.sh, tools/git-hooks/* (extensionless hooks
# included), and scripts/*.sh (content-pipeline scripts, still linted even
# though they live outside tools/).

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

command -v shellcheck >/dev/null \
  || { echo "shellcheck not in PATH — run: mise install" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# bash 3.2 compatible (macOS system bash): no mapfile/readarray — build the
# array with a while-read loop over process substitution instead.
files=()
while IFS= read -r f; do
  files+=("$f")
done < <(
  {
    find "$REPO_ROOT/tools" -maxdepth 1 -name '*.sh'
    find "$REPO_ROOT/tools/lib" -maxdepth 1 -name '*.sh'
    find "$REPO_ROOT/tools/git-hooks" -maxdepth 1 -type f
    find "$REPO_ROOT/scripts" -maxdepth 1 -name '*.sh'
  } | sort
)

# Guard: expanding an empty array under `set -u` is an error on bash 3.2.
if [ "${#files[@]}" -eq 0 ]; then
  echo "lint-sh: no shell scripts found — unexpected, check the find globs" >&2
  exit 1
fi

shellcheck --shell=bash -x "${files[@]}"

ok "lint-sh"
