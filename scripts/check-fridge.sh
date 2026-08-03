#!/usr/bin/env bash
# scripts/check-fridge.sh — fridge[] schema check.
# Called by `make check-fridge` (part of `make validate`).
# Fails if a recipe's fridge[] array references a slug that has no
# matching id="fi-<slug>" in layouts/partials/fridge-icons.html.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ---------------------------------------------------------------------------
# Fridge schema check
# ---------------------------------------------------------------------------
# Extract valid slugs from fridge-icons.html: id="fi-<slug>" → <slug>
ICONS_FILE="$REPO_ROOT/layouts/partials/fridge-icons.html"
valid_slugs=$(grep -oE 'id="fi-[^"]*"' "$ICONS_FILE" | sed 's/id="fi-//;s/"//')

if [[ -z "$valid_slugs" ]]; then
  echo "FAIL: Could not extract valid slugs from $ICONS_FILE" >&2
  exit 1
fi

errors=0
while IFS= read -r recipe; do
  # Extract fridge array values: matches both ["a", "b"] and [a, b] formats
  fridge_line=$(grep -E '^fridge:' "$recipe" || true)
  if [[ -z "$fridge_line" ]]; then
    continue
  fi
  # Extract quoted values from the array
  slugs_in_recipe=$(echo "$fridge_line" | grep -oE '"[^"]*"' | tr -d '"')
  for slug in $slugs_in_recipe; do
    if ! echo "$valid_slugs" | grep -qx "$slug"; then
      echo "FAIL: Unknown fridge slug \"$slug\" in $(basename "$recipe")" >&2
      echo "  Valid slugs: $(echo "$valid_slugs" | tr '\n' ' ')" >&2
      errors=$((errors + 1))
    fi
  done
done < <(find "$REPO_ROOT/content/recettes" -name "*.md")

if [[ $errors -gt 0 ]]; then
  echo "FAIL: fridge schema check FAILED ($errors error(s))" >&2
  echo "  Add the missing icon to layouts/partials/fridge-icons.html first." >&2
  exit 1
fi

ok "check-fridge"
