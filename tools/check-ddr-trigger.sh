#!/usr/bin/env bash
# tools/check-ddr-trigger.sh — Refuse a DDR (Deferred Decision Record) marked
# Ouverte without an explicit reopening trigger. Adapted from Ikima's
# tools/check-ddr-trigger.sh (sibling project, same author). Renamed
# 2026-08-04: nothing in a DDR is proposed or submitted for comment; it
# records a deferred decision plus its reopening trigger.
# Called by `make check-ddr-trigger`. Exits non-zero on violation.
#
# bash 3.2 compatible (macOS system bash): no mapfile/readarray/declare -A/
# globstar. `find -print0` piped into a `while read -r -d ''` loop avoids
# both mapfile and any array variable — no `${arr[@]}`-under-`set -u` risk.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DDR_DIR="$REPO_ROOT/docs/ddr"

if [[ ! -d "$DDR_DIR" ]]; then
  echo "check-ddr-trigger OK (no docs/ddr/ yet)"
  exit 0
fi

fail=0

# Files to scan: every .md under docs/ddr/, except README.md (index, not
# itself a DDR document).
while IFS= read -r -d '' ddr; do
  base=$(basename "$ddr")
  if [[ "$base" == "README.md" ]]; then
    continue
  fi

  # Only enforce on DDRs whose Statut starts with "Ouvert" (Ouverte/Ouvert).
  # Closed, Différée, etc. don't need a trigger.
  if ! grep -qE '^\*\*Statut\*\* *: *Ouvert' "$ddr"; then
    continue
  fi

  # Acceptable trigger declarations:
  #   - **Déclencheur de réouverture** : ...
  #   - ## Déclencheur de réouverture   (with body below)
  #   - **Déclencheur d'arbitrage** : ... / ## Déclencheur d'arbitrage
  #   - **Conditions de réouverture** : ... / ## Conditions de réouverture
  if grep -qE '^\*\*(Déclencheur d.{1,3}arbitrage|Déclencheur de réouverture|Conditions de réouverture)\*\*' "$ddr"; then
    continue
  fi

  if grep -qE '^#{1,4} +(Déclencheur d.{1,3}arbitrage|Déclencheur de réouverture|Conditions de réouverture)' "$ddr"; then
    continue
  fi

  echo "FAIL: $ddr — DDR ouverte sans déclencheur explicite" >&2
  fail=1
done < <(find "$DDR_DIR" -type f -name '*.md' -print0)

if ((fail)); then
  echo "check-ddr-trigger failed — every open DDR must list its reopening trigger" >&2
  echo "Add a section like:" >&2
  echo "  ## Déclencheur de réouverture" >&2
  echo "  1. <condition>." >&2
  echo "  2. <condition>." >&2
  exit 1
fi
ok "check-ddr-trigger"
