# Kanpai Ø

Site de recettes de mocktails (cocktails sans alcool), construit comme une pièce de logiciel professionnel : décisions d'architecture tracées en ADR, tests de régression visuelle bloquants, release automation sans dépendance superflue.

Auteur : **Vincent Clair** · Tech Lead freelance · [Profil Malt](https://www.malt.fr/profile/vincentclair) · [LinkedIn](https://www.linkedin.com/in/vincent-clair/)

Site en ligne : [**kanpai0.co**](https://kanpai0.co).

---

## Ce que ce repo prouve

Ce projet est un side product personnel **et** une vitrine technique assumée. Au-delà d'avoir des recettes pour mes soirées, l'objectif était de valider un processus de développement assisté par IA sans sacrifier la lisibilité, la testabilité ou la sobriété technique.

Trois choses à regarder en priorité si vous arrivez depuis ma fiche Malt :

- [**specs/**](specs/) — 27 décisions tracées en format ADR, avec contexte, alternatives considérées et rationale explicite. Un projet perso, un seul développeur, discipline ADR quand même.
- La section **« Processus de développement assisté par IA »** plus bas — comment l'IA est utilisée et où elle est délibérément refusée.
- [**docs/retrospective-manques.md**](docs/retrospective-manques.md) — ce qui a été écarté, ce qui manque, ce qui a été appris en route.

---

## Processus de développement assisté par IA

Le principe : l'IA accélère la production de code, la discipline garantit ce qui en sort. Ce projet met les deux en tension sur un périmètre maîtrisable.

### Où l'IA intervient

- **Écriture de code** sous cadre architectural défini en amont (templates Hugo, CSS, scripts de build, tests).
- **Refactoring** sous contrôle des tests de régression visuelle et des tests fonctionnels BDD.
- **Génération de contenu initial** (descriptions de recettes, wordings d'UI) relu et corrigé.
- **Exploration d'alternatives techniques**, toujours suivie d'un ADR co-produit avec l'IA puis validé qui tranche.

### Où l'IA est délibérément refusée

- **Décisions d'architecture.** Les ADR sont co-produits avec l'IA à partir de la discussion préalable — contexte, options explorées, arbitrage — puis relus et validés manuellement. L'IA formalise ce qui a été échangé, je tranche et je signe. Le rationale et la décision retenue engagent ma responsabilité, pas celle du modèle.
- **Tests.** La garantie ne peut pas venir de la même source que le code. Les scénarios BDD et les seuils de régression sont posés par moi.
- **Release notes et CHANGELOG.** Sémantique produit, pas résumé de diff. `git-cliff` génère la structure, je revois la narration.

### Cadres de contrôle mécaniques

Chaque contribution, qu'elle vienne de l'IA ou de moi, passe par trois filtres :

- **Hook pre-commit** : build Hugo + validation de schéma des données frontmatter.
- **`make preflight` avant push** : build complet + tests Playwright dans le même conteneur Docker que la CI (même version des navigateurs, rendu identique macOS / Linux).
- **CI bloquante** : régression visuelle (14 sections, seuil 1 % diff pixels) + audit Lighthouse sur seuils définis dans `budget.json`. Pas de merge si rouge.

Ce cadre est transposable sur une plateforme B2B en équipe. C'est le genre de construction que je cherche à mettre en place en mission.

---

## Preuves

### Alternatives écartées (et pourquoi)

| Outil | Verdict |
|-------|---------|
| PicoCSS | Reset non voulu, conventions conflictuelles → CSS custom retenu |
| Pagefind | 24 recettes = recherche inutile, le filtre frigo suffit |
| semantic-release | Incompatible avec « pas de Node superflu dans un repo Hugo » — 8 263 fichiers npm pour ce que `git-cliff` fait en 157 lignes de bash |
| @cucumber complet | 414 dépendances → `playwright-bdd` (12 dépendances) suffit |
| rembg + SDXL local | Fond transparent du verre supprimé avec le fond → `gpt-image-1` avec `background: "transparent"` natif |

### Stack technique

| Composant | Choix | Justification |
|-----------|-------|---------------|
| SSG | **Hugo** | Binaire Go, ultra rapide, zéro dépendance Node, maturité |
| CSS | Custom (~350 lignes) | Variables CSS, mobile-first, zéro framework — contrôle total |
| JS | Vanilla uniquement | Filtrage CSS `:has()` + `data-*`, `localStorage` — pas de framework |
| Hébergement | **Cloudflare Pages** | Gratuit, CDN mondial, déploiement Git automatique |
| Tests | **Playwright + playwright-bdd** | Visual regression + BDD, 12 dépendances vs 414 pour `@cucumber` |
| Release | **bash + git-cliff** | 157 lignes de bash, 0 dépendance Node (vs `semantic-release` = 8 263 fichiers npm) |
| Images | **gpt-image-1** | `background: "transparent"` natif — le seul modèle fiable sur verres |

→ Détail des méthodes, outils et techniques : [docs/methodes-outils-techniques.md](docs/methodes-outils-techniques.md)  
→ Rétrospective des manques et apprentissages : [docs/retrospective-manques.md](docs/retrospective-manques.md)

### Chiffres

- **27 ADR** horodatés dans `specs/`, du premier commit à la v1
- **14 sections** testées en régression visuelle, seuil 1 % diff pixels, blocage des merges
- **~45 h** de travail effectif sur 3 semaines
- **58 €** de coût de lancement
- **Sobriété de dépendances** : là où une stack classique en aurait des centaines, ce repo en a 2 publiques de poids (Playwright, git-cliff) et aucune au runtime du site

---

## Le produit

**kanpai0.co** : 24 recettes de mocktails, filtrage par ingrédients disponibles et par saveurs, site statique ultra-léger.

Fonctionnalités principales :

- Catalogue de 24 recettes avec photos WebP optimisées (~100–150 KB, fond transparent)
- **Filtre frigo** : panel latéral avec 25+ icônes SVG, logique AND, persistance `localStorage`
- **Filtre saveurs** : 9 flavor pills composables avec le filtre frigo
- Grille responsive fluide 2 → 4 colonnes sans breakpoints (CSS Grid `auto-fill` + `minmax`)
- Accent couleur unique par recette (sous-titre, chiffres)
- Accessibilité ARIA complète (rôles, labels, live regions sur les filtres)
- Mentions légales, page 404 en easter egg (recette originale)

Les choix écartés et leur rationale sont documentés dans [docs/retrospective-manques.md](docs/retrospective-manques.md) — notamment l'abandon de la PWA ([ADR dédié](specs/2026-04-19-pwa/plan.md)).

---

## Déploiement & CI

Push `main` → pipeline GitHub Actions → Cloudflare Pages. Domaine `kanpai0.co` (301 depuis `kanpai0.com`).

Deux jobs tournent en parallèle avant tout déploiement :

| Job | Ce qu'il fait |
|-----|---------------|
| `visual-regression` | Build Hugo local → Playwright : snapshots visuels + BDD fonctionnels (filtrage frigo/saveurs, navigation, responsive) |
| `lighthouse` | Audit post-deploy sur `kanpai0.co` et une page recette — seuils Performance, Accessibilité, SEO dans `budget.json` |

Le job `deploy` est bloqué si l'un des deux échoue. Les diffs Playwright sont uploadés comme artefacts GitHub (rétention 7 jours) en cas d'échec.

Détail : [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

---

## Pour aller plus loin

### Structure Hugo

```
content/recettes/        # 24 recettes markdown (source de vérité)
layouts/                 # Templates Hugo
  index.html             # Homepage : grille + panel frigo + filtering JS
  recettes/single.html   # Page recette individuelle
  partials/              # fridge-icons, fridge-panel-body, …
static/css/main.css      # Tous les styles (~350 lignes)
static/images/recettes/  # Images WebP optimisées
scripts/                 # Utilitaires Python/bash
specs/                   # ADR horodatés
design/                  # Fichiers .pen + maquettes
docs/                    # Références, qualité, marketing
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

### V2 si le projet évolue

SEO (Schema.org `Recipe` + Open Graph + meta description), Pagefind search, liens d'achat affiliés, monétisation légère.

### Historique complet

[CHANGELOG.md](CHANGELOG.md) · [Posts LinkedIn publiés autour du projet](docs/marketing/linkedin-posts.md)

---

## Me contacter

Je suis **Vincent Clair**, Tech Lead freelance basé à Bordeaux, plus de 20 ans d'expérience sur plateformes B2B critiques. Ce que j'apporte : produit, qualité, sobriété, et désormais une pratique cadrée du développement assisté par IA.

**Disponible pour une mission longue** (12 mois et plus, remote dominant avec points réguliers en présentiel). Scale-ups et ETI B2B principalement : industrie, énergie, santé, aérospatial, défense.

- Malt : [malt.fr/profile/vincentclair](https://www.malt.fr/profile/vincentclair)
- LinkedIn : [linkedin.com/in/vincent-clair](https://www.linkedin.com/in/vincent-clair/)
- Email : [vincent.clair@inneair.com](mailto:vincent.clair@inneair.com)

Si ce repo raconte ce que vous cherchez dans votre équipe, un message suffit.
