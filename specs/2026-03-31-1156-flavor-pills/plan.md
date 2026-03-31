# Flavor Filter Pills

## Status: done

## Goal

Add flavor/taste filter pills above the recipe grid so visitors can discover cocktails by profile (pétillant, fruité, acidulé, etc.), independent of but composable with fridge filtering.

## Flavor Taxonomy (9 tags)

| ID | Label | Notes |
|---|---|---|
| `petillant` | Pétillant | carbonated ingredients (petillante, cola, tonic, gingembre) |
| `plat` | Sans bulles | no carbonated ingredient |
| `fruite` | Fruité | pineapple, mango, passion, apple, raspberry prominent |
| `acidule` | Acidulé | lime/lemon sour |
| `sucre` | Sucré | agave, honey, orgeat prominent |
| `epice` | Épicé | ginger, cinnamon forward |
| `amer` | Amer | tonic/amaretto forward |
| `herbace` | Herbacé | mint, basil prominent |
| `cremeux` | Crémeux | egg white foam, coconut cream |

`petillant` and `plat` are mutually exclusive. `petillant` (flavor) ≠ `petillante` (fridge ingredient slug).

## Recipe flavors

| File | flavors |
|---|---|
| amaretto-sour | `["plat", "acidule", "amer", "sucre"]` |
| bourbon-mule | `["petillant", "epice"]` |
| caipirinha | `["plat", "acidule", "sucre"]` |
| chenonceau | `["plat", "fruite", "acidule", "epice"]` |
| clover-club | `["plat", "acidule", "fruite", "cremeux"]` |
| cuba-libre | `["petillant", "sucre"]` |
| daiquiri | `["plat", "acidule", "sucre"]` |
| dark-stormy | `["petillant", "epice"]` |
| gin-basil-smash | `["plat", "acidule", "herbace"]` |
| gin-tonic | `["petillant", "amer"]` |
| godfather | `["plat", "sucre", "amer"]` |
| italian-mule | `["petillant", "epice", "fruite"]` |
| jamaican-mule | `["petillant", "epice", "fruite"]` |
| london-mule | `["petillant", "epice"]` |
| madeleine | `["plat", "fruite", "sucre", "acidule"]` |
| mai-tai | `["plat", "fruite", "acidule", "sucre"]` |
| mojito | `["petillant", "herbace", "acidule"]` |
| orange-spritz | `["petillant", "fruite", "amer"]` |
| pina-colada | `["plat", "fruite", "sucre", "cremeux"]` |
| planteur | `["plat", "fruite"]` |
| versailles | `["plat", "fruite", "acidule", "cremeux"]` |
| whisky-apple | `["plat", "fruite"]` |
| whisky-ginger-ale | `["petillant", "epice"]` |
| whisky-sour | `["plat", "acidule", "cremeux"]` |

## Filter behavior

- **Multiple pills selected = AND** (show recipes matching ALL selected flavors)
- **Flavor + fridge = AND** (must pass both)
- **Nothing selected = show all**
- State persisted in `localStorage` key `'flavors'`

## Implementation

### Recipe frontmatter
Added `flavors` array after `fridge` in all 24 `content/recettes/*.md` files.

### `layouts/index.html`

- `<nav class="flavor-pills">` placed outside `.page-body`, between fridge panel and grid
- `data-flavors="{{ $flavors }}"` attribute on each `.recipe-card`
- `applyFridgeFilter()` replaced by unified `applyFilters()`:
  - `fridgeOk`: all needed ingredients in fridge (AND)
  - `flavorOk`: `active.every(f => cardFlavors.includes(f))` — AND logic
  - card hidden if either fails
- Flavor state restored from `localStorage('flavors')` on init
- Active flavors saved to localStorage on checkbox change

### `static/css/main.css`

- `--pills-h: 44px` token added to `:root`
- `.recipes-grid` top padding uses `--header-h` only (pill bar is fixed, outside flow)
- `.flavor-pills`: `position: fixed`, `top: var(--header-h)`, `z-index: 90`, horizontally scrollable, no background
- `.flavor-pill`: frosted glass via `backdrop-filter: blur(12px)`, `text-shadow: 0 0 8px rgba(255,255,255,0.8)` for subtle white glow on text
- Active state via CSS `:has(.flavor-cb:checked)` — no JS needed for visual toggle
