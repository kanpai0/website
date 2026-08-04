# ADR-004 — Outillage de régression visuelle : Playwright

**Date** : 2026-04-02
**Statut** : Accepté (rétroactif, 2026-04-02 — à signer)
**Sujets liés** : ADR-005 (BDD fonctionnel, même runner Playwright)
**Palier d'outillage** : 3 — écosystème de paquets, assumé et borné : première et seule devDependency de test du repo à cette date, aucune dépendance runtime ajoutée au site. Le palier 3 se justifie ici par l'absence d'équivalent palier 1/2 pour la régression visuelle par capture d'écran.
**Déclencheur d'irréversibilité** : une fois ~6 baselines PNG committées (`tests/visual/snapshots/`) et le job CI `visual-regression` bloquant configuré, changer de runner impose de régénérer toutes les baselines sous un autre moteur de rendu (fonts différentes), de réécrire la configuration CI et les scripts npm. Coût > 1 jour dès la première PR bloquée par ce gate (déjà le cas).

## Contexte

Première introduction d'un `package.json` dans le repo (une seule devDependency : `@playwright/test`), pour tester en régression visuelle la page `/design-system/` — 6 sections identifiées par `data-ds`. Le plan source documente le comparatif d'outils dans sa section « Key decisions », ainsi que le choix de Docker pour l'exécution locale (baselines Linux garanties identiques à la CI).

## Décision

**Playwright** (`@playwright/test`), Chromium, exécution locale via Docker (`mcr.microsoft.com/playwright:v1.59.1-jammy`) pour garantir des baselines PNG identiques entre poste dev et CI. Seuil `maxDiffPixelRatio: 0.01`. Aucune régénération de snapshot en CI — toujours locale puis commit.

## Alternatives écartées

| Alternative | Raison du rejet | Source |
|---|---|---|
| Cypress + plugin visual | Régression visuelle nécessite un plugin payant (Percy/Currents) ; Playwright a `toHaveScreenshot()` natif | Plan source, § Key decisions |
| BackstopJS | Plus lourd, configuration JSON-heavy | Plan source, § Key decisions |

## Conséquences

- Premier `package.json` du repo — surface npm à surveiller, strictement limitée aux devDependencies de test (aucun runtime app ajouté).
- Nécessite Docker en local pour générer des baselines cohérentes avec la CI — documenté comme prérequis.
- CI consolidée : le workflow `lighthouse.yml` est renommé `ci.yml` et étendu avec un job `visual-regression` parallèle, bloquant sur PR.
- Base technique réutilisée un mois plus tard pour le BDD fonctionnel (ADR-005) — même runner, même config, pas de second outillage à apprendre.

**État actuel (2026-08)** : le seuil a été resserré à `maxDiffPixelRatio: 0.001` et l'image Docker est passée à `v1.62.1-jammy` depuis cette décision d'origine — les valeurs ci-dessus (`0.01`, `v1.59.1-jammy`) restent celles arbitrées le 2026-04-02 et ne sont pas mises à jour rétroactivement dans le corps de l'ADR.

Source : docs/specs/2026-04-02-1545-visual-regression/plan.md
