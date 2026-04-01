# Session — 2026-04-01 — Max-width layout constraint

## What was built

Applied a consistent 1440px max-width constraint across the full site layout,
and pushed the recipe grid from 4 to 5 columns max.

---

## Changes

### CSS variables (`static/css/main.css` — `:root`)

Two variables introduced:

```css
--max-w: 1440px;
--inset: max(0px, calc((100vw - var(--max-w)) / 2));
```

- `--max-w` is the single source of truth for the site width cap
- `--inset` derives the lateral offset for full-bleed elements automatically —
  resolves to `0` on viewports ≤ 1440px, grows symmetrically beyond that

### Recipe grid — 5 columns + centered

```css
grid-template-columns: repeat(auto-fill, minmax(clamp(180px, 20% - 6px, 275px), 1fr));
max-width: var(--max-w);
margin-inline: auto;
```

- Changed from `25%` (4 cols) to `20%` (5 cols)
- Ceiling moved from 300px to 275px to fit exactly 5 columns at 1440px:
  `(1440 - 4×8gap) / 5 = 275.2px`

### Fridge panel + recipe title bar

Both use `position: fixed/absolute` with `left:0; right:0`. Constrained with:

```css
left: 0; right: 0;
max-width: var(--max-w);
margin-inline: auto;
```

`margin-inline: auto` centers a fixed/absolute element when `left` and `right`
are both 0 and `max-width` is less than the viewport — same mechanic as a
normal flow block.

### Header + flavor pills

These are full-bleed bars (background spans full viewport). Constraining the
box itself would leave gaps at screen edges. Instead, inner content is aligned
via padding:

```css
/* header */
padding-inline: calc(var(--inset) + 24px);

/* pills */
padding: 6px calc(var(--inset) + 16px);
```

---

## Decisions

### Why two techniques instead of one

| Technique | Used on | Reason |
|---|---|---|
| `max-width` + `margin-inline: auto` | grid, fridge panel, recipe info | box itself is constrained |
| `padding-inline: calc(--inset + gap)` | header, flavor pills | bar must fill full viewport visually |

The only way to unify all 5 with a single technique would be adding an inner
`<div class="container">` inside the header and pills in HTML. Decided against
it to avoid touching templates for a purely cosmetic constraint.

### `--inset` resolves to 0 below 1440px

`max(0px, ...)` ensures negative values are clamped — no layout shift on
mobile or tablet. The variable is safe to use everywhere unconditionally.

### Recipe page (single) not constrained

`.recipe` is a full-viewport immersive layout (100dvh, absolute-positioned
photo). Max-width doesn't apply. Only `.recipe__info` (the title bar at the
bottom) was constrained to align with the grid aesthetic.
