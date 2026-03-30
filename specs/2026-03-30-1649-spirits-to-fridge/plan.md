# Spirits → Fridge Migration — Plan

**Date:** 2026-03-30
**Status:** ✅ Implemented
**Follows:** `specs/2026-03-27-fridge-icons/plan.md`

---

## Goal

Remove the spirit filter pill bar and move spirits into the fridge panel as first-class ingredient tiles — same UI, same filtering logic, no dedicated variables or separate data attributes.

---

## Design Decisions

- **Spirits are ingredients**: no special JS handling, no `SPIRITS` array, no dedicated `data-spirits` attribute — spirits live in `FRIDGE` and in `data-fridge` exactly like menthe or citron-vert
- **Brand naming**: Sober Spirits brand names displayed on tiles (Sober Rhum 0.0%, Sober Whisky 0.0%, Sober Gin 0.0%, Sober Amaretto 0.0%, Sober Spritz 0.0%)
- **Same 4-column grid**: spirits use the default fridge-grid layout, no overrides
- **Frontmatter merge**: `spirits: [rhum]` and `fridge: [citron-vert, ...]` are merged into a single `fridge: [rhum, citron-vert, ...]` key on every recipe — one source of truth
- **Section order**: "Spiritueux sans alcool" is the first section in the fridge panel

---

## Files Changed

| File | Change |
|---|---|
| `content/recettes/*.md` | Merged `spirits` values into `fridge` array (spirits appear first in the list) |
| `layouts/partials/fridge-icons.html` | Added 5 spirit icons: `fi-rhum` (bottle), `fi-whisky` (lowball glass), `fi-gin` (tall bottle), `fi-amaretto` (squat bottle), `fi-spritz` (stemmed glass + bubble) |
| `layouts/partials/fridge-panel-body.html` | **Created** — extracted panel body content from `index.html`; added "Spiritueux sans alcool" section first |
| `layouts/index.html` | Removed spirit `filter-cb` inputs and `<nav class="filters">`; fridge panel now uses `{{ partial "fridge-panel-body.html" . }}`; recipe cards use single `data-fridge` attr; JS simplified |
| `static/css/main.css` | Removed `--filters-h`, all filter/pill CSS rules; grid top-padding tightened; first `.fridge-section__title` margin-top reset to 0 |

---

## Template

Recipe cards emit a single attribute combining spirits and ingredients:

```hugo
{{- $fridge := delimit .Params.fridge " " }}
<a class="recipe-card" data-fridge="{{ $fridge }}">
```

`default slice` guard needed if any recipe lacks the `fridge` key:

```hugo
{{- $fridge := delimit (default slice .Params.fridge) " " }}
```

---

## JS

Single flat array, no SPIRITS variable, standard load/save/filter:

```js
const FRIDGE = [
  'rhum','whisky','gin','amaretto','spritz',
  'menthe','citron-vert', ...
];

function applyFridgeFilter() {
  const available = getAvailable();
  document.querySelectorAll('.recipe-card').forEach(card => {
    const needed = (card.dataset.fridge || '').split(' ').filter(Boolean);
    card.classList.toggle('fridge-hidden', !needed.every(ing => available.includes(ing)));
  });
}
```

---

## Partial Structure

```
layouts/partials/
├── fridge-icons.html       SVG sprite (21 ingredient + 5 spirit symbols)
└── fridge-panel-body.html  All sections + tiles (referenced from index.html)
```

---

## Possible Next Steps

- Replace spirit tiles with flavour pills (Onctueux, Épicé, Doux…) — spirits section will be removed
- Add "Tout cocher / Tout décocher" shortcut in the panel body
