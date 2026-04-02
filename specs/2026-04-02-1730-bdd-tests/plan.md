# BDD Functional Tests (playwright-bdd)

## What was built

End-to-end functional tests for the two critical filter systems — Saveurs (flavor pills) and Mon frigo (fridge panel) — plus navigation smoke tests. Written in Gherkin (`.feature` files), run by Playwright via the `playwright-bdd` bridge.

### New files

| File | Purpose |
|------|---------|
| `tests/bdd/features/saveurs.feature` | 4 scenarios: default visibility, single flavor filter, AND logic, deselect restores |
| `tests/bdd/features/frigo.feature` | 4 scenarios: open/close panel, uncheck ingredient, combined fridge+flavor |
| `tests/bdd/features/navigation.feature` | 3 scenarios: homepage loads, recipe detail, logo returns home |
| `tests/bdd/steps/shared.steps.ts` | `Given` steps: homepage nav, filter reset, recipe detail nav |
| `tests/bdd/steps/saveurs.steps.ts` | Flavor check/uncheck actions + visibility assertions |
| `tests/bdd/steps/frigo.steps.ts` | Panel open/close, ingredient uncheck, visibility assertions |
| `tests/bdd/steps/navigation.steps.ts` | Card count, click, URL assertions |

### Modified files

| File | Change |
|------|--------|
| `package.json` | Added `playwright-bdd ^8.5.0`; extracted `build` and `pw` scripts; added `test:visual` and `test:bdd` |
| `playwright.config.ts` | Refactored to multi-project (`visual`, `bdd-mobile`, `bdd-desktop`); added `reporter: 'dot'`; silenced Python access logs |
| `.gitignore` | Added `tests/.generated/` |

---

## What is tested

### Saveurs filter
- All cards visible by default (no active flavor)
- Selecting one flavor hides cards that don't match
- Selecting two flavors applies AND logic (both must be present)
- Deselecting restores all cards

### Frigo filter
- Fridge panel opens and closes via `.fridge-btn` / `.fridge-panel__close`
- Unchecking an ingredient hides all recipes that require it (`data-fridge`)
- Fridge + flavor filters combine: no visible card can require the unchecked ingredient OR lack the selected flavor

### Navigation
- At least one recipe card is visible on homepage
- Clicking a card navigates to `/recettes/<slug>/`
- Clicking the logo returns to `/`

---

## Key decisions

### playwright-bdd over @cucumber/cucumber
`@cucumber/cucumber` pulls ~414 transitive dependencies and uses its own runner (incompatible with Playwright fixtures). `playwright-bdd` is a thin bridge (~12 direct deps) that generates Playwright spec files from `.feature` files, keeping Playwright Test as the runner. Visual regression and BDD tests share the same runner and config.

### Mobile-first: bdd-mobile is the primary BDD project
`bdd-mobile` (`Pixel 5`, 393×851) runs all scenarios first. `bdd-desktop` (`Desktop Chrome`) re-runs the same scenarios as a smoke check. No separate responsive feature files needed — viewport differences are exercised automatically.

### `tests/.generated/` is gitignored
`bddgen` output is ephemeral — regenerated before every test run via `npx bddgen && npx playwright test`. Committing generated files would create noise and drift.

### `page.evaluate` for hidden checkboxes
Both `.flavor-cb` and `.fridge-cb` are `display: none` in CSS (custom-styled via `:has()` on their parent labels). Playwright refuses to interact with `display: none` elements even with `force: true`. The fix is to drive them via `page.evaluate`: set `.checked` directly and dispatch a `change` event with `{ bubbles: true }`, which triggers the app's event listeners (`saveFlavors` / `saveFridge` → `applyFilters`).

### `Then I should be on …` vs `Then I am on …`
`Given I am on the homepage` (navigation) and `Then I am on the homepage` (URL assertion) would conflict in playwright-bdd since Given/When/Then match step text regardless of keyword. The assertion steps were renamed to `Then I should be on …` to disambiguate.

### Background: clear localStorage + reload
Resetting filter state between scenarios requires clearing both `fridge` and `flavors` from `localStorage` then reloading the page. This guarantees a deterministic initial state: all fridge ingredients checked (app default when `localStorage` key is absent), no flavor active.

### Snapshot rename after project rename
When the visual project was renamed from `chromium` to `visual`, Playwright's snapshot naming convention changed (`*-chromium-linux.png` → `*-visual-linux.png`). The 6 baseline files were renamed in-place rather than regenerating them.

### Python server access log silenced
`python3 -m http.server` writes all request lines to stderr. Added `2>/dev/null` to the `webServer.command` to keep test output clean alongside `reporter: 'dot'`.

### Scripts factored into primitives
`hugo build` → `npm run build`. The full Docker run prefix → `npm run pw`. Test scripts are now `npm run build && npm run pw -- <playwright invocation>`, eliminating ~80 chars of repeated string.

---

## Test run commands

```bash
npm run test:bdd     # hugo build + docker bddgen + playwright --project=bdd-mobile --project=bdd-desktop
npm run test:visual  # hugo build + docker playwright --project=visual
npm test             # hugo build + docker bddgen + playwright (all projects)
```
