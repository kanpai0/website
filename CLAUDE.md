# CLAUDE.md — Kanpai Ø

Lue à chaque session. Garder court.

1. Ne suppose pas. Ne cache pas ta confusion. Expose les tradeoffs.
2. Le minimum de code qui résout le problème. Rien de spéculatif.
3. Touche uniquement à ce qui est nécessaire. Nettoie seulement ton propre désordre.
4. Définis les critères de succès. Boucle jusqu'à validation.

## Le projet

Site de recettes de mocktails (cocktails sans alcool) — Hugo statique, déployé sur
[kanpai0.co](https://kanpai0.co). Projet perso **et** vitrine technique assumée (cf.
`README.md`) : décisions tracées, tests de régression visuelle bloquants, release
sans dépendance superflue.

Sources de vérité : `README.md`, `docs/adr/`, `docs/ddr/`, `docs/dev-process/`, `docs/specs/`.

## Trois principes ancrés

Détail complet : [`docs/dev-process/PROCESS.md`](docs/dev-process/PROCESS.md).

### 1. Ship-by-default

Le défaut, c'est **coder et livrer**. Un ADR n'est écrit que si la décision est
**irréversible en plus d'une journée de retravail**. Garde-fou mécanique :
`make check-adr-trigger` refuse un ADR sans `Déclencheur d'irréversibilité` non vide.

### 2. Architect sous condition

Un modèle costaud (Opus) n'est convoqué **qu'en exception, jamais en réflexe** —
seulement si la décision est irréversible (principe 1) ET que des options sont
réellement contestées. Sinon : décision dans le fil, en 3 lignes. Pas de fiche
agent dédiée sur ce repo (solo, pas d'équipe à outiller). Sortie max 1 page,
scorecard interdite par défaut — cf. `make check-scorecard`.

### 3. DDR = décision différée avec déclencheur

Une DDR enregistre une question vue passer, pourquoi elle n'est pas traitée
maintenant, et un **déclencheur de réouverture** explicite. Rien n'y est proposé
ni soumis à commentaires. Jamais inflatée en ADR sans qu'un déclencheur soit
franchi. Garde-fou : `make check-ddr-trigger`.

## Commandes

```bash
make bootstrap      # fresh clone: mise install + npm ci + git hooks
make install-hooks  # (re)install git hooks from tools/git-hooks/

hugo serve          # Local dev server with hot reload
hugo build          # Generate static site to public/

make serve          # alias → hugo serve
make build          # alias → hugo build
make release        # bump version, generate CHANGELOG, commit + tag (no push — printed to run manually)
make release-dry    # preview release without writing anything
make preflight      # full local quality gate before pushing (npm test)
make validate       # pre-commit gate: hugo build + 10 checks (shell, Playwright pin, content schema, DOM, design system, ADR/DDR/scorecard gates, unit tests)
make validate-ci    # CI fan-out of the same checks, no hugo build (public/ comes from the build job's artifact)
make check-sh       # syntax-check all shell scripts (bash -n)
make lint-sh        # lint all shell scripts (shellcheck)
make check-pw-version # verify Playwright version pinned consistently (package.json + CI)
make doctor         # show pinned versions + latest available Hugo
```

Outillage épinglé dans `.mise.toml` (Hugo, Node, Python, git-cliff, shellcheck, jq,
yq), installé par `mise` (Docker hors mise, image Playwright épinglée dans
`package.json`). `tools/release.sh` : bump SemVer via Conventional Commits
(`git-cliff`), commit + tag local, **aucun push automatique** ; notes de release =
`CHANGELOG.md`, pas de fichier dédié par release. Hooks (`tools/git-hooks/`,
installés par `make install-hooks`) : `pre-commit` = `make validate` ;
`commit-msg` impose Conventional Commits.

## Architecture

Site Hugo statique — pas de Node.js, pas de pipeline de build au-delà de `hugo`.
Déploiement automatique sur push `main` (GitHub Actions → Cloudflare Pages, cf.
`docs/adr/ADR-001`).

```
src/
  content/recettes/  # 24 fiches recette markdown (source de vérité)
  layouts/            # Templates Hugo
    index.html        # Home : grille recettes + panel frigo + JS de filtrage
    recettes/single.html  # Page recette individuelle
    partials/
      fridge-icons.html      # Sprite SVG (~25 icônes ingrédient/spiritueux)
      fridge-panel-body.html # Panel du filtre frigo
  static/css/main.css # Tous les styles (~350 lignes, zéro framework)
  static/images/recettes/  # Photos WebP des cocktails
tools/               # Process repo : check-*, lib/, git-hooks/, release.sh, preflight.sh
scripts/             # Pipelines de contenu : Python + download-recipe-images.sh
docs/
  adr/               # 5 ADR tranchées (déclencheur d'irréversibilité)
  ddr/               # 5 DDR différées (déclencheur de réouverture)
  specs/             # 28 plans d'implémentation horodatés (historique de fabrication)
  design/, sources/  # Maquettes Pencil, HTML sources scrapés
```

Frontmatter d'une recette :
```yaml
---
title: Mojito
slug: mojito
draft: false
fridge: ["rhum", "citron-vert", "agave", "menthe", "petillante"]
source_image: "https://..."
source_url: "https://..."
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"
---
```

**Invariant frigo** : les valeurs de `fridge[]` doivent correspondre à
`id="fi-<slug>"` dans `fridge-icons.html` **et** `id="fr-<slug>"` dans
`fridge-panel-body.html` — les deux contrôlés par `check-content`. Ajouter un
ingrédient = 3 étapes : (1) `<symbol>` dans `fridge-icons.html`, (2) `<label>`
dans `fridge-panel-body.html`, (3) mettre à jour les recettes qui l'utilisent.

**Filtrage** (home) : vanilla JS + `localStorage`, pas de framework. Chaque carte
porte `data-fridge="rhum citron-vert menthe"` ; le panel frigo coche les
ingrédients disponibles, les cartes sans correspondance prennent `.fridge-hidden`.
L'indicateur du bouton frigo utilise le pseudo-sélecteur CSS `:has()`.

**Tokens design** (`main.css`) : `--bg` #F7F4EE, `--ink` #1A1A18, `--sage` #3D5A3E
(accent), `--muted` #6B6860, `--border` #E8E3D8. Playfair Display (titres,
italique), Inter (corps). Mobile-first, `clamp()` pour le texte responsive.

**Déploiement** : push `main` → GitHub Actions build avec la version Hugo épinglée
dans `.mise.toml`, puis déploie `public/` sur Cloudflare Pages via `wrangler`.
Domaine `kanpai0.co` (301 depuis `kanpai0.com`).

## En codant

- Vanilla JS, pas de framework.
- Logique dans des modules testés, pas dans le shell — le script shell reste de la
  colle (jq, hugo, wrangler…), l'algorithme vit dans un module Node testé.
  Précédents : `tools/lib/frontmatter.mjs`, `static/js/fridge.js`.
- Parser à la frontière une fois, puis faire confiance : `localStorage` via
  `parseStoredFridge`, frontmatter via `yq` + `validateRecipe`. Pas de
  re-validation à chaque lecture.
- Unions discriminées, jamais `null` dans les modèles.
- Pas de nouvelle dépendance sans justification de palier (cf.
  `docs/dev-process/PROCESS.md` §Paliers d'outillage).
- Scripts bash compatibles bash 3.2 (macOS) : pas de `mapfile` / `readarray` /
  `globstar` / `declare -A` ; garder un tableau vide valide sous `set -u`.

## Fin de tâche — checklist

1. `make validate` vert ?
2. Tests écrits dans la même diff que le code ?
3. Sections pertinentes de `docs/QUALITY_CHECKLIST.md` relues ?
4. Changement visuel intentionnel → `npm run test:update` + baselines committées ?
5. Décision prise → ADR, DDR ou message de commit, selon la grille (PROCESS.md §Triage) ?
6. `docs/dev-process/memory/` à jour si une préférence dev a émergé ?

## Refus automatiques

- ADR sans irréversibilité avérée (> 1 jour de retravail).
- DDR ouverte sans déclencheur de réouverture.
- Nouvelle dépendance sans justification de palier.
- « Fais le test après l'implémentation. »
- Commit englobant plusieurs intentions.
- Bashism 4+ dans un script (bash 3.2 requis).
- Scorecard sans colonne « Critère ».

## Mémoire long terme

- Décision tranchée et irréversible → `docs/adr/ADR-NNN-titre.md`.
- Question différée → `docs/ddr/DDR-NNN-titre.md`.
- Plan de feature → `docs/specs/<date>-<slug>/plan.md`.
- Conventions / préférences dev versionnées → `docs/dev-process/memory/*.md` —
  **à lire en début de session**.
- Suivi du transfert de méthode Ikima → Kanpai → `docs/dev-process/ikima-methods.md`.

## Communication

- Doc projet et conversations en français ; code, scripts, commits, tests en anglais.
- Concision, pas de préambule.
