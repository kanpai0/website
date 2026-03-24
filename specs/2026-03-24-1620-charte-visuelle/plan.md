# Charte visuelle & état du projet — 2026-03-24

## ⚠️ Rappel essentiel

**On publie UNE seule page. Elle contient TROIS choses :**

1. La photo du mocktail
2. Le titre
3. La liste des ingrédients

C'est tout. Ne pas ajouter d'autres éléments avant d'avoir validé cette base en conditions réelles.


il faut également récupérer l'image du verre, à côté de la section "comment faire", et la détourer
ignore les js, css. Récupère seulement le contenu html et l'image souhaitée

---

## Ce qui a été décidé et fait

### Références visuelles

- Seedlip (onepagelove.com/seedlip) : minimalisme premium, photo produit comme ancre, carte blanche avec détails
- Pinterest : fond neutre, vue légèrement plongeante, verre "intégré" à la page (pas de fond visible)

### Charte graphique

| Élément | Valeur |
|---|---|
| Fond | `#F7F4EE` (crème chaud) |
| Texte principal | `#1A1A18` |
| Texte secondaire | `#6B6860` |
| Accent | `#3D5A3E` (vert sauge) |
| Carte | `#FFFFFF` |
| Bordures | `#E8E3D8` |
| Serif (titres) | Playfair Display italic |
| Sans-serif (corps) | Inter |

### Layout

- **Page non-scrollable** (`overflow: hidden`, `height: 100dvh`)
- **Photo** : positionnée en absolu, détourée via `mix-blend-mode: multiply` + `filter: brightness(1.08)` — le fond blanc/gris de la photo disparaît sur le fond crème sans PNG transparent
- **Carte ingrédients** : flotte en absolu, ancrée par rapport au bas (`bottom`), légèrement rentrée du bord (`right: 8%`), largeur `30% / min 180px`
- **Titre** : ancré en bas de page, Playfair Display italic, taille fluide `clamp(48px, 15vw, 60px)`
- **Un seul layout** — pas de breakpoints pour l'instant, le layout mobile s'applique à tous les formats

### Éléments retirés (volontairement)

- Difficulté, temps de préparation, nombre de personnes
- Bouton "Commander les ingrédients"
- Catégorie ("Mocktail rafraîchissant")
- Lien "↑ recette"

### Fichiers produits

```
layouts/index.html          — template Hugo de la page
static/css/main.css         — styles (layout unique, pas de breakpoints)
static/images/spritz-sureau.webp  — photo générée (IA, frontal léger)
```

### Maquette

Fichier Pencil : `/Users/vincent/Documents/kanpai0.pen`
- Frame `YNA7f` : écran mobile de référence (390×844)
- Frame `34xA7` : état "recette révélée" (non implémenté pour l'instant)

### Déploiement

- Repo : `github.com/kanpai0/website`
- Hébergement : Cloudflare Pages (build auto sur push `main`)
- URL : `kanpai0.co`

---

## Ce qui reste à faire (quand on sera prêt)

- Remplacer la photo IA par une vraie photo du mocktail
- Transformer le template en recette Hugo générique (frontmatter YAML)
- Implémenter la vue "recette" (ingrédients + préparation) sur scroll/swipe
- Ajouter d'autres recettes
- SEO : Schema.org Recipe, Open Graph, sitemap
