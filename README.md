# Projet 01 — Site de mocktails

## Vision

Un site de recettes de mocktails (cocktails sans alcool), beau et rapide, avec un
lien vers un shop pour commander les ingrédients nécessaires. L'objectif
est de valider une audience et une monétisation simple avant de complexifier.

---

## Stack technique

| Composant | Choix | Justification |
|-----------|-------|---------------|
| SSG | **Hugo** | Binaire Go, ultra rapide, zéro dépendance Node, maturité |
| CSS | Custom | Variables CSS, mobile-first, zéro framework |
| Hébergement | **Cloudflare Pages** | Gratuit, CDN mondial, déploiement Git |
| Monétisation v1 | **Liens affiliés** | Zéro risque, valide la demande |

### Niveau de JavaScript : vanilla uniquement

- **Filtrage** : CSS `:has()` + `data-*` attributes, localStorage persistence
- **Pas de framework JS**

---

## Structure du contenu (Hugo)

```
content/recettes/   # 24 recettes markdown
layouts/            # Templates Hugo
static/css/main.css # Styles (~350 lignes, pas de framework)
static/images/recettes/ # Images WebP optimisées
```

Frontmatter recette :

```yaml
---
title: "Mojito"
slug: mojito
fridge: ["rhum", "citron-vert", "menthe", "petillante"]
flavors: ["petillant", "herbace", "acidule"]
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"
---
```

---

## Fonctionnalités — Réalisées ✅

- **Catalogue de recettes** : 24 recettes avec photos WebP optimisées
- **Filtre frigo** : panel avec 25+ icônes SVG, logique AND, localStorage
- **Filtre saveurs** : 9 flavor pills (pétillant, fruité, acidulé…), composable avec le frigo
- **Images optimisées** : WebP ~100–150 KB, fond transparent
- **Semantic versioning** : version `1.0.0` dans `hugo.toml [params]`, exposée via `<meta name="version">` dans les pages HTML
- **Semantic release notes** : add release notes with rebuild content from git commits history
- **Grille responsive** : colonnes fluides 2→4 sans breakpoints (CSS Grid `auto-fill` + `minmax`)
- **Rapport qualité (Lighthouse)** : score Performance, Accessibilité, SEO, PWA — seuils minimum définis dans `budget.json`, intégré au pipeline CI
- **ARIA** : accessibilité complète (rôles, labels, live regions pour les filtres)
- **Page composants** : page dédiée listant tous les composants UI pour détecter les régressions visuelles
- **Tests automatisés** : anti régression visuelle sur le design system ; déploiement bloqué si les tests échouent

---

## Fonctionnalités — En cours / Backlog prioritaire

- [ ] **Tests automatisés** : tests fonctionnels pour filtrage frigo, filtrage saveurs, navigation recette, responsive
- [ ] **Checklist de commit** : vérifier que tout a été fait (légal, ARIA, design system, tests auto, etc.)
- [ ] **PWA / installable** : `manifest.json` + Service Worker pour "Ajouter à l'écran d'accueil" sur iOS/Android
- [ ] **Recipe page enrichment** : étapes de préparation
- [ ] **Recettes grisées** si ingrédient manquant : cards en bas de liste, visuellement atténuées
- [ ] **Custom recipe UI** : rework every recipe to integrate independent pictures of ingredients
- [ ] **Obligations légales** 
- [ ] **Icones réseaux sociaux**

---

## Fonctionnalités — V2

- **Pagefind search** : index statique, zéro serveur
- **SEO** : Schema.org `Recipe` structured data sur chaque recette
- **SEO** : Open Graph + meta description sur toutes les pages
- **Liens d'achat** : `shop_link` par ingrédient (affiliés)
- **Panier multi-ingrédients** (Snipcart)

---

## Fonctionnalités — Ignorées

- ~~Système de favoris~~ — complexité non justifiée à ce stade
- ~~Suggestions "si tu aimes X, essaie Y"~~ — idem
- ~~Newsletter~~ — pas de stratégie contenu définie
- ~~Badge compteur de recettes filtrées~~ — UX peu prioritaire
- ~~Recipe page enrichment : temps, difficulté~~ — rester le plus simple possible

---

## SEO — Canal d'acquisition principal

Hugo génère des pages statiques = indexation parfaite.
Points d'attention :
- `sitemap.xml` auto-généré par Hugo.
- URLs propres (`/recettes/mojito/`).
- Temps de chargement < 1s (pages statiques + CDN).
- Open Graph + Schema.org `Recipe` : prévu en V2.

---

## Déploiement

1. Push `main` → Cloudflare Pages build automatique (Hugo `0.159.1`).
2. Domaine custom : kanpai0.co (301 depuis kanpai0.com).
3. À venir : GitHub Actions gate avant promotion preview → production.

---

## Questions ouvertes

- Stratégie d'affiliation : quels partenaires cibler en premier ?
- Faut-il un blog/magazine en plus des recettes pour le SEO longue traîne ?
- TikTok : compte non créé (échec technique lors de l'inscription)
