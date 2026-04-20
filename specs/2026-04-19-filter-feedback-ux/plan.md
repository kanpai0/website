# ADR: Filter Feedback UX — Non-matching Recipes

**Status:** Deferred  
**Date:** 2026-04-19

## Context

When fridge or flavor filters are active, some recipe cards don't match. The current behavior hides them (`display: none`). Two approaches were considered to give users better feedback about filtered-out content.

## Options Considered

### Option A — Dim + reorder (rejected for now)
Show non-matching cards at 20% opacity, pushed to the end of the grid via CSS `order: 1`. Cards remain in the DOM and visible.

**Rejected because:**
- ARIA implications unclear: screen readers don't perceive opacity, so filter state is invisible to them.
- Dimmed cards still appear in tab order, which is confusing for keyboard users.
- Visual noise when many recipes are filtered out.
- Would need a visually-hidden `<span>` toggled per card to communicate state to assistive tech — adds complexity without a clear UX gain.

### Option B — Counter + reset (preferred direction, not yet implemented)
Keep recipes hidden (`display: none`). Add below the grid:
- A counter: "N recettes masquées" (appears only when filters are active).
- A button to reset flavor pills.
- A link to open the fridge panel to reset fridge selection.

**Why this is better:**
- No accessibility ambiguity — hidden cards are truly removed from the reading/tab order.
- The counter gives users awareness of what they're missing without visual clutter.
- Reset affordances are contextual: they appear only when needed.

## Decision

Revert Option A. Keep `display: none` behavior. Implement Option B in a future iteration.

## Implementation Notes for Option B

### Counter — why CSS-only was rejected

CSS counters fire during layout. `display: none` removes elements from the formatting context entirely, so `counter-increment` on `.fridge-hidden` elements produces no result. There is no pure-CSS way to count hidden elements.

The inversion (counting *visible* cards with `:not(.fridge-hidden)`) would work in CSS, but produces "N disponibles" copy — which requires knowing the total to be meaningful, adds visual noise when nothing is filtered, and still needs JS to show/hide the banner conditionally. The CSS-only path offers no real simplification.

**Decision:** use JS. Count hidden cards after each `applyFilters()` call with `querySelectorAll('.recipe-card.fridge-hidden').length`. Toggle `hidden` on the banner element; set count in a `<span>`. `aria-live="polite"` on the banner announces changes to screen readers automatically.

### Reset controls (JS still needed)
- Reset flavor: uncheck all `.flavor-cb`, clear localStorage key `flavors`, call `applyFilters()`.
- Reset fridge: link or button that opens the fridge panel (trigger existing fridge toggle).
- Show/hide `.filter-summary` only when filters are active — can be done via `:has()` on the body or a wrapper, or a simple JS class toggle.
