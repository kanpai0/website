# Process — Développement Kanpai Ø

Comment ce repo est développé. Décrit ce qui **est**, pas un process
aspirationnel — pas d'étape inventée qui n'a jamais eu lieu.

Les **trois principes ancrés** sont dans `AGENTS.md`. Ce document en
donne la version détaillée. En cas de contradiction, `AGENTS.md` prime.

---

## Workflow

Solo, pas d'équipe. Commits **directs sur `main`** — pas de PR
obligatoire (décision 2026-08-03 : « pas de PR obligatoire en flux
solo ; tout le reste [ruleset, squash-only, template PR] en découlait »).

- **Hook `pre-commit`** = `make validate` (10 checks, cf. §Le gate).
- **Hook `commit-msg`** = Conventional Commits obligatoire (requis par
  `git-cliff` pour calculer le bump de version).
- **Push `main`** → CI GitHub Actions : `build` (une seule fois,
  artefact `public/`) → `validate` + `visual-regression` en parallèle
  → `deploy` (gated par les deux, Cloudflare Pages via `wrangler`) →
  `lighthouse` (post-deploy, sur le site réel — pas avant, sinon on
  auditerait la version précédente).
- **Release** : `bash tools/release.sh` — bump SemVer automatique
  (breaking→major, feat→minor, sinon patch), preview + confirmation
  `[y/N]`, commit + tag **local**, aucun push automatique (la commande
  `git push` s'affiche pour lancement manuel).

Hooks versionnés dans `tools/git-hooks/`, (ré)installés par
`make install-hooks` (aussi fait par `make bootstrap`).

---

## Les trois principes ancrés (détail)

### 1. Ship-by-default

Le défaut est de coder et déployer. Une ADR n'existe que si le retour
en arrière coûte **plus d'une journée de retravail**. En-dessous : la
décision se prend, et se change, en message de commit.

Refus type observés en triant les 28 specs historiques (`docs/specs/`,
lot F.29) :

- **Schéma de version SemVer** — pas une ADR : c'est un standard
  d'industrie appliqué par défaut, pas un arbitrage entre options
  (cf. `docs/adr/ADR-003` §Sujets liés).
- **Réorganisation des répertoires** (2026-04-15,
  `docs/specs/2026-04-15-0930-directory-layout/`) — refus type
  « structure de dossiers » : réversible en une session, reste un plan.
- **Abandon du support PWA** — réversible à faible coût, piloté par un
  signal produit (usage mobile mesuré) plutôt qu'un verrou technique →
  devient une DDR (`docs/ddr/DDR-004-mode-offline-pwa.md`), pas une ADR.

Garde-fou mécanique : `make check-adr-trigger` refuse un ADR sans champ
`Déclencheur d'irréversibilité` non vide.

### 2. Architect sous condition

Un modèle costaud (Opus) n'est convoqué **qu'en exception, jamais en
réflexe**, et seulement si :

- la décision est irréversible (test du principe 1) ET
- soit deux options sont réellement contestées (écart pressenti faible),
  soit le problème dépasse manifestement un arbitrage en 3 lignes.

Pour tout le reste : décision dans le fil de la session. Pas de fiche
agent dédiée sur ce repo (contrairement à Ikima 1, qui a une équipe de
sous-agents) — un modèle costaud est invoqué au cas par cas, jamais
comme sous-agent permanent. Sortie attendue : un plan numéroté ou une
ADR/DDR, **max 1 page**. Scorecard interdite par défaut (cf. Annexe A).

### 3. DDR = décision différée avec déclencheur

Une DDR (Deferred Decision Record) enregistre une question vue passer,
pourquoi elle n'est pas traitée maintenant, et un **déclencheur de
réouverture** explicite et numéroté. Rien n'y est proposé ni soumis à
commentaires — c'est ce qui la distingue d'une RFC au sens classique.
Une DDR n'est **jamais inflatée en ADR** sans qu'un déclencheur ait été
franchi. Garde-fou : `make check-ddr-trigger` refuse une DDR au statut
`Ouvert*` sans déclencheur.

---

## Grille de triage : décision / différé / plan

Face à un sujet nouveau, trois destinations possibles — jamais un
quatrième panier « je ne sais pas » :

| Question | Destination | Format |
|---|---|---|
| Retour en arrière > 1 jour de retravail ? | **ADR** (`docs/adr/ADR-NNN-titre.md`) | Contexte, décision, alternatives écartées, `Déclencheur d'irréversibilité` |
| Question identifiée, pas encore tranchée, avec conditions de réouverture ? | **DDR** (`docs/ddr/DDR-NNN-titre.md`) | Contexte, pistes envisagées, `Déclencheur de réouverture` |
| Un « comment » d'implémentation, réversible, sans arbitrage entre options ? | **Plan** (`docs/specs/<date>-<slug>/plan.md`) | Ce qui a été construit, sans verrou de sortie |

Le critère unique qui sépare ADR du reste : **> 1 jour de retravail
pour revenir en arrière**. Tout le reste est un plan ou une DDR.

---

## Paliers d'outillage

1. **Natif POSIX / plateforme** — bash, `find`, `grep`, `awk`, `jq`,
   `node --test`, `make`, `git`. Rien à installer.
2. **Binaire autonome ciblé** — un seul exécutable, zéro arbre de
   dépendances transitives (`hugo`, `git-cliff`, `yq`, `shellcheck`).
3. **Écosystème de paquets** — `node_modules`. Exige une justification
   explicite : pourquoi les paliers 1 et 2 ne suffisent pas.

Précédents concrets sur ce repo :

- **`git-cliff` (palier 2) retenu contre `semantic-release` (palier 3,
  329 paquets npm)** — alternative réellement testée sur une branche
  `feat/semantic-release` avant d'être abandonnée (`docs/adr/ADR-003`).
- **`yq` (palier 2) retenu contre un parseur YAML maison** (295 lignes,
  v1) — révisé le 2026-08-03 sur push-back de Vincent : `frontmatter.mjs`
  réduit à la validation sémantique pure, l'extraction passe par `yq`
  (mikefarah, épinglé `mise`, `--front-matter=extract`).
- **`playwright-bdd` = palier 3 assumé et borné** — 12 dépendances
  transitives contre 414 pour `@cucumber/cucumber` direct, choisi
  précisément pour rester au plus près du palier 2 (`docs/adr/ADR-005`).
- **Biome écarté** — faute d'irritant mesuré (frugalité : pas de dette
  d'outillage résolue, pas d'ADR ni de DDR nécessaire pour un refus).

---

## Le gate `make validate`

Dix checks, fan-out parallèle (`gmake -j --output-sync=target`) après
un `hugo build --quiet` :

| Check | Garantit | Source |
|---|---|---|
| `check-sh` | Chaque script shell est syntaxiquement valide (`bash -n`) | `tools/check-sh.sh` |
| `lint-sh` | Scripts shell lintés (`shellcheck`) | `tools/lint-sh.sh` |
| `check-pw-version` | Version Playwright alignée aux 3 points d'épinglage | `tools/check-pw-version.sh` |
| `check-content` | Frontmatter des recettes valide (fridge/flavors/glass/color) | `tools/check-content.mjs` (extraction `yq` + `validateRecipe`) |
| `check-dom` | `public/` contient tous les sélecteurs consommés par `fridge.js` | `tools/check-dom.sh` |
| `check-design-system` | Chaque partial a sa section dans `design-system.html` | `tools/check-design-system.sh` |
| `check-adr-trigger` | Chaque ADR déclare son déclencheur d'irréversibilité | `tools/check-adr-trigger.sh` |
| `check-ddr-trigger` | Chaque DDR ouverte déclare son déclencheur de réouverture | `tools/check-ddr-trigger.sh` |
| `check-scorecard` | Toute scorecard (« Score pondéré ») a une colonne « Critère » | `tools/check-scorecard.sh` |
| `test-unit` | Tests unitaires `node --test` verts | `tests/unit/*.test.mjs` |

Détail des vérifications manuelles (a11y, design system, legal) :
[`docs/QUALITY_CHECKLIST.md`](../QUALITY_CHECKLIST.md).

**Hors `make validate`** : les tests d'acceptation Playwright (visual +
BDD) requièrent Docker et un build — ils tournent dans le job
`visual-regression` de la CI, pas dans le hook pre-commit.

---

## Conventions

- **Bilingue** (tranché 2026-08-04) : doc projet et conversations en
  français ; code, scripts, commits, tests en anglais. Le README
  vitrine reste français (contrainte lecteurs Malt).
- **Bash 3.2** (compatibilité macOS système) : pas de `mapfile` /
  `readarray` / `globstar` / `declare -A` dans les scripts. Garder un
  tableau vide valide sous `set -u` (nullglob + boucle `for`, ou
  `find -print0` + `while read -r -d ''`).
- **Baselines visuelles** : toujours régénérées en local via l'image
  Docker Playwright épinglée (`package.json`), jamais en CI — garantit
  des PNG identiques entre poste dev et CI (mêmes fonts).

---

## Annexe A — Scorecard : quand s'en servir

**Quand l'utiliser** : dès qu'on compare ≥ 2 options techniques pour
trancher une ADR et que la décision doit rester auditable des mois
plus tard.

**Quand s'en passer** : si le message de commit suffit — auquel cas ce
n'est probablement pas une décision irréversible non plus (principe 1).

Garde-fou mécanique : `make check-scorecard` refuse une scorecard
(détectée par un total « Score pondéré ») sans colonne « Critère » en
entête — pas d'exception pour l'instant.
