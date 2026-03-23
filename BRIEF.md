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
| CSS | **PicoCSS** | HTML sémantique stylé nativement |
| Recherche | **Pagefind** | Index statique, zéro serveur, quelques Ko côté client |
| Hébergement | **Cloudflare Pages** | Gratuit, CDN mondial, déploiement Git |
| Paiements | **Stripe Payment Links** | Zéro backend, lien direct vers checkout |
| Alternative shop | **Snipcart** | Panier e-commerce sur site statique (si besoin de panier) |
| Monétisation v1 | **Liens affiliés** | Zéro risque, valide la demande |

### Niveau de JavaScript : 0 à 1

- **Filtrage des recettes** : CSS `:has()` + checkbox si catalogue < 300 recettes, sinon petit script vanilla avec `data-*` + `hidden`.
- **Recherche** : Pagefind (JS léger auto-généré au build).
- **Navigation fluide** : script vanilla ~30 lignes (fetch + DOMParser + pushState) ou Turbo si les cas edge le justifient.
- **Pas de framework JS.**

---

## Structure du contenu (Hugo)

```
content/
├── recettes/
│   ├── mojito-virgin.md
│   ├── spritz-sans-alcool.md
│   └── ...
├── ingredients/
│   ├── sirop-de-sureau.md
│   ├── tonic-fever-tree.md
│   └── ...
└── pages/
    ├── a-propos.md
    └── contact.md
```

Chaque recette en frontmatter YAML :

```yaml
---
title: "Mojito Virgin"
date: 2026-03-01
categories: ["rafraîchissant", "été"]
difficulty: "facile"
prep_time: "5 min"
ingredients:
  - name: "Menthe fraîche"
    quantity: "10 feuilles"
    shop_link: ""
  - name: "Sirop de sucre de canne"
    quantity: "2 cl"
    shop_link: "https://..."
  - name: "Eau gazeuse"
    quantity: "15 cl"
    shop_link: ""
  - name: "Citron vert"
    quantity: "1"
    shop_link: ""
tags: ["menthe", "citron", "sans-sucre-ajouté"]
image: "mojito-virgin.jpg"
---
```

---

## Fonctionnalités — MVP

1. **Catalogue de recettes** avec photos, filtrable par catégorie / ingrédient / difficulté.
2. **Page recette** avec liste d'ingrédients, étapes, photo.
3. **Liens d'achat** sur chaque ingrédient (affiliés ou Stripe Payment Links).
4. **Recherche** via Pagefind.
5. **SEO optimisé** : pages statiques, meta tags, structured data (Recipe schema.org).
6. **Responsive** : PicoCSS gère ça nativement.

## Fonctionnalités — V2

- Panier multi-ingrédients (Snipcart).
- Système de favoris (localStorage ou petit backend).
- Suggestions "si tu aimes X, essaie Y".
- Newsletter (Buttondown ou similaire, sans base mail custom).

---

## SEO — Canal d'acquisition principal

Hugo génère des pages statiques = indexation parfaite.
Points d'attention :
- Schema.org `Recipe` sur chaque recette.
- `sitemap.xml` auto-généré par Hugo.
- Open Graph et Twitter Cards pour le partage social.
- URLs propres (`/recettes/mojito-virgin/`).
- Temps de chargement < 1s (pages statiques + CDN).

---

## Déploiement

1. Repo Git (GitHub ou GitLab).
2. Push → Cloudflare Pages build automatique (Hugo).
3. Pagefind s'exécute en post-build.
4. Domaine custom sur Cloudflare (DNS intégré).

---

## Questions ouvertes

- [ ] Nom de domaine / marque ?
- [ ] Source des recettes initiales ? (Création originale, curation, les deux ?)
- [ ] Photos : stock, générées, prises soi-même ?
- [ ] Stratégie d'affiliation : quels partenaires cibler en premier ?
- [ ] Faut-il un blog/magazine en plus des recettes pour le SEO longue traîne ?
