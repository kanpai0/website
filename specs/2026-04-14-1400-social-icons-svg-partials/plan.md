# Social Icons & SVG Partials

**Date:** 2026-04-14  
**Status:** Shipped

## What was built

### 1. Social icons in the footer

Five social network icons added to `layouts/partials/footer.html`, displayed as a row above the copyright/legal line:

| Platform | Handle | URL |
|----------|--------|-----|
| Instagram | @kanpai0 | instagram.com/kanpai0 |
| Pinterest | kanpai0 | pinterest.com/kanpai0 |
| YouTube | @kanpaizero | youtube.com/@kanpaizero |
| Threads | @kanpai0 | threads.net/@kanpai0 |
| Bluesky | kanpai0 | bsky.app/profile/kanpai0.bsky.social |

Icons are 16px, `fill: currentColor`, `--muted` by default, `--sage` on hover. No external dependency — inline SVG paths from Simple Icons.

The footer layout changed from a single flex row to a column: social row on top, copyright/legal row below.

### 2. SVG icon partials

Two new partials centralising all inline SVG icons:

**`layouts/partials/icon-social.html`**  
Usage: `{{ partial "icon-social.html" "instagram" }}`  
Slugs: `instagram` | `pinterest` | `youtube` | `threads` | `bluesky`  
Filled 24×24 icons, `fill: currentColor`.

**`layouts/partials/icon-ui.html`**  
Usage: `{{ partial "icon-ui.html" "close" }}`  
Names: `close` | `back`  
Stroked 20×20 icons, `stroke: currentColor`, `stroke-width: 2`.

All inline SVGs were removed from production templates and replaced with partial calls:

| Template | Icons migrated |
|----------|---------------|
| `partials/footer.html` | 5 social icons |
| `layouts/index.html` | close (fridge panel) |
| `layouts/recettes/single.html` | back (header arrow) |

### 3. Design system section

A `data-ds="social-links"` section was added to the design system, showing:
- Default state: all 5 icons at `--muted`
- Hover state: Instagram at `--sage`

The existing `data-ds="footer"` section was updated to use `{{ partial "footer.html" . }}` and `{{ partial "footer.html" (dict "Params" (dict "source_url" "#")) }}` instead of hardcoded HTML, so it always reflects the real footer.

The design system buttons section was also updated to use `icon-ui` partials.

A visual regression test for `social-links` was added to `tests/visual/design-system.spec.ts`.

## Why

The footer needed social network links as part of the brand presence build-out (handles were already reserved — see `SOCIAL.md`). The icons needed to be discrete: one color, small, no hover animation beyond a color shift.

The SVG partial refactor was triggered by the observation that adding social icons meant duplicating large SVG path strings in both `footer.html` and the design system. The existing `glass-icon.html` pattern (one partial, one argument) was the right model to extend to all icon families.

## Decisions

**Inline SVG, not an icon font or external sprite.** No build pipeline, no HTTP request, no FOUT risk. Consistent with the project's zero-dependency philosophy.

**`icon-social` and `icon-ui` as separate partials, not one unified `icon`.** The two families differ structurally: social icons are filled 24×24, UI icons are stroked 20×20. Merging them into a single partial with a namespace (`icon "social/instagram"`) would add complexity for no gain — they are never used interchangeably.

**`glass-icon.html` not renamed.** It predates this work and is already called in many places. Renaming it to `icon-glass.html` for consistency would be churn with no functional benefit.

**Threads and Bluesky included.** Both handles are reserved (see `SOCIAL.md`). Even if the accounts are inactive today, including them signals presence and costs nothing. TikTok and X were deliberately excluded per project policy.

**Footer uses `{{ partial "footer.html" . }}` in the design system.** The previous design system hardcoded footer HTML that drifted from the real template. Using the partial directly means the design system always shows the true component — no sync burden.

**Design system shows only one hover example.** A hover state for all 5 icons would be redundant; the state is purely a color change, demonstrated once (Instagram) is sufficient.
