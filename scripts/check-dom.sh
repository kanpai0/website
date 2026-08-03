#!/usr/bin/env bash
# scripts/check-dom.sh — Every DOM selector static/js/fridge.js (and the
# inline bootstrap script in layouts/index.html) reads or writes at runtime
# must exist in the built public/*.html. Checked against the build output,
# not the Hugo templates, so the guarantee also covers whatever a partial
# nesting/whitespace change might do at build time.
#
# Why at build and not at run: the guarantee is static, so fridge.js doesn't
# have to carry defensive "element not found" branches everywhere. A break
# surfaces here, not on the live site.
#
# Called by `make check-dom`. Exits non-zero on any missing selector.
# Requires public/ — run `make build` first (or `make validate`, which
# builds before running checks).

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "$REPO_ROOT/public" ]]; then
  echo "check-dom: public/ not found — run 'make build' first" >&2
  exit 1
fi

fail=0
say_fail() { echo "FAIL: $*" >&2; fail=1; }

# Checks that a public/* file contains every grep pattern given. Content is
# whitespace-normalized (collapsed to a single space) so a single-line
# pattern can match attributes Hugo spreads across several source lines.
check_file_has() {
  local file="$1"
  shift
  if [[ ! -f "$file" ]]; then
    say_fail "$file absent (build missing?)"
    return
  fi
  local content
  content=$(tr -s '[:space:]' ' ' <"$file")
  for pattern in "$@"; do
    if ! grep -q "$pattern" <<<"$content"; then
      say_fail "$file does not contain '$pattern'"
    fi
  done
}

# static/js/fridge.js — filter bootstrap (init/applyFilters/getActive*):
# - #fridge-open / #fridge-panel / #fridge-btn : checkbox-driven panel,
#   toggled + aria-synced by the change listener installed in init().
# - .recipe-card + data-fridge / data-flavors   : read by updateCardVisibility
#   via card.dataset.fridge / card.dataset.flavors.
# - .flavor-cb                                  : change-listener target
#   (saveFlavors), queried via querySelectorAll('.flavor-cb').
# - #filter-summary / #filter-summary-count     : written by updateFilterSummary.
# - #fl-<flavor> for each of the 9 FLAVORS      : read by getActiveFlavors()
#   via getElementById('fl-' + f), and by init() when restoring a selection.
# - `const FRIDGE` / `const FLAVORS`            : globals fridge.js depends
#   on, injected inline by layouts/index.html — must survive the build
#   unexpanded (fridge.js itself declares neither).
check_file_has public/index.html \
  'id="fridge-open"' \
  'id="fridge-panel"' \
  'id="fridge-btn"' \
  'id="filter-summary"' \
  'id="filter-summary-count"' \
  'class="recipe-card' \
  'data-fridge=' \
  'data-flavors=' \
  'class="flavor-cb"' \
  'id="fl-sparkling"' \
  'id="fl-still"' \
  'id="fl-fruity"' \
  'id="fl-tart"' \
  'id="fl-sweet"' \
  'id="fl-spicy"' \
  'id="fl-bitter"' \
  'id="fl-herbaceous"' \
  'id="fl-creamy"' \
  'const FRIDGE' \
  'const FLAVORS'

# Dynamic invariant: `const FRIDGE` is generated from recipe data (Hugo
# ranges over content/recettes/*.md — see layouts/index.html), not from
# fridge-icons.html. A slug with an icon but no `fr-<slug>` checkbox in
# fridge-panel-body.html would compile fine and pass check-content, yet
# getActiveIngredients() would never find it checked — filtering silently
# breaks for that one ingredient. Re-derive FRIDGE from the built page and
# check every entry has a matching input, in that same file.
if [[ -f "$REPO_ROOT/public/index.html" ]]; then
  fridge_line=$(grep -o 'const FRIDGE = \[[^]]*\]' "$REPO_ROOT/public/index.html" || true)
  if [[ -z "$fridge_line" ]]; then
    say_fail "public/index.html: could not find 'const FRIDGE = [...]'"
  else
    content=$(tr -s '[:space:]' ' ' <"$REPO_ROOT/public/index.html")
    while IFS= read -r slug; do
      [[ -n "$slug" ]] || continue
      if ! grep -q "id=\"fr-$slug\"" <<<"$content"; then
        say_fail "public/index.html: FRIDGE entry \"$slug\" has no matching id=\"fr-$slug\" input"
      fi
    done < <(grep -oE '"[^"]*"' <<<"$fridge_line" | tr -d '"')
  fi
fi

# .fridge-hidden : class toggled at runtime by updateCardVisibility — must
# be styled, or the fridge filter silently stops hiding anything.
check_file_has public/css/main.css '\.fridge-hidden'

if ((fail)); then
  echo "check-dom failed" >&2
  exit 1
fi
ok "check-dom"
