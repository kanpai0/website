# Fridge Ingredient Icons — Plan

**Date:** 2026-03-27
**Status:** ✅ Implemented
**Follows:** `specs/2026-03-26-1759-fridge/plan.md`

---

## Goal

Replace the `✓` text mark on fridge tiles with a recognizable line icon per ingredient — more visual, more polished.

---

## Technique: Inline SVG sprite

**Chosen over external file and icon fonts because:**
- `currentColor` works — a single CSS rule (`stroke: var(--sage)`) recolors all icons on check
- Zero extra HTTP requests — sprite injected once into the HTML at build time via Hugo partial
- Crisp at any DPI, scales perfectly
- Adding an icon = adding a `<symbol>` block in the partial
- Reuse on recipe pages = include the same partial (no file duplication)

**On external SVG file (`static/images/`):**
- `currentColor` does NOT work cross-document — CSS from the HTML document cannot reach symbols in an external SVG
- CSS `filter` can approximate color changes but is fragile and imprecise for a clean muted/sage toggle
- Would make sense if caching across many pages with a heavy icon set — not the case here

---

## Files Changed

| File | Change |
|---|---|
| `layouts/partials/fridge-icons.html` | Created — SVG sprite with 21 `<symbol>` elements |
| `layouts/index.html` | Added `{{ partial "fridge-icons.html" . }}` at top of `<body>`; replaced all 21 `<span class="fridge-item__check">✓</span>` with `<svg class="fridge-item__icon" aria-hidden="true"><use href="#fi-{slug}"></use></svg>` |
| `static/css/main.css` | Removed `.fridge-item__check`; added `.fridge-item__icon` and its `:has(:checked)` variant |
| `layouts/index.html` | Fixed `delimit` nil error — wrapped `.Params.spirits` and `.Params.fridge` with `default slice` for recipes missing those frontmatter fields |

---

## SVG Sprite Structure

```html
<!-- layouts/partials/fridge-icons.html -->
<svg xmlns="http://www.w3.org/2000/svg" style="display:none" aria-hidden="true">
  <symbol id="fi-menthe" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="1.5"
          stroke-linecap="round" stroke-linejoin="round">
    <!-- paths -->
  </symbol>
  <!-- × 21 -->
</svg>
```

All icons: 24×24 viewBox, stroke-only, `stroke-width="1.5"`, `stroke-linecap/join="round"`, no fill.

---

## CSS

```css
.fridge-item__icon {
  width: 20px;
  height: 20px;
  stroke: var(--muted);
  transition: stroke 0.15s;
}

.fridge-item:has(.fridge-cb:checked) .fridge-item__icon {
  stroke: var(--sage);
}
```

---

## Icon Mapping (21 icons)

| id | Concept | Source |
|---|---|---|
| `menthe` | leaf + center vein | Custom |
| `citron-vert` | citrus cross-section (circle + radial lines) | Custom |
| `citron-jaune` | lemon oval + nubs | Custom |
| `basilic` | herb sprig, 3 leaves on stem | Custom |
| `ananas` | pineapple oval + crown | Custom |
| `framboise` | cherry pair | Lucide `cherry` |
| `mangue` | teardrop fruit + stem | Custom |
| `passion` | 5-petal flower | Custom |
| `pomme` | apple + leaf | Lucide `apple` |
| `agave` | succulent fan, 5 pointed leaves | Custom |
| `orgeat` | almond oval + center vein | Custom |
| `hibiscus` | 5-petal flower (tighter) | Custom |
| `vanille` | elongated curved pod | Custom |
| `miel` | honey droplet | Lucide `droplet` |
| `cola` | cup + straw | Custom |
| `gingembre` | knobbly root | Custom |
| `tonic` | bottle + label line | Custom |
| `petillante` | glass + 3 bubble dots | Custom |
| `oeuf` | egg | Lucide `egg` |
| `creme-coco` | coconut halved | Custom |
| `cannelle` | bundle of sticks | Custom |

---

## Follow-up

- `specs/2026-03-30-1649-spirits-to-fridge/plan.md` — spirits moved into fridge panel as tiles, filter bar removed

---

## Possible Next Steps

- Audit each icon visually and refine paths that are ambiguous at 20px
- Include partial on recipe pages if ingredient icons are needed there
- Consider adding a `title` element inside each `<symbol>` for screen reader fallback
