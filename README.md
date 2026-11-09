# Kanpai Ø

Site de recettes de mocktails (cocktails sans alcool), construit comme une pièce de logiciel professionnel : décisions d'architecture tracées en ADR, tests de régression visuelle bloquants, publication automatisée sans dépendance superflue.

Auteur : **Vincent Clair** · Tech Lead, fondateur d'[Innéair](https://inneair.com/vincent-clair/) · [LinkedIn](https://www.linkedin.com/in/vincent-clair/)

Site en ligne : [**kanpai0.co**](https://kanpai0.co).

---

## Ce que ce repo prouve

Ce projet est un side product personnel **et** une vitrine technique assumée. Au-delà d'avoir des recettes pour mes soirées, l'objectif était de valider un processus de développement assisté par IA sans sacrifier la lisibilité, la testabilité ou la sobriété technique.

Trois choses à regarder en priorité si vous arrivez depuis mon CV ou mon profil :

- [**docs/adr/**](docs/adr/) : les décisions tranchées, avec leur contexte, les alternatives considérées et la raison du choix. [**docs/ddr/**](docs/ddr/) range les décisions différées, chacune avec son déclencheur de réouverture. [**specs/**](specs/) garde l'historique de fabrication : un plan daté par session de travail. Un projet perso, un seul développeur, et la même discipline qu'en équipe : chaque sujet est trié entre décision et plan.
- La section **« Processus de développement assisté par IA »** plus bas : comment l'IA est utilisée et où elle est délibérément refusée.
- [**docs/retrospective-manques.md**](docs/retrospective-manques.md) : ce qui a été écarté, ce qui manque, ce qui a été appris en route.

---

## Processus de développement assisté par IA

Le principe : l'IA pour la vitesse, le code pour la justesse. L'IA accélère la production du code ; les tests, les contrôles automatiques et mes décisions garantissent ce qui en sort.

### Où l'IA intervient

- **Écriture de code** sous un cadre architectural défini en amont (templates Hugo, CSS, scripts de build, tests).
- **Refactoring** sous contrôle des tests de régression visuelle et des tests fonctionnels BDD.
- **Génération de contenu initial** (descriptions de recettes, textes d'interface), relu et corrigé.
- **Images des recettes**, générées par un script idempotent au coût calculé d'avance, puis relues une à une avant publication.
- **Exploration d'alternatives techniques**, toujours suivie d'un ADR co-produit avec l'IA, que je relis et qui tranche.

### Où l'IA est délibérément refusée

- **Décisions d'architecture.** Les ADR sont co-produits avec l'IA à partir de la discussion préalable (contexte, options explorées, arbitrage), puis relus et validés manuellement. L'IA formalise ce qui a été échangé, je tranche et je signe. La raison et la décision retenue engagent ma responsabilité, pas celle du modèle.
- **Tests.** La garantie ne peut pas venir de la même source que le code. Les scénarios BDD et les seuils de régression sont posés par moi.
- **Release notes et CHANGELOG.** Sémantique produit, pas résumé de diff. `git-cliff` génère la structure, je revois la narration.

### Cadres de contrôle mécaniques

Chaque contribution, qu'elle vienne de l'IA ou de moi, passe par trois filtres :

- **Hook pre-commit** : un contrôle unique, `make validate`, qui refuse le commit si une règle du cadre n'est pas tenue (lint des scripts shell, schéma du contenu, version de Playwright, éléments attendus par le JavaScript, sections du design system, déclencheurs des ADR et des décisions différées, tests unitaires).
- **`make preflight` avant push** : build complet et tests Playwright dans le même conteneur Docker que la CI (même version des navigateurs, rendu identique sous macOS et Linux).
- **CI bloquante** : régression visuelle de chaque section du design system (seuil de 0,1 % de pixels différents) et scénarios BDD. Pas de déploiement si l'un des deux est rouge. Un audit Lighthouse tourne ensuite sur le site déployé ; il n'a pas encore de seuil bloquant.

Ce cadre est transposable sur une plateforme B2B en équipe. C'est le genre de construction que je mets en place avec une équipe.

---

## Preuves

### Alternatives écartées (et pourquoi)

| Outil | Verdict |
|-------|---------|
| PicoCSS | Reset non voulu, conventions conflictuelles → CSS maison retenu |
| Pagefind | 24 recettes = recherche inutile, le filtre frigo suffit |
| semantic-release | Incompatible avec « pas de Node superflu dans un repo Hugo » : 8 263 fichiers npm pour ce qu'un script bash et `git-cliff` font |
| @cucumber complet | 414 dépendances → `playwright-bdd` (12 dépendances) suffit |
| rembg + SDXL local | Fond transparent du verre supprimé avec le fond → `gpt-image-1` avec `background: "transparent"` natif |

### Stack technique

| Composant | Choix | Justification |
|-----------|-------|---------------|
| SSG | **Hugo** | Binaire Go, ultra rapide, zéro dépendance Node, maturité |
| CSS | CSS maison | Variables CSS, mobile-first, zéro framework : contrôle total |
| JS | Vanilla uniquement | Filtrage des recettes et mémoire des choix (`localStorage`) en JavaScript ; état de l'interface (panneau, pastilles) en CSS `:has()` |
| Hébergement | **Cloudflare Pages** | Gratuit, CDN mondial, déploiement Git automatique |
| Tests | **Playwright + playwright-bdd** | Régression visuelle + BDD, 12 dépendances au lieu de 414 pour `@cucumber` |
| Release | **bash + git-cliff** | Un script bash, aucune dépendance Node (contre 8 263 fichiers npm pour `semantic-release`) |
| Images | **gpt-image-1** | `background: "transparent"` natif : le seul modèle fiable sur des verres |
| Toolchain | **mise** | Versions d'outils épinglées dans `.mise.toml` : les mêmes binaires en local et en CI |

→ Rétrospective des manques et apprentissages : [docs/retrospective-manques.md](docs/retrospective-manques.md)

### Ce qui se vérifie dans le repo

- Les décisions tranchées dans `docs/adr/`, les décisions différées avec leur déclencheur dans `docs/ddr/`, un plan daté par session dans `specs/`, du premier commit à la v1
- Chaque section du design system testée en régression visuelle, avec un seuil de 0,1 % de pixels différents, qui bloque le déploiement
- **Sobriété de dépendances** : aucune dépendance au runtime du site ; côté outillage, Playwright, playwright-bdd et git-cliff

---

## Le produit

**kanpai0.co** : 24 recettes de mocktails, filtrage par ingrédients disponibles et par saveurs, site statique ultra-léger.

Fonctionnalités principales :

- Catalogue de 24 recettes avec photos WebP optimisées (fond transparent)
- **Filtre frigo** : panneau latéral d'icônes SVG, logique ET, choix mémorisés dans `localStorage`
- **Filtre saveurs** : pastilles de saveurs, combinables avec le filtre frigo
- Grille responsive fluide de 2 à 4 colonnes sans breakpoints (CSS Grid `auto-fill` + `minmax`)
- Accent couleur unique par recette (sous-titre, chiffres)
- Accessibilité des filtres : rôles, libellés et zones live ARIA
- Mentions légales, page 404 en easter egg (recette originale)

Les choix écartés et leurs raisons sont documentés dans [docs/retrospective-manques.md](docs/retrospective-manques.md), notamment l'abandon de la PWA ([DDR-004](docs/ddr/DDR-004-mode-offline-pwa.md), à partir de [ce plan](specs/2026-04-19-1543-pwa/plan.md)).

---

## Déploiement & CI

Push `main` → pipeline GitHub Actions → Cloudflare Pages. Domaine `kanpai0.co` (301 depuis `kanpai0.com`).

Le site est buildé une seule fois (`build`), publié comme artefact GitHub, puis consommé par les jobs suivants ; aucun autre job ne relance `hugo build` :

| Job | Ce qu'il fait |
|-----|---------------|
| `build` | `hugo build` → artefact `public` |
| `validate` | `make validate-ci` : schéma frigo/saveurs, lint shell, version Playwright, tests unitaires |
| `visual-regression` | Playwright sur l'artefact `public` : snapshots visuels + BDD fonctionnels (filtrage frigo/saveurs, navigation, responsive) |
| `deploy` | Déploie l'artefact `public` sur Cloudflare Pages : push `main` uniquement, et seulement si `validate` et `visual-regression` sont verts |
| `lighthouse` | Audit après déploiement de `kanpai0.co` et d'une page recette, rapports publiés ; pas encore de seuil bloquant |

`validate` et `visual-regression` tournent en parallèle dès que l'artefact est disponible ; `deploy` est bloqué si l'un des deux échoue ; `lighthouse` audite le site une fois déployé, donc après `deploy`, sinon il auditerait la version précédente. Les diffs Playwright sont publiés comme artefacts GitHub (rétention 7 jours) en cas d'échec.

`build` et `validate` installent le toolchain épinglé via `jdx/mise-action` : la version de Hugo (et de shellcheck, jq, etc.) utilisée en CI vient de `.mise.toml`, pas d'un numéro recopié dans le workflow.

Détail : [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

---

## Pour aller plus loin

### Développer en local

Le toolchain est épinglé dans [`.mise.toml`](.mise.toml) : Hugo, Node, Python, `git-cliff`, `shellcheck`, `jq`, `yq`. La CI installe ce même fichier via `jdx/mise-action` : pas de version d'outil écrite en double.

Deux prérequis sur la machine (plus Docker pour les tests Playwright) :

| Outil  | Rôle                        | Installation                                                |
|--------|-----------------------------|-------------------------------------------------------------|
| `mise` | Gère les versions d'outils  | `brew install mise`, voir [mise.jdx.dev](https://mise.jdx.dev/) |
| `make` | Task runner (GNU Make 4+ requis par `make validate`) | macOS : `brew install make` ; le `make` 3.81 de `xcode-select` ne suffit pas |

```sh
git clone https://github.com/kanpai0/website.git
cd website
make bootstrap   # mise install + npm ci + hook pre-commit
make serve       # hugo serve
make preflight   # build + tests Playwright avant push
```

Activer mise dans le shell pour que les binaires épinglés arrivent dans le `PATH` :

```sh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
exec $SHELL -l
```

Sans activation, préfixer les commandes par `mise exec --` (ex. `mise exec -- make preflight`).

### Structure Hugo

```
src/
  content/recettes/      # 24 recettes markdown (source de vérité)
  layouts/               # Templates Hugo
    index.html           # Homepage : grille + panneau frigo + filtrage JS
    recettes/single.html # Page recette individuelle
    partials/            # fridge-icons, fridge-panel-body, …
  static/css/main.css    # Tous les styles
  static/images/recettes/  # Images WebP optimisées
tools/                   # Process repo : check-*, lib/, git-hooks/, release.sh, preflight.sh
scripts/                 # Pipelines de contenu : Python + download-recipe-images.sh
specs/                   # Plans d'implémentation datés (historique de fabrication)
docs/
  adr/                   # Décisions tranchées
  ddr/                   # Décisions différées (déclencheur de réouverture)
  design/                # Maquettes .pen, essais et inspirations
```

### Frontmatter d'une recette

```yaml
---
title: "Mojito"
slug: mojito
fridge: ["rhum", "citron-vert", "menthe", "petillante"]
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"
---
```

### Backlog

- Custom recipe UI : photos indépendantes par ingrédient
- Release notes grand public sur le site
- Seuils Lighthouse bloquants

### V2 si le projet évolue

SEO (Schema.org `Recipe` + Open Graph + meta description), Pagefind search, liens d'achat affiliés, monétisation légère.

### Historique complet

[CHANGELOG.md](CHANGELOG.md)

---

## Me contacter

Je suis **Vincent Clair**, Tech Lead et fondateur d'Innéair. J'ai dirigé pendant quatre ans la technique d'un produit Somfy en production, et je fais travailler l'IA sous la même discipline : l'IA pour la vitesse, le code pour la justesse.

- Mon parcours : [inneair.com/vincent-clair](https://inneair.com/vincent-clair/)
- LinkedIn : [linkedin.com/in/vincent-clair](https://www.linkedin.com/in/vincent-clair/)
- Email : [vincent.clair@inneair.com](mailto:vincent.clair@inneair.com)

Si ce repo raconte ce que vous cherchez dans votre équipe, un message suffit.
