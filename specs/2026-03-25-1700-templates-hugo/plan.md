# Templates Hugo — 2026-03-25

## Objectif

Créer les templates Hugo pour la page d'accueil (grille de recettes) et la page
individuelle de recette, en utilisant les images WebP générées par IA.

---

## Fichiers produits

### `layouts/index.html` — Page d'accueil

Grille 2 colonnes listant toutes les recettes de la section `recettes`.

```hugo
{{ range (where .Site.RegularPages "Section" "recettes") }}
<a href="{{ .RelPermalink }}" class="recipe-card">
  <figure class="recipe-card__photo">
    <img src="/images/recettes/{{ .Params.slug }}.webp" alt="{{ .Title }}">
  </figure>
  <h2 class="recipe-card__title">{{ .Title }}</h2>
</a>
{{ end }}
```

- `<body class="home">` pour activer le scroll (le body global a `overflow: hidden`)
- Image référencée via `{{ .Params.slug }}` dans le frontmatter

### `layouts/recettes/single.html` — Page recette

Template individuel pour chaque recette.

- Image : `/images/recettes/{{ .Params.slug }}.webp`
- Titre : `{{ .Title }}`
- Ingrédients : `{{ range .Params.ingredients }}`
- `<title>` : `{{ .Title }} — {{ .Site.Title }}`

---

## CSS ajouté dans `static/css/main.css`

### Override scroll page d'accueil

```css
body.home {
  overflow: auto;
}
```

### Grille `.recipes-grid`

- `grid-template-columns: 1fr 1fr`
- `gap: 8px`
- padding-top = `var(--header-h) + 24px`

### Carte `.recipe-card`

- Flexbox colonne, centré
- Hover : fond légèrement assombri (`rgba(26,26,24,0.04)`)
- Titre : serif italique, `clamp(15px, 3.5vw, 20px)`

---

## Conventions

- Les images sont référencées par `{{ .Params.slug }}` — le champ `slug` doit être
  présent dans le frontmatter de chaque recette et correspondre exactement au nom
  du fichier image (ex: `madeleine` → `madeleine.webp`).
- Format image : **WebP** (PNG converti, ~800×800px)

---

## Prochaines étapes

1. Convertir les 24 PNG en WebP (~800px) — réduire de ~1.5 MB à ~100–150 KB
2. Vérifier l'affichage de la grille sur mobile (1 colonne ?) et tablette
3. Enrichir la page recette : étapes de préparation, temps, niveau de difficulté
