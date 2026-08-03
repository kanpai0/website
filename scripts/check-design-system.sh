#!/usr/bin/env bash
# scripts/check-design-system.sh — Every layouts/partials/*.html must be
# referenced in layouts/_default/design-system.html.
#
# Called by `make check-design-system`. Exits non-zero on violation.
#
# Rule: any UI partial gets a section in the design system, even a single
# hand-duplicated mention — this catches the total oversight, not the shape
# of the documentation. Detection: for each layouts/partials/X.html, look
# for the slug "X" (basename without .html) anywhere in design-system.html
# — a `{{ partial "X.html" }}` call, a comment, or a section label all
# count. Loose by design; strict on presence.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

partials_dir="$REPO_ROOT/layouts/partials"
ds_file="$REPO_ROOT/layouts/_default/design-system.html"

if [[ ! -d "$partials_dir" ]]; then
  echo "check-design-system OK (no $partials_dir yet)"
  exit 0
fi

if [[ ! -f "$ds_file" ]]; then
  echo "FAIL: $ds_file is missing — required by design-system convention" >&2
  exit 1
fi

missing=()
while IFS= read -r -d '' partial; do
  name=$(basename "$partial" .html)
  if ! grep -qF -- "$name" "$ds_file"; then
    missing+=("$name")
  fi
done < <(find "$partials_dir" -maxdepth 1 -type f -name '*.html' -print0)

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "FAIL: partials missing from $ds_file:" >&2
  for name in "${missing[@]}"; do
    echo "  - $name (expected: {{ partial \"$name.html\" }} or a named section/comment)" >&2
  done
  exit 1
fi

ok "check-design-system"
