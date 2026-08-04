---
name: feedback-bash32-scripts
description: Scripts shell compatibles bash 3.2 (macOS système) — pas de bash 4+
type: feedback
---

# Compatibilité bash 3.2 (macOS système)

**Règle** : tout script `tools/*.sh` doit tourner sous bash 3.2 (macOS système), pas
seulement en CI/Linux (bash 4+/5+). Interdits : `mapfile`, `readarray`, `shopt -s
globstar`, `declare -A`. Autorisés : `shopt -s nullglob` + `for` sur un glob (zéro
itération si vide, pas de tableau) ; `find -print0` + `while IFS= read -r -d ''`.
Piège : un tableau bash vide sous `set -u` (`"${arr[@]}"`) lève « unbound variable »
— les patterns ci-dessus l'évitent sans tableau explicite.

**Why** : macOS livre bash 3.2 par défaut (GPLv3 bloqué par Apple) ; Homebrew/CI
tournent en bash récent. Un script qui passe en CI mais pas sur le poste de Vincent
casse `make validate` en silence, en local.

**How to apply** : deux incidents tracés — `mapfile` dans `scripts/release.sh`
(2026-03-31, `docs/specs/2026-03-31-1825-responsive-grid-release-script/plan.md`),
puis récidive dans `tools/lint-sh.sh` (2026-08-03) : le script passait toutes les
vérifications en sandbox Linux (bash 5) et cassait sur le poste (« mapfile: command
not found »). `bash -n` ne détecte PAS un bashism 4+ ; un environnement de
vérification en bash récent non plus. Relire à l'œil (grep
`mapfile|readarray|declare -A|globstar`) avant de committer.
