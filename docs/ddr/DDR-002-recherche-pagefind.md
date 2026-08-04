# DDR-002 — Recherche Pagefind

**Statut** : Ouverte

## Contexte

Pagefind (recherche full-text côté client) a été évalué très tôt dans le
projet (la spec `minimal-website` du 2026-03-23 listait « Configurer Pagefind
pour la recherche » comme prochaine étape), puis jamais intégré. Le README
documente ce renoncement dans son tableau « Alternatives écartées » :
« Pagefind | 24 recettes = recherche inutile, le filtre frigo suffit ».

Pagefind était même déjà planifié le jour 1 : `BRIEF.md` (commit `4597ac9`,
2026-03-23) le retient comme choix de recherche — « Index statique, zéro
serveur ». Il n'a jamais été intégré, puis a été écarté formellement dans le
README avec le rationale ci-dessus.

## Pistes envisagées (non tranchées)

Aucune piste alternative n'a été formalisée — le filtre frigo (`docs/adr/`
n'en fait pas une ADR, c'est une fonctionnalité produit, pas une décision
d'architecture) couvre le besoin de découverte de recette à la volumétrie
actuelle.

## Déclencheur de réouverture

1. Le catalogue dépasse ~50 recettes.
2. Le filtre frigo (ingrédients) ne suffit plus à retrouver une recette précise — par exemple recherche par nom ou par note libre.

Source : README.md (§ « Alternatives écartées ») ; docs/specs/2026-03-23-1645-minimal-website/plan.md.
