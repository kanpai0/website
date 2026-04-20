# Projet 01 — Kanpai Ø · Site de mocktails

## Vision

Un site de recettes de mocktails (cocktails sans alcool), beau et rapide, conçu pour mes soirées et mes invités. Double objectif : usage personnel et démonstration de savoir-faire technique pour les recruteurs.

Pas de validation d'audience externe, pas de SEO intentionnel, pas de monétisation en v1 — ces sujets sont déplacés en v2 optionnelle si le projet prend de l'ampleur.

---

## Specs & historique

Chaque fonctionnalité significative a un plan horodaté dans `specs/` (format ADR) documentant le contexte, les options évaluées et la décision retenue. 22 specs au total, de `2026-03-23-minimal-website` à `2026-04-15-directory-layout`.

Les renoncements et apprentissages de méthode sont consignés dans [docs/retrospective-manques.md](docs/retrospective-manques.md).

L'historique complet des versions est dans [CHANGELOG.md](CHANGELOG.md).

---

## Déploiement

Push `main` → pipeline GitHub Actions → Cloudflare Pages.  
Domaine : `kanpai0.co` (301 depuis `kanpai0.com`).

### Pipeline de validation (`.github/workflows/ci.yml`)

Deux jobs tournent en parallèle avant tout déploiement :

| Job | Ce qu'il fait |
|-----|---------------|
| `visual-regression` | Build Hugo local → Playwright : tests visuels (snapshots) + tests BDD fonctionnels (filtrage frigo/saveurs, navigation, responsive) |
| `lighthouse` | Audit post-deploy sur `kanpai0.co` et une page recette — seuils Performance, Accessibilité, SEO définis dans `budget.json` |

Le job `deploy` est bloqué si l'un des deux échoue. Les diffs Playwright sont uploadés comme artefacts GitHub (rétention 7 jours) en cas d'échec.

---

## Communication

Posts LinkedIn publiés autour du projet : [docs/marketing/linkedin-posts.md](docs/marketing/linkedin-posts.md).

---

## Stack technique

| Composant | Choix | Justification |
|-----------|-------|---------------|
| SSG | **Hugo** | Binaire Go, ultra rapide, zéro dépendance Node, maturité |
| CSS | Custom (~350 lignes) | Variables CSS, mobile-first, zéro framework — contrôle total |
| JS | Vanilla uniquement | Filtrage CSS `:has()` + `data-*`, localStorage — pas de framework |
| Hébergement | **Cloudflare Pages** | Gratuit, CDN mondial, déploiement Git automatique |
| Tests | **Playwright + playwright-bdd** | Visual regression + BDD ; 12 dépendances vs 414 pour @cucumber |
| Release | **bash + git-cliff** | 157 lignes, 0 dépendance Node (vs semantic-release = 8263 fichiers npm) |
| Images | **gpt-image-1** | `background: "transparent"` natif — le seul modèle fiable sur verres |

→ Détail des méthodes, outils et techniques utilisés : [docs/methodes-outils-techniques.md](docs/methodes-outils-techniques.md)

### Alternatives écartées (et pourquoi)

| Outil | Verdict |
|-------|---------|
| PicoCSS | Reset non voulu, conventions conflictuelles → CSS custom retenu |
| Pagefind | 24 recettes = recherche inutile, le filtre frigo suffit |
| semantic-release | Philosophiquement incompatible avec "pas de Node dans un repo Hugo" |
| rembg + SDXL local | Fond transparent du verre supprimé avec le fond — image vide |

---

## Structure du contenu (Hugo)

```
content/recettes/        # 24 recettes markdown (source de vérité)
layouts/                 # Templates Hugo
  index.html             # Homepage : grille + panel frigo + filtering JS
  recettes/single.html   # Page recette individuelle
  partials/
    fridge-icons.html        # Sprite SVG ~25 icônes ingrédients
    fridge-panel-body.html   # Composant panel frigo
static/css/main.css      # Tous les styles (~350 lignes)
static/images/recettes/  # Images WebP optimisées
scripts/                 # Utilitaires Python/bash
specs/                   # Plans et ADRs horodatés
design/                  # Fichiers .pen + maquettes
docs/                    # Docs de référence, qualité, marketing
```

Frontmatter recette :

```yaml
---
title: "Mojito"
slug: mojito
fridge: ["rhum", "citron-vert", "menthe", "petillante"]
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"
---
```

---

## Fonctionnalités

### Fonctionnalités — Réalisées ✅

- **Catalogue de recettes** : 24 recettes avec photos WebP optimisées
- **Filtre frigo** : panel avec 25+ icônes SVG, logique AND, localStorage
- **Filtre saveurs** : 9 flavor pills (pétillant, fruité, acidulé…), composable avec le frigo
- **Images optimisées** : WebP ~100–150 KB, fond transparent
- **Grille responsive** : colonnes fluides 2→4 sans breakpoints (CSS Grid `auto-fill` + `minmax`)
- **Semantic versioning** : version dans `hugo.toml [params]`, exposée via `<meta name="version">`
- **Release notes sémantiques** : contenu reconstruit depuis l'historique git
- **ARIA** : accessibilité complète (rôles, labels, live regions pour les filtres)
- **Rapport qualité (Lighthouse)** : scores Performance, Accessibilité, SEO — seuils définis dans `budget.json`
- **Tests visuels automatisés** : anti-régression sur le design system ; déploiement bloqué si échec
- **Tests fonctionnels automatisés** : filtrage frigo, filtrage saveurs, navigation recette, responsive
- **Page composants** : liste tous les composants UI pour détecter les régressions visuelles
- **Obligations légales** : mentions légales, RGPD
- **Étapes de préparation** : enrichissement des pages recettes
- **Couleur par cocktail** : accent unique sur le sous-titre et les chiffres de chaque recette
- **Icône d'app** : favicon + PWA
- **Icônes réseaux sociaux**
- **Bouton retour** : retour à la liste depuis une recette
- **Recettes grisées** : cards sans ingrédients disponibles → en bas de liste, visuellement atténuées
- **Page 404 cocktail** : recette originale en easter egg
- **Page storytelling** : logo et icône Kanpai Ø

### Fonctionnalités — Backlog

- [ ] **Custom recipe UI** : photos indépendantes de chaque ingrédient intégrées à la page recette
- [ ] **Release notes** : faire une version grand public sur le site

### Fonctionnalités — V2 (si le projet évolue)

- **SEO** : Schema.org `Recipe` + Open Graph + meta description
- **Pagefind search** : index statique, zéro serveur
- **Liens d'achat affiliés** : `shop_link` par ingrédient
- **Monétisation** : liens affiliés ou panier multi-ingrédients

### Fonctionnalités — Ignorées

- ~~Système de favoris~~ — complexité non justifiée
- ~~Suggestions "si tu aimes X, essaie Y"~~ — idem
- ~~Newsletter~~ — pas de stratégie contenu définie
- ~~Badge compteur de recettes filtrées~~ — UX peu prioritaire
- ~~Temps, difficulté par recette~~ — rester le plus simple possible
- ~~PWA / installable~~ — gain offline insuffisant pour justifier la complexité d'un service worker ; support iOS PWA trop limité ([ADR](specs/2026-04-19-pwa/plan.md))
