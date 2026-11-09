# ADR-003 — Outillage de release : git-cliff + bash plutôt que semantic-release

**Date** : 2026-03-31
**Statut** : Accepté (rétroactif, 2026-03-31)
**Décideur** : Vincent Clair
**Sujets liés** : le schéma de version lui-même (SemVer, tags git comme source de vérité) est un standard d'industrie appliqué par défaut — pas un arbitrage, donc pas d'ADR dédiée. La décision porte uniquement sur l'outillage qui le consomme.
**Palier d'outillage** : 2 — binaire autonome (`git-cliff`), retenu explicitement contre le palier 3 (`semantic-release`, 329 paquets npm) après un test réel de l'alternative (branche `feat/semantic-release`).
**Déclencheur d'irréversibilité** : une fois `tools/release.sh` (157 lignes bash) + `cliff.toml` en place comme mécanisme de release et qu'un historique de tags/CHANGELOG existe déjà sous ce format, migrer vers `semantic-release` impose d'introduire un `node_modules` de 329 paquets, de réécrire le pipeline de hooks (`commit-msg`), et de réconcilier le format du changelog existant avec celui du nouvel outil. Coût > 1 jour dès la première release automatisée (déjà taguée en v1.x).

## Contexte

Le plan source est lui-même titré « ADR — Release Tooling » et documente un comparatif direct entre deux approches candidates pour l'automatisation de release d'un site Hugo. Une branche `feat/semantic-release` a été créée pour tester l'alternative avant d'être abandonnée — le renoncement est donc testé, pas seulement supposé.

## Décision

**git-cliff + bash** (`tools/release.sh` + `cliff.toml`). Script interactif : preview du changelog, confirmation `[y/N]` avant tout commit/tag, option `--bump` pour forcer un type de bump, aucun push automatique (ajouté après coup — voir spec du 2026-03-31 18h25).

## Alternatives écartées

| Alternative | Raison du rejet | Source |
|---|---|---|
| `semantic-release` (Node.js) | 329 paquets npm (~6 Mo `node_modules`) pour un site Hugo sans Node au runtime ; pas de confirmation interactive avant tag ; branche `feat/semantic-release` testée puis abandonnée | Plan source (tableau comparatif) + README, tableau « Alternatives écartées » (« 8 263 fichiers npm pour ce que git-cliff fait en 157 lignes de bash ») + `docs/retrospective-manques.md` (arbre de décision, § Release tooling) |

## Conséquences

- 0 dépendance Node pour la release — cohérent avec ADR-001 (Hugo sans pipeline Node).
- Contrôle total du format de changelog via `cliff.toml` (template Tera).
- Contrepartie assumée : script bash maintenu à la main (157 lignes), pas de communauté npm derrière l'outillage — accepté car le volume de release est faible (projet solo).
- Corrections ultérieures tracées dans une spec dédiée (2026-03-31 18h25) : compatibilité bash 3.2 (`mapfile` remplacé), bug de séparateur changelog, suppression du push automatique, suppression d'un fichier `specs/release-notes.md` auto-généré (jamais réintroduit depuis).

Source : docs/specs/2026-03-31-1627-release-tooling-adr/plan.md
