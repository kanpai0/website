---
name: feedback-logique-modules-pas-shell
description: L'algorithme vit dans un module Node testé, le shell reste de la colle
type: feedback
---

# Logique dans des modules testés, pas dans le shell

**Règle** : un script shell orchestre (jq, hugo, wrangler, git…) ; toute logique —
branchement, comptage, validation de forme — vit dans un module Node pur, testé par
`node --test`. Un script qui grep/sed pour décider quelque chose est un signal à extraire.

**Why** : un script bash n'est pas testable à la même granularité qu'un module ; la
complexité s'y cache sans garde-fou (pas de lint de complexité sur du bash).

**How to apply** — précédents tracés :

- **Validation frontmatter** : les greps bash du hook pre-commit remplacés par
  `tools/lib/frontmatter.mjs` (validation sémantique pure, testée) + extraction `yq`
  pour le parsing brut — pas de parseur YAML maison en shell (lot B.10, révisé lot 5).
- **Filtrage frigo** : la logique pure (matching ingrédients, unions discriminées,
  jamais de throw sur état corrompu) vit dans `static/js/fridge.js`, testée via
  `node:vm` — pas dans un script de build.
