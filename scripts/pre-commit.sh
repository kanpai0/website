#!/usr/bin/env bash
# Pre-commit quality gate — fast smoke checks (<3s).
# Install: cp scripts/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#
# Checks:
#   1. hugo build --quiet — fails on template/content errors
#   2. fridge[] schema — unknown slugs in recipe frontmatter fail the commit
#   3. flavors[] schema — all flavor slugs in frontmatter must be listed in index.html FLAVORS

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

HUGO="${HUGO_BIN:-$(command -v hugo || echo /opt/homebrew/bin/hugo)}"

# ---------------------------------------------------------------------------
# 1. Hugo build check
# ---------------------------------------------------------------------------
echo "pre-commit: running hugo build..."
if ! "$HUGO" --source "$REPO_ROOT" --quiet 2>&1; then
  echo ""
  echo "ERROR: hugo build failed. Fix template/content errors before committing."
  exit 1
fi
echo "pre-commit: hugo build OK"

# ---------------------------------------------------------------------------
# 2. Fridge schema check
# ---------------------------------------------------------------------------
# Extract valid slugs from fridge-icons.html: id="fi-<slug>" → <slug>
ICONS_FILE="$REPO_ROOT/layouts/partials/fridge-icons.html"
valid_slugs=$(grep -oE 'id="fi-[^"]*"' "$ICONS_FILE" | sed 's/id="fi-//;s/"//')

if [[ -z "$valid_slugs" ]]; then
  echo "ERROR: Could not extract valid slugs from $ICONS_FILE"
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
      echo "ERROR: Unknown fridge slug \"$slug\" in $(basename "$recipe")"
      echo "  Valid slugs: $(echo "$valid_slugs" | tr '\n' ' ')"
      errors=$((errors + 1))
    fi
  done
done < <(find "$REPO_ROOT/content/recettes" -name "*.md")

if [[ $errors -gt 0 ]]; then
  echo ""
  echo "pre-commit: fridge schema check FAILED ($errors error(s))"
  echo "  Add the missing icon to layouts/partials/fridge-icons.html first."
  exit 1
fi

echo "pre-commit: fridge schema OK"

# ---------------------------------------------------------------------------
# 3. Flavors schema check
# ---------------------------------------------------------------------------
# Extract FLAVORS array from index.html (manual display-order list)
INDEX_FILE="$REPO_ROOT/layouts/index.html"
flavors_line=$(grep -E "const FLAVORS\s*=" "$INDEX_FILE" || true)
if [[ -z "$flavors_line" ]]; then
  echo "ERROR: Could not find FLAVORS constant in $INDEX_FILE"
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
      echo "ERROR: Unknown flavor slug \"$slug\" in $(basename "$recipe")"
      echo "  Listed in FLAVORS: $(echo "$valid_flavors" | tr '\n' ' ')"
      errors=$((errors + 1))
    fi
  done
done < <(find "$REPO_ROOT/content/recettes" -name "*.md")

if [[ $errors -gt 0 ]]; then
  echo ""
  echo "pre-commit: flavors schema check FAILED ($errors error(s))"
  echo "  Add the missing flavor to the FLAVORS array in layouts/index.html."
  exit 1
fi

echo "pre-commit: flavors schema OK"
exit 0
