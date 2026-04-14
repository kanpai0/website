# Recipe Accent Colors

**Date:** 2026-04-14  
**Status:** Shipped

## What was built

A per-recipe accent color system used on two elements of each recipe page:
- `.recipe__subtitle` (italic tagline under the title)
- `.recipe__step-num` (numbered steps in the preparation section)

Each recipe declares a single keyword in its frontmatter (`color: "vert"`). The template adds it as a body class, which triggers a CSS rule that overrides the `--accent` custom property.

## Why

The design request was to give each recipe a color linked to the most visually dominant hue in its photo against the cream background — e.g. cucumber green for gin tonic, raspberry for clover club. This adds character and visual differentiation between recipe pages without touching the overall site palette.

## Implementation

### CSS (`static/css/main.css`)

4 named tokens and a default `--accent` in `:root`:

```css
--color-vert:   #0A9A4A;
--color-rose:   #D01860;
--color-or:     #CF7C00;
--color-orange: #E04810;
--accent:       #C9865B;   /* default warm terracotta, formerly --subtitle */
```

4 body class rules override `--accent` for recipe pages:

```css
body.vert   { --accent: var(--color-vert); }
body.rose   { --accent: var(--color-rose); }
body.or     { --accent: var(--color-or); }
body.orange { --accent: var(--color-orange); }
```

The two accent-bearing selectors simply use:

```css
color: var(--accent);
```

### Template (`layouts/recettes/single.html`)

```html
<body class="recipe-page{{ with .Params.color }} {{ . }}{{ end }}">
```

No inline `style` attribute. The keyword from frontmatter becomes a semantic class.

### Frontmatter (all 24 recipes)

```yaml
color: "vert"   # one of: vert | rose | or | orange
```

### Design system (`layouts/_default/design-system.html`)

A _Recipe Accent Colors_ subsection was added after the existing Color Tokens swatches, showing all 4 accent tokens with their hex values.

## Keyword → recipe assignments

| Keyword | Hex | Rationale | Recipes |
|---------|-----|-----------|---------|
| `vert` | `#0A9A4A` | Cucumber, mint, lime, basil | gin-tonic, mojito, gin-basil-smash, caipirinha, daiquiri |
| `rose` | `#D01860` | Raspberry, hibiscus | clover-club, versailles |
| `or` | `#CF7C00` | Golden amber liquids (whisky, amaretto, coconut) | whisky-sour, whisky-apple, whisky-ginger-ale, chenonceau, amaretto-sour, godfather, madeleine, pina-colada, mai-tai |
| `orange` | `#E04810` | Aperol orange, copper mug, dark cola, tropical sunset | orange-spritz, planteur, bourbon-mule, italian-mule, jamaican-mule, london-mule, cuba-libre, dark-stormy |

## Decisions

**24 hex values → 4 keywords.** The first iteration had a unique hex per recipe (extracted by looking at each photo). This was discarded in favour of 4 semantic categories: easier to maintain, more coherent visually across the site, and the actual per-photo variation was too subtle to justify 24 different tokens.

**More vivid than the photos.** The raw dominant colors from the photos (muted greens, washed ambers) were too close to the existing `--subtitle` token. The final palette is intentionally more saturated to create contrast and energy on the page.

**`--accent` default in `:root`, not inline fallback.** Initially the selectors used `var(--accent, var(--subtitle))`. This was replaced by declaring `--accent` directly in `:root` — a single source of truth, and the selectors stay simple with just `var(--accent)`.

**Body classes instead of inline `style`.** The first version injected `style="--accent: var(--color-vert)"` on `<body>`. Replaced with `class="recipe-page vert"` — no inline styles, classes are semantic, inspectable in devtools, and the mapping lives entirely in CSS.

**`--subtitle` renamed to `--accent`.** The old `--subtitle` token (`#C9865B`) was the only consumer of the warm terracotta default. Renaming it `--accent` removes the indirection (`--accent: var(--subtitle)`) and makes the token name consistent with its role throughout the system.
