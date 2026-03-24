# Import des recettes Sober Spirits — 2026-03-24

## Objectif

Importer les 24 recettes de mocktails de soberspirits.com et les structurer
en fichiers Hugo pour préparer le passage à un système de templates.

---

## Approche technique

### Pourquoi pas Playwright ?

Le site soberspirits.com utilise GemPages (page builder Shopify). On aurait pu
croire que le contenu est rendu côté client (JS), mais un `curl` simple suffit :
les ingrédients sont dans le HTML statique, encodés en balises `<p>` et `<span>`.
Pas besoin de headless browser.

### Scraping

- `curl` avec un User-Agent Chrome pour télécharger les 24 pages HTML
- Stockage dans `_sources/sober-spirits/` (versionné, jamais publié par Hugo)
- Pause de 0,5 s entre les requêtes

### Parsing (`scripts/scrape-sober-spirits.py`)

**Dépendances** : aucune (stdlib Python uniquement)

Structure HTML identifiée :
```
<p>Ingrédients</p>
<p><span>50 ml de Sober Spirits 0,0 %</span><br/>1 demi-citron vert pressé</p>
<p>15 ml de sirop d'agave</p>
...
<p>Ustensiles</p>
```

**Deux patterns de séparation des ingrédients :**

1. `<br/>` à l'intérieur d'un `<p>` → remplacé par `\n` avant de stripper les tags
2. Plusieurs ingrédients dans une seule ligne (sans `<br>`) → split par détection
   des *débuts* d'ingrédients via regex (`\d+ ml`, `\d+ demi`, `Glace`, `Une `, etc.)
   plutôt qu'en splitant sur des caractères (évite de couper les noms de marque)

**Extraction :**
- Titre : `<meta property="og:title">` + `html.unescape()`
- Image : première `<img>` Shopify CDN assets `.webp`
- Ingrédients : bloc entre `<p>Ingrédients</p>` et `<p>Ustensiles</p>`

---

## Fichiers produits

### Sources brutes (référence)
```
_sources/sober-spirits/
├── mocktail-sober-mojito.html
├── mocktail-sober-daiquiri.html
└── ... (24 fichiers HTML)
```

### Contenu Hugo
```
content/recettes/
├── mojito.md
├── daiquiri.md
└── ... (24 fichiers)
```

### Frontmatter YAML généré
```yaml
---
title: Mocktail Mojito sans alcool
slug: mojito
draft: false
source_image: "https://www.soberspirits.com/cdn/shop/..."
source_url: "https://www.soberspirits.com/fr/pages/mocktail-sober-mojito"
ingredients:
  - "50 ml de Sober Spirits 0,0 %"
  - 1 demi-citron vert pressé
  - "15 ml de sirop d'agave"
  - 8 feuilles de menthe fraîche
  - Glace pilée
  - "Une giclée d'eau pétillante"
---
```

---

## Points d'attention

| Recette | Artefact | Cause |
|---------|----------|-------|
| bourbon-mule, godfather, whisky-apple, chenonceau, whisky-sour, whisky-ginger-ale | `50 ml de Sober Spirits bourbon Sober Spirits 0,0 %` | Deux `<span>` produits concaténés dans le HTML source (variante Bourbon + produit générique) |
| planteur | 9 ingrédients, quantités ×6 (recette pour 6 personnes) | Recette collective — à normaliser si besoin |
| pina-colada | `50 ml de jus d'ananas,` (virgule finale) | Ponctuation dans le HTML source |

---

## Prochaines étapes

1. Créer `layouts/recettes/single.html` — template Hugo qui lit le frontmatter
2. Mettre à jour `layouts/index.html` pour qu'il devienne une page liste ou redirige
3. Ajouter une photo par recette (génération IA ou stock)
4. SEO : meta description, Schema.org Recipe, Open Graph
