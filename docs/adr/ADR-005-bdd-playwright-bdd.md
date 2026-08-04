# ADR-005 — Tests fonctionnels BDD : playwright-bdd plutôt que @cucumber/cucumber

**Date** : 2026-04-02
**Statut** : Accepté (rétroactif, 2026-04-02 — à signer)
**Sujets liés** : ADR-004 (runner Playwright, réutilisé ici)
**Palier d'outillage** : 3 — écosystème de paquets, assumé et minimisé : `playwright-bdd` (12 dépendances transitives) choisi précisément contre `@cucumber/cucumber` (414 dépendances) pour rester au plus près du palier 2 tout en gardant Gherkin. La comparaison chiffrée est la justification explicite qu'exige ce palier.
**Déclencheur d'irréversibilité** : une fois des scénarios `.feature` écrits en Gherkin et les step definitions codées contre `playwright-bdd`, migrer vers `@cucumber/cucumber` (runner séparé, fixtures incompatibles avec Playwright Test) impose de réécrire l'intégration complète et de dupliquer la configuration CI. Coût > 1 jour dès que plusieurs features existent (3 features / ~11 scénarios dès cette spec, ~30 après la spec du 2026-04-28).

## Contexte

Le plan source construit les tests fonctionnels des deux systèmes de filtre (Saveurs, Mon frigo) plus des smoke tests de navigation, en Gherkin. La section « Key decisions » compare explicitement `playwright-bdd` à `@cucumber/cucumber` sur le critère du nombre de dépendances transitives et de la compatibilité avec les fixtures Playwright déjà en place (ADR-004).

## Décision

**`playwright-bdd`** comme pont Gherkin → Playwright Test. Les `.feature` génèrent des specs Playwright dans `tests/.generated/` (gitignoré, régénéré à chaque run via `bddgen`). Projet mobile-first : `bdd-mobile` (Pixel 5) exécute tous les scénarios en premier, `bdd-desktop` (Desktop Chrome) rejoue en smoke check.

## Alternatives écartées

| Alternative | Raison du rejet | Source |
|---|---|---|
| `@cucumber/cucumber` (direct, sans pont) | ~414 dépendances transitives, runner séparé incompatible avec les fixtures Playwright déjà utilisées pour la régression visuelle (ADR-004) | Plan source, § Key decisions ; README, tableau « Alternatives écartées » (« 414 dépendances → playwright-bdd (12 dépendances) suffit ») |

## Conséquences

- Un seul runner (Playwright Test) pour visuel + fonctionnel — pas de configuration CI dupliquée.
- Scénarios exprimés en Gherkin, lisibles sans connaître le code — mais rédigés et maintenus en anglais dans ce repo (voir écart de convention noté au lot précédent), alors même que les docs projet sont en français.
- Contrainte technique découverte pendant l'implémentation : les checkboxes `display: none` ne sont pas pilotables nativement par Playwright — nécessite `page.evaluate` (corrigé plus tard, spec du 2026-04-28, en faveur d'un clic sur le `<label>` visible, plus fidèle au parcours utilisateur réel).

Source : docs/specs/2026-04-02-1730-bdd-tests/plan.md
