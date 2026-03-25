# Images transparentes des recettes — 2026-03-25

## Objectif

Remplacer les photos de produits Sober Spirits (verre + bouteille + table) par des
PNG transparents générés par IA, montrant uniquement le verre et le cocktail.

Motivation : le workaround CSS `mix-blend-mode: multiply` utilisé pour simuler la
transparence est cassé sur Safari iOS.

---

## Approche

Génération par `gpt-image-1` (OpenAI) avec `background: "transparent"` natif.
Le modèle produit un PNG avec canal alpha directement — aucun post-traitement nécessaire.

**Pourquoi pas rembg :** La suppression de fond conserve tous les éléments au premier
plan (bouteille, accessoires). Ne résout pas le problème.

**Pourquoi pas Stable Diffusion local :** Testé (SDXL + rembg sur Apple Silicon) —
le verre transparent est supprimé par rembg avec le fond. Image résultante vide.

**Coût :** ~$0.04/image × 24 = ~$0.96 (one-time).

---

## Script : `scripts/generate-recipe-images.py`

**Dépendances :** `openai`, `Pillow`, `numpy` (pip)
**Auth :** variable d'environnement `OPENAI_API_KEY`
**Output :** `static/images/recettes/{slug}.png`

### Paramètres API

```python
client.images.generate(
    model="gpt-image-1",
    prompt=...,
    size="1024x1024",
    quality="medium",       # valeurs valides : low, medium, high, auto
    n=1,
    background="transparent",
)
```

> ⚠️ `response_format` n'est pas supporté par `gpt-image-1` (erreur 400).
> La réponse est toujours `b64_json`.

### Prompt template final

```
A single {glass} filled with {drink}{garnish_clause}.
Clean 3D render, isolated object, transparent background, centered,
soft diffuse lighting, slightly above eye level.
No table, no floor, no bottle, no props, no people, no camera, no shadows on background.
Absolutely nothing other than the cocktail.
```

**Ce qui a été écarté :** "Professional product photography, studio lighting" → déclenchait
des accessoires de studio, un sol avec lignes, un viseur d'appareil photo, fond sombre.

### Comportement

- Idempotent : skip si le fichier existe déjà
- Rate limit : pause de 13s entre appels (max 5/min) — sautée si le fichier existait déjà
- `--dry-run` : affiche les prompts sans appeler l'API
- `--slug <slug>` : génère une seule image

### Fallback dall-e-3

Si `gpt-image-1` échoue, repli automatique sur `dall-e-3` (URL) + suppression du fond
blanc via numpy. Moins fiable pour les verres transparents.

---

## Statut

✅ 24 PNG générés dans `static/images/recettes/`

| Slug | Taille |
|------|--------|
| amaretto-sour | 1.5 MB |
| bourbon-mule | 1.6 MB |
| caipirinha | 1.6 MB |
| chenonceau | 1.8 MB |
| clover-club | 1.5 MB |
| cuba-libre | 1.7 MB |
| daiquiri | 1.4 MB |
| dark-stormy | 1.7 MB |
| gin-basil-smash | 1.5 MB |
| gin-tonic | 1.8 MB |
| godfather | 1.5 MB |
| italian-mule | 1.7 MB |
| jamaican-mule | 1.6 MB |
| london-mule | 1.8 MB |
| mai-tai | 1.6 MB |
| mojito | 1.8 MB |
| orange-spritz | 1.6 MB |
| pina-colada | 1.4 MB |
| planteur | 1.5 MB |
| sober-madeleine | 1.5 MB |
| versailles | 1.5 MB |
| whisky-apple | 1.6 MB |
| whisky-ginger-ale | 1.6 MB |
| whisky-sour | 1.5 MB |

---

## Prochaines étapes

1. Vérifier visuellement les 24 PNG (fond en damier = transparent ✓)
2. Intégrer dans `layouts/recettes/single.html` — template Hugo
3. Supprimer dans `static/css/main.css` les deux lignes du workaround :
   ```css
   mix-blend-mode: multiply;
   filter: brightness(1.08);
   ```
4. Tester sur Safari iOS (Simulator ou device réel)
