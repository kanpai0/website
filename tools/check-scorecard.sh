#!/usr/bin/env bash
# tools/check-scorecard.sh — Refuse une scorecard sans colonne "Critère".
# Adapté du tools/check-scorecard.sh d'Ikima (projet jumeau, même auteur).
# Appelé par `make check-scorecard`. Sort non-zéro à la première violation.
#
# Règle : si un ADR contient une scorecard (détectée par la présence de la
# chaîne "Score pondéré" dans un tableau Markdown), ce tableau doit comporter
# une colonne d'entête "Critère" (ou variantes : "Criterion", "Criteria",
# "Critère (poids)").
#
# Ce qui est *autorisé* :
#   - Une scorecard à 2 options : c'est OK.
#   - Pas de scorecard du tout dans l'ADR : c'est OK aussi (la justification
#     peut être en prose).
#
# Ce qui est *refusé* :
#   - Une scorecard avec un total "Score pondéré" mais sans colonne
#     "Critère" en entête → table de vibe-check, pas une comparaison
#     contrainte. Refus.
#
# bash 3.2 compatible (macOS système) : pas de mapfile/readarray/
# declare -A/globstar. `for` sur un glob nullglob, pas de tableau bash — un
# glob vide donne zéro itération, aucun risque de "${arr[@]}" sous `set -u`.

set -euo pipefail
# shellcheck source=SCRIPTDIR/lib/ok.sh
. "$(dirname "$0")/lib/ok.sh"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADR_DIR="$REPO_ROOT/docs/adr"

if [[ ! -d "$ADR_DIR" ]]; then
  echo "check-scorecard OK (no docs/adr/ yet)"
  exit 0
fi

fail=0

# Pour chaque ADR :
#   1. trouver les lignes contenant "Score pondéré" dans un row de tableau
#      (commence par `|`).
#   2. pour chacune, remonter au header du tableau (premier row `|...|`
#      avant la ligne `|---|---|...`) et vérifier qu'il contient
#      "Critère"/"Criterion"/"Criteria".
shopt -s nullglob
for adr in "$ADR_DIR"/ADR-*.md; do
  awk -v file="$adr" '
    BEGIN { in_table = 0; header = ""; rc = 0 }

    /^\|/ {
      if (!in_table) {
        header = $0
        in_table = 1
        next
      }
      if ($0 ~ /^\|[- :|]+\|[- :|]*\|?[ \t]*$/) {
        next
      }
      if ($0 ~ /Score pondéré/) {
        if (header !~ /Critère|Criterion|Criteria/) {
          printf("FAIL: %s — scorecard sans colonne \"Critère\" en entête (header observé : %s)\n", file, header) > "/dev/stderr"
          rc = 1
        }
      }
      next
    }

    /^[^|]/ { in_table = 0; header = "" }

    END { exit rc }
  ' "$adr" || fail=1
done
shopt -u nullglob

if ((fail)); then
  echo "check-scorecard failed — toute scorecard doit comparer des options contre des critères explicites." >&2
  echo "Ajoute une colonne \"Critère\" dans l'entête, ou retire le total \"Score pondéré\" et écris la décision en prose." >&2
  exit 1
fi
ok "check-scorecard"
