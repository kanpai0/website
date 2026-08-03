#!/usr/bin/env bash
# scripts/check-flavors.sh — flavors[] schema check.
# Called by `make check-flavors` (part of `make validate`).
# Fails if a recipe's flavors[] array references a slug that is not
# listed in the FLAVORS constant in layouts/index.html.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ---------------------------------------------------------------------------
# Flavors schema check
# ---------------------------------------------------------------------------
# Extract FLAVORS array from index.html (manual display-order list)
INDEX_FILE="$REPO_ROOT/layouts/index.html"
flavors_line=$(grep -E "const FLAVORS\s*=" "$INDEX_FILE" || true)
if [[ -z "$flavors_line" ]]; then
  echo "FAIL: Could not find FLAVORS constant in $INDEX_FILE" >&2
  exit 1
fi
valid_flavors=$(echo "$flavors_line" | grep -oE "'[^']*'" | tr -d "'")

errors=0
while IFS= read -r recipe; do
  flavors_line_fm=$(grep -E '^flavors:' "$recipe" || true)
  if [[ -z "$flavors_line_fm" ]]; then
    continue
  fi
  slugs_in_recipe=$(echo "$flavors_line_fm" | grep -oE '"[^"]*"' | tr -d '"')
  for slug in $slugs_in_recipe; do
    if ! echo "$valid_flavors" | grep -qx "$slug"; then
      echo "FAIL: Unknown flavor slug \"$slug\" in $(basename "$recipe")" >&2
      echo "  Listed in FLAVORS: $(echo "$valid_flavors" | tr '\n' ' ')" >&2
      errors=$((errors + 1))
    fi
  done
done < <(find "$REPO_ROOT/content/recettes" -name "*.md")

if [[ $errors -gt 0 ]]; then
  echo "FAIL: flavors schema check FAILED ($errors error(s))" >&2
  echo "  Add the missing flavor to the FLAVORS array in layouts/index.html." >&2
  exit 1
fi

ok "check-flavors"
