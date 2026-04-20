# Page 404 — Easter egg recette secrète

## Pourquoi

Le site n'avait pas de page 404. Plutôt qu'une page d'erreur générique, l'idée est d'en faire un easter egg cohérent avec l'identité du site : une fiche recette humoristique, en français, avec un faux cocktail thématisé autour du vide, de l'absence ou du réveil.

## Ce qui a été construit

### `layouts/404.html`

Hérite de `baseof.html` via les blocs Hugo (`define "title"`, `define "body"`, etc.). Reprend exactement la structure visuelle d'une fiche recette (`recipe`, `recipe__photo`, `recipe__body`, `recipe__section`…).

Au chargement, du JS inline sélectionne aléatoirement une recette parmi trois et injecte son contenu dans le DOM.

### Les trois fausses recettes

| Slug | Couleur | Concept |
|---|---|---|
| `404-verre-deau` | orange | Un verre d'eau — recette minimaliste et honnête |
| `404-air-de-rien` | pink | Un verre vide — cocktail conceptuel, zéro calorie, zéro contenu |
| `404-reveil-brutal` | gold | Double café — pour explorateurs égarés |

### Images

Trois slugs ajoutés dans `scripts/generate-recipe-images.py` (tables GLASS, DRINK, GARNISH) pour génération via gpt-image-1, identique aux autres recettes. Les images sont à générer manuellement :

```bash
source .venv/bin/activate
python scripts/generate-recipe-images.py --slug 404-verre-deau
python scripts/generate-recipe-images.py --slug 404-air-de-rien
python scripts/generate-recipe-images.py --slug 404-reveil-brutal
```

## Décisions

**Héritage de `baseof.html`** — La page utilise les blocs Hugo au lieu de dupliquer le `<head>`. `single.html` ne le fait pas encore ; c'est une incohérence connue, non corrigée ici pour ne pas élargir le scope.

**JS inline plutôt que trois fichiers Hugo** — Les trois recettes n'ont pas de fichiers markdown (elles n'apparaissent pas dans la grille, ne sont pas indexées). Tout le contenu vit dans le template. L'aléatoire se fait côté client au chargement.

**Extension `.png`** — Le script génère des PNG (transparence via gpt-image-1). Contrairement aux recettes normales référencées en `.webp`, les images 404 sont en `.png`. À homogénéiser si la pipeline de conversion est un jour automatisée.

**Cloudflare Pages** — Aucune configuration nécessaire. Cloudflare détecte automatiquement `public/404.html` généré par Hugo.
