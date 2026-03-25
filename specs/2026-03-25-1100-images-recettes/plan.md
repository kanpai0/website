# Images des recettes — 2026-03-25

## Objectif

Télécharger une image de référence pour chacune des 24 recettes importées depuis
soberspirits.com, à partir des HTML déjà versionnés dans `_sources/sober-spirits/`.

---

## Approche technique

### Script : `scripts/download-recipe-images.sh`

**Dépendances** : bash, curl (stdlib macOS)

**Stratégie de sélection de l'image :**

Le site Sober Spirits affiche plusieurs images par page (bannières, logos, vignettes
produit, photo du cocktail). La photo du cocktail est systématiquement positionnée
juste avant la section « Comment faire ».

Algorithme :

1. Tronquer le fichier HTML à la première occurrence de `Comment faire`
   (`awk '/Comment faire/{exit} {print}'`)
2. Dans cette portion, trouver le dernier attribut `src="//www.soberspirits.com/cdn/shop/..."`
   appartenant à un `<img>` (pattern : espace avant `src=` pour exclure `data-src`
   et `srcset`)
3. Préfixer par `https:` et télécharger via `curl -s -L`

**Deux variantes de chemin CDN identifiées :**

| Chemin | Recettes concernées |
|--------|---------------------|
| `cdn/shop/t/5/assets/` | 23 recettes (pattern standard) |
| `cdn/shop/files/` | orange-spritz uniquement |

Le pattern retenu (`cdn/shop/[^"]*\.webp`) couvre les deux cas.

---

## Fichiers produits

```
_sources/imgs/
├── mocktail-sober-mojito.webp         (~81 KB)
├── mocktail-sober-daiquiri.webp       (~86 KB)
└── ... (24 fichiers .webp)
```

Nommage : identique au fichier HTML source (sans l'extension `.html`).

---

## ⚠️ Points d'attention

### Image pas toujours la bonne

La sélection automatique (dernière image CDN avant « Comment faire ») ne correspond
pas toujours à la photo principale du cocktail. L'important est de sélectionner
l'image avec le verre complet.

**Recettes dont l'image a été vérifiée ou corrigée manuellement :**

| Recette       | Problème              | Action              |
|---------------|-----------------------|---------------------|
| Amaretto Sour | First paragraph image | Downloaded manually |
| Caipirinha    | First paragraph image | Downloaded manually |
| Chenonceau    | First paragraph image | Downloaded manually |
| Cuba Libre    | First paragraph image | Downloaded manually |
| Godfather     | First paragraph image | Downloaded manually |
| Madeleine     | First paragraph image | Downloaded manually |
| Maï Taï       | First paragraph image | Downloaded manually |
| Versailles    | First paragraph image | Downloaded manually |

---

## Prochaines étapes

1. Intégrer les images dans `static/images/recettes/` (renommage slug court)
2. Référencer l'image dans le frontmatter des `.md` ou directement dans le template Hugo
3. Vérifier visuellement les 24 images et corriger les cas erronés
4. Créer `layouts/recettes/single.html` — template Hugo qui lit le frontmatter
