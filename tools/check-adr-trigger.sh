#!/usr/bin/env bash
# tools/check-adr-trigger.sh — Refuse an ADR without an explicit
# "Déclencheur d'irréversibilité" field. Adapted from Ikima's
# tools/check-adr-trigger.sh (sibling project, same author).
# Called by `make check-adr-trigger`. Exits non-zero on violation.
#
# bash 3.2 compatible (macOS system bash): no mapfile/readarray/declare -A/
# globstar. Uses a nullglob `for` loop, not an array — an empty glob simply
# yields zero loop iterations, no `${arr[@]}`-under-`set -u` pitfall.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADR_DIR="$REPO_ROOT/docs/adr"

if [[ ! -d "$ADR_DIR" ]]; then
  echo "check-adr-trigger OK (no docs/adr/ yet)"
  exit 0
fi

fail=0

# Scan every ADR-NNN-*.md and assert it carries a non-empty
# "Déclencheur d'irréversibilité" field. The field can appear:
#   - On a single line:   **Déclencheur d'irréversibilité** : <text>
#   - As a header:        ## Déclencheur d'irréversibilité   (with body below)
# The check is loose on form, strict on presence + non-empty body.
shopt -s nullglob
for adr in "$ADR_DIR"/ADR-*.md; do
  # Skip files explicitly marked as superseded (a superseded ADR keeps its
  # frontmatter from when it was accepted; no need to re-validate it).
  if grep -qE '^\*\*Statut\*\* *: *Superseded' "$adr"; then
    continue
  fi

  # Acceptable trigger declarations:
  #   1. inline:    **Déclencheur d'irréversibilité** : ...
  #   2. heading:   (# | ## | ###) Déclencheur d'irréversibilité, followed
  #      within 5 non-empty lines by something other than another heading.
  if grep -qE '^\*\*Déclencheur d.{1,3}irréversibilité\*\* *:.+\S' "$adr"; then
    continue
  fi

  if grep -qE '^#{1,3} +Déclencheur d.{1,3}irréversibilité' "$adr"; then
    body=$(awk '
      /^#{1,3} +Déclencheur d.{1,3}irréversibilité/ { found=1; next }
      found && /^#/ { exit }
      found && /[^[:space:]]/ { print; n++; if (n >= 5) exit }
    ' "$adr")
    if [[ -n "$body" ]]; then
      continue
    fi
  fi

  echo "FAIL: $adr — missing or empty 'Déclencheur d'irréversibilité' field" >&2
  fail=1
done
shopt -u nullglob

if ((fail)); then
  echo "check-adr-trigger failed — every ADR must declare why it is irreversible" >&2
  echo "Add either:" >&2
  echo "  **Déclencheur d'irréversibilité** : <one short paragraph>" >&2
  echo "  or a '## Déclencheur d'irréversibilité' section with a non-empty body." >&2
  exit 1
fi
ok "check-adr-trigger"
