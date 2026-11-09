# ADR-002 — CSS custom plutôt qu'un framework (PicoCSS)

**Date** : 2026-03-24
**Statut** : Accepté (rétroactif, 2026-03-24)
**Décideur** : Vincent Clair
**Palier d'outillage** : 0/1 — plateforme native (CSS custom, aucun framework, aucun paquet). Cohérent avec « Pas de framework JS. » déjà écrit dans le BRIEF jour 1 (`4597ac9`) — le même principe de sobriété s'applique ici au CSS.
**Déclencheur d'irréversibilité** : une fois la charte graphique (couleurs, typographies Playfair/Inter, layout non-scrollable `100dvh`) codée en CSS custom et appliquée à la home puis à chaque page ajoutée (recette, design system, 404, about), migrer vers un framework CSS impose de réécrire toutes les classes et de résoudre les conflits de reset avec l'existant. Coût déjà > 1 jour dès que plusieurs pages/composants partagent la même base de tokens (le cas dès la 2ᵉ page).

## Contexte

Le plan source (`charte-visuelle`, 2026-03-24) fixe la charte graphique complète — palette, typographies, layout non-scrollable, carte ingrédients flottante — et liste les fichiers produits : `layouts/index.html`, `static/css/main.css`, une image générée. Le plan ne mentionne pas explicitement PicoCSS ni de comparaison de frameworks ; il documente uniquement le résultat retenu (CSS custom).

PicoCSS n'était pourtant pas un oubli : c'était une option planifiée du BRIEF jour 1 (`4597ac9`, tableau « Stack technique » : « HTML sémantique stylé nativement »). Le renoncement de fait est daté par l'historique git — commit `10cae5a` (2026-03-24, 15h32), même jour que ce plan : la première (et unique, à l'époque) fiche recette est codée directement en CSS custom (`static/css/main.css`, 161 lignes), sans jamais intégrer PicoCSS. Le choix n'a plus été revisité ensuite — PicoCSS disparaît du README sans que son utilité soit justifiée.

## Décision

CSS custom (`static/css/main.css`), sans framework. Palette et typographies figées dans des variables CSS (`--bg`, `--ink`, `--sage`, `--muted`, `--border`), Playfair Display italic pour les titres, Inter pour le corps.

## Alternatives écartées

| Alternative | Raison du rejet | Source |
|---|---|---|
| PicoCSS | Reset non voulu, conventions conflictuelles → CSS custom retenu | README, tableau « Alternatives écartées » ; confirmé par `docs/retrospective-manques.md` (« l'abandon de PicoCSS… jamais intégré ») |

**Arbitrage non tracé au moment où il a eu lieu** : ni le plan `charte-visuelle` ni aucune spec ne documentent explicitement la décision de renoncer à PicoCSS — c'était encore une « prochaine étape » dans le plan précédent, puis silencieusement remplacée. L'historique git permet désormais de dater ce renoncement (`10cae5a`, 2026-03-24) sans avoir à inventer un rationale : le README et la rétrospective confirment le résultat final, l'historique git confirme le moment. Cette ADR formalise donc un renoncement implicite, jamais écrit au moment où il a eu lieu — exactement le manque de méthode identifié en rétrospective (§5, « pas de post-mortem documenté »), désormais daté plutôt que simplement constaté.

## Conséquences

- 350 lignes de CSS custom, contrôle total, aucune dépendance de reset à défaire.
- Toute nouvelle page hérite des mêmes tokens (`--bg`, `--ink`, `--sage`…) — cohérence visuelle automatique.
- Pas de mécanisme de mise à jour de framework à surveiller (sécurité, breaking changes).

Source : docs/specs/2026-03-24-1620-charte-visuelle/plan.md
