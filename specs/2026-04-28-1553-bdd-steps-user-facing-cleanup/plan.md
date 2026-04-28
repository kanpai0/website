# BDD steps: user-facing interactions, no POM indirection

## Context

`docs/test-playwright.md` documents three UI test patterns: User Facing Attributes, Page Object Model, Screenplay. The question raised at the start of this session was whether any of them apply to our existing Playwright BDD tests under `tests/bdd/`.

The codebase being a 24-recipe Hugo static site with three feature files (~30 scenarios), the choice of pattern matters less than the choice of *which* concrete improvements actually pay off. This plan records what was changed and what was deliberately not.

## Why

Two pain points in the original BDD steps were worth fixing:

1. **Imperative for-loops over `.recipe-card`** — four steps in `frigo.steps.ts` and `saveurs.steps.ts` iterated over every card, parsed `data-fridge` / `data-flavors`, and asserted per-element. The intent ("no visible card requires X" / "no visible card lacks flavor X") is declarative; the implementation was not.
2. **`page.evaluate` toggling checkboxes by ID** — the original code did `el.checked = false; dispatchEvent('change')`. This bypasses every layer of the UI: the visible `<label>` the user actually clicks, the `for=` association that links it to the input, the click→change pipeline. A regression that breaks the `label[for]` wiring would not be caught by these tests.

Neither pain point was about test fragility on CSS selectors — both files passed reliably. The issue was that the tests were simulating a user *less faithfully than they could*, and were harder to read than they needed to be.

## How

Applied two narrow changes across `frigo.steps.ts` and `saveurs.steps.ts`:

### 1. Token-attribute selectors replace for-loops

`data-fridge="rhum citron-vert menthe"` is whitespace-separated; CSS supports the `~=` token operator for exactly this. Replacing the loops:

```ts
// Before: for-loop reading data-fridge, asserting hidden class per card
// After:
await expect(
  page.locator(`.recipe-card:not(.fridge-hidden)[data-fridge~="${ingredient}"]`),
).toHaveCount(0);
```

One assertion replaces N per-card assertions, and the assertion itself is a sentence: "no visible card requires this ingredient". Same trick for `data-flavors~=` in saveurs, including the AND-logic case (two assertions, one per flavor).

### 2. Click the visible `<label>` instead of `page.evaluate`

The native `<input type="checkbox">` for both fridge ingredients (`.fridge-cb`) and flavor pills (`.flavor-cb`) has `display: none` (`static/css/main.css:514`, `static/css/main.css:322`). The actual user interaction is clicking the styled `<label>` that wraps it.

```ts
// Idempotent: only click if the desired state isn't already met
const checkbox = page.locator(`#fr-${ingredient}`);
if (await checkbox.isChecked()) {
  await page.locator(`label[for="fr-${ingredient}"]`).click();
}
```

This exercises the real DOM path (label click → input toggle → change event) and would catch `for=` regressions.

## Decisions

### Rejected: a `HomePage` POM (class-based)

A first iteration introduced `tests/bdd/homePage.ts` exporting a `HomePage` class with methods `openFridge`, `closeFridge`, `uncheckIngredient`, plus locator getters. Reverted because:

- Tests passed (30/30) but the abstraction added an indirection that wasn't earning its keep at this size (3 feature files).
- Two of the helper methods ended up CSS-based anyway (see next decision), so the "user-facing" branding was misleading.
- Project preference: prefer plain functions over classes; introduce abstractions only when state, identity, or polymorphism actually requires it.

### Rejected: `getByRole('dialog', { name: 'Mon frigo' })` for the panel

The fridge panel toggles via `aria-hidden="true"`/`"false"`. When closed, the dialog leaves the accessibility tree, so `getByRole('dialog')` returns nothing and `expect(...).toHaveAttribute('aria-hidden', 'true')` times out. The role-based locator is fundamentally incompatible with asserting on the very ARIA state that controls a11y-tree presence. Stayed with `page.locator('#fridge-panel')`.

### Rejected: `getByRole('checkbox', { name: ... })` for ingredients

The `<input>` is `display: none`, which removes it from the a11y tree and makes the role-based query miss it. The user-facing element is the `<label>` — the click-the-label approach above is the genuine match for "user facing attributes" in this DOM, more so than chasing a role on a hidden input.

### Rejected: `getByRole('button', { name: 'Mon frigo' / 'Fermer' })` for open/close

The intermediate POM iteration switched these to role-based locators. A second pass reverted to `.fridge-btn` / `.fridge-panel__close` because the gain was marginal (two clicks) and the original CSS-class form is no less stable than `aria-label` text. Kept the diff focused on the two changes that matter.

### Skipped: navigation.steps.ts and shared.steps.ts

Neither file has the for-loop pattern or the `page.evaluate` hack. Touching them "for consistency" would have been churn.

### Skipped: Screenplay pattern

`docs/test-playwright.md` itself notes Screenplay's payoff is in "suites de tests larges et évolutives". 30 scenarios with one user role does not qualify.

## Files changed

- `tests/bdd/steps/frigo.steps.ts` — rewritten: token-attribute assertions, click-the-label uncheck, `When` steps no longer assert state (the following `Then` steps own assertions).
- `tests/bdd/steps/saveurs.steps.ts` — same treatment for select/deselect and the AND-logic assertion.

## When to revisit

Reasons that would justify reintroducing a `homePage.ts` (or similar) abstraction:

- The DOM changes break selectors in 3+ places at once, making a single point of update useful.
- The BDD suite grows past ~10 feature files / 100 scenarios and duplication of locator strings becomes a real maintenance cost.
- A second test mode (e.g. component tests, alternative entry points) needs to share the same locators.

Until then, the steps are the abstraction.