# Recipe Page Redesign

**Date:** 2026-04-07  
**Scope:** Recipe page layout, structured frontmatter, source attribution, design system

---

## What was built

### 1. New recipe page layout (`layouts/recettes/single.html`)

Rewrote the recipe single-page template from scratch. The previous version showed a full-bleed hero photo with an overlay card. The new layout is a linear scroll optimised for mobile:

- **Centered photo** — full width, capped at 600 px, not cropped
- **Back arrow** in the header, logo centered (was left-aligned on this page)
- **Subtitle** in terracotta italic above the title (`#c9865b`)
- **Ingrédients section** — 2-column grid: ingredient name left, quantity right, no separator lines
- **Ustensiles section** — glass type rendered as an inline SVG icon with a humanised label
- **Préparation section** — ordered list with a large italic serif counter, bold step title, muted description paragraph
- **Conseils section** — italic muted prose, only rendered if tips exist
- **Footer** — shared with rest of site, recipe pages append a Sober Spirits source credit

All sections use `aria-labelledby` / `aria-label`. The `<main>` uses `role="main"` + `aria-labelledby="recipe-title"`.

### 2. Glass icon partial (`layouts/partials/glass-icon.html`)

New partial rendering a 20×20 inline SVG for 8 canonical glass types: `rocks`, `highball`, `collins`, `mule-mug`, `coupette`, `martini`, `margarita`, `vin`. Falls back to a generic glass shape for unknown slugs.

### 3. Structured frontmatter migration

Two Python scripts in `scripts/`:

**`extract-source-fields.py`** — parses `_sources/sober-spirits/*.html` (24 files) using data-id anchors and regex. Extracts `subtitle`, `glass` (mapped to 8 canonical slugs), `steps` (list of strings), `tips`. Writes results into recipe markdown frontmatter. Run once to populate all 24 files.

**`migrate-frontmatter.py`** — restructures previously flat frontmatter lists:

```
# Before
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"

steps:
  - "Versez le jus dans le verre. Ajoutez de la glace."

# After
ingredients:
  - name: "Rhum Sober Spirits 0,0 %"
    qty: "50 ml"

steps:
  - title: "Versez le jus dans le verre"
    text: "Ajoutez de la glace."
```

Ingredient parsing uses two regex patterns: `QTY unit de NAME` and `QTY NAME`. Step title is derived by splitting at the first `. `.

Run once with `--write` on all 24 files. The Hugo template was then simplified to use `.name`/`.qty` and `.title`/`.text` directly, removing all `replaceRE`/`split` logic from the template.

**Known edge case fixed:** the `remove_yaml_key` regex required `\n` after each list item, causing the final item (no trailing newline) to be left dangling in `orange-spritz.md`. Fixed the regex to `\n?` and patched the file manually.

### 4. Source attribution in footer

The shared `footer.html` partial now conditionally appends `· Recette Sober Spirits` (linked to `source_url` from frontmatter) when that field is present. Only visible on recipe pages. Renders inline within the existing footer, not as a separate element.

### 5. Design system additions (`layouts/_default/design-system.html`)

Four new sections added with `data-ds` attributes for test targeting:

| `data-ds` | What it shows |
|---|---|
| `glass-icons` | All 8 glass types via `{{ partial "glass-icon.html" }}`, labelled in monospace |
| `recipe-ingredients` | Full ingredient list with 2-col name/qty layout, section label, rule |
| `recipe-steps` | 3-step example with counter, title, and optional description |
| `recipe-tips` | Tips prose block in italic muted style |

The existing `footer` section was also updated to show two states: default (homepage) and recipe page (with Sober Spirits credit).

Visual regression baselines updated for all 11 sections via `playwright test --update-snapshots --project=visual` in Docker.

---

## Decisions

**Structured frontmatter over template logic** — qty/name split and step title derivation were initially done in the Hugo template via `replaceRE` and `split`. Moved to the markdown files instead: templates stay dumb, content is self-describing, and future editors don't need to understand template regex.

**8 canonical glass slugs** — glass type uses a fixed vocabulary (`rocks`, `highball`, `collins`, `mule-mug`, `coupette`, `martini`, `margarita`, `vin`) matching both the SVG partial and the source HTML extraction mapping. Two files (`pina-colada`, `orange-spritz`) had no extractable glass type and were set manually.

**No ingredient images** — originally planned (AI-generated per slug). Dropped in favour of pure text with quantity. Simpler, faster, accessible, easier to maintain.

**Footer partial is shared** — the source credit is handled by the partial reading `.Params.source_url`, so non-recipe pages silently get nothing. No separate template branching needed.

**Design system uses static HTML for recipe sections** — the design system page renders ingredients/steps/tips as static HTML rather than pulling a live recipe. This avoids a dependency on a specific recipe's data and makes the intent of each component explicit.
