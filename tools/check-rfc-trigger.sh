#!/usr/bin/env bash
# tools/check-rfc-trigger.sh — Refuse a RFC marked Ouverte without an
# explicit reopening trigger. Adapted from Ikima's tools/check-rfc-trigger.sh
# (sibling project, same author).
# Called by `make check-rfc-trigger`. Exits non-zero on violation.
#
# bash 3.2 compatible (macOS system bash): no mapfile/readarray/declare -A/
# globstar. `find -print0` piped into a `while read -r -d ''` loop avoids
# both mapfile and any array variable — no `${arr[@]}`-under-`set -u` risk.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RFC_DIR="$REPO_ROOT/docs/rfc"

if [[ ! -d "$RFC_DIR" ]]; then
  echo "check-rfc-trigger OK (no docs/rfc/ yet)"
  exit 0
fi

fail=0

# Files to scan: every .md under docs/rfc/, except README.md (index, not
# itself an RFC document).
while IFS= read -r -d '' rfc; do
  base=$(basename "$rfc")
  if [[ "$base" == "README.md" ]]; then
    continue
  fi

  # Only enforce on RFCs whose Statut starts with "Ouvert" (Ouverte/Ouvert).
  # Closed, Différée, etc. don't need a trigger.
  if ! grep -qE '^\*\*Statut\*\* *: *Ouvert' "$rfc"; then
    continue
  fi

  # Acceptable trigger declarations:
  #   - **Déclencheur de réouverture** : ...
  #   - ## Déclencheur de réouverture   (with body below)
  #   - **Déclencheur d'arbitrage** : ... / ## Déclencheur d'arbitrage
  #   - **Conditions de réouverture** : ... / ## Conditions de réouverture
  if grep -qE '^\*\*(Déclencheur d.{1,3}arbitrage|Déclencheur de réouverture|Conditions de réouverture)\*\*' "$rfc"; then
    continue
  fi

  if grep -qE '^#{1,4} +(Déclencheur d.{1,3}arbitrage|Déclencheur de réouverture|Conditions de réouverture)' "$rfc"; then
    continue
  fi

  echo "FAIL: $rfc — RFC ouverte sans déclencheur explicite" >&2
  fail=1
done < <(find "$RFC_DIR" -type f -name '*.md' -print0)

if ((fail)); then
  echo "check-rfc-trigger failed — every open RFC must list its reopening trigger" >&2
  echo "Add a section like:" >&2
  echo "  ## Déclencheur de réouverture" >&2
  echo "  1. <condition>." >&2
  echo "  2. <condition>." >&2
  exit 1
fi
ok "check-rfc-trigger"
