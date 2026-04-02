# Visual Regression Tests for Design System

## What was built

Playwright-based screenshot regression tests covering the `/design-system/` page, integrated into a unified CI workflow.

### New files

| File | Purpose |
|------|---------|
| `package.json` | Single devDep: `@playwright/test` |
| `playwright.config.ts` | Chromium only, 1280×800, webServer via Python HTTP |
| `tsconfig.json` | TypeScript config scoped to test files |
| `tests/visual/design-system.spec.ts` | 6 screenshot tests, one per `[data-ds]` section |
| `tests/visual/snapshots/` | Committed Linux baseline PNGs |
| `.github/workflows/ci.yml` | Renamed from `lighthouse.yml`, now two parallel jobs |

### Modified files

| File | Change |
|------|--------|
| `.gitignore` | Added `node_modules/`, `test-results/` |
| `.github/workflows/lighthouse.yml` | Renamed → `ci.yml`, extended with `visual-regression` job |

---

## What is tested

The design system page (`/design-system/`) has `data-ds` attributes on all sections. Each test screenshots one section and compares against the committed baseline.

| Test | Selector |
|------|----------|
| colors | `[data-ds="colors"]` |
| typography | `[data-ds="typography"]` |
| flavor-pills | `[data-ds="flavor-pills"]` |
| fridge-items | `[data-ds="fridge-items"]` |
| buttons | `[data-ds="buttons"]` |
| recipe-card | `[data-ds="recipe-card"]` |

Threshold: `maxDiffPixelRatio: 0.01`.

Full-page screenshot was considered and dropped — the 6 section tests already cover the entire page with more actionable failure diffs.

---

## Key decisions

### Playwright over alternatives
- Cypress requires a paid plugin for visual regression; Playwright has `toHaveScreenshot()` built in.
- BackstopJS is heavier and JSON-config-heavy.
- Chosen for: zero extra deps, native screenshot diffing, `--update-snapshots` CLI flag.

### Docker for local test execution
Baselines must be Linux PNGs to match CI (ubuntu-latest). Running Playwright inside the official Docker image (`mcr.microsoft.com/playwright:v1.59.1-jammy`) locally ensures identical font rendering regardless of developer OS (macOS/Windows/Linux).

```bash
npm test          # hugo build + docker run playwright test
npm run test:update  # same + --update-snapshots (regenerate baselines)
```

Snapshots are **always generated locally via Docker**, never from CI. The `workflow_dispatch` update-snapshots pattern was considered and dropped as unnecessary.

### CI: no snapshot regeneration in CI
CI only reads and compares against committed baselines. If a visual change is intentional, the developer runs `npm run test:update` locally (in Docker) and commits the new PNGs.

### CI workflow consolidation
The standalone `visual-regression.yml` was merged into `lighthouse.yml` (renamed `ci.yml`) as two parallel jobs:

- `lighthouse`: runs only on `push` to `main` (audits the live site post-deploy)
- `visual-regression`: runs on `push` and `pull_request` targeting `main` (blocks bad merges)

The `audit` job was renamed `lighthouse` for clarity.

### webServer: Python HTTP server
Uses `python3 -m http.server` (zero extra dep) to serve the pre-built `public/` directory. Hugo must be built before running tests — baked into both `npm test` and `npm run test:update` scripts.

---

## Snapshot update workflow

When a design change is intentional:

1. `npm run test:update` — rebuilds Hugo, runs Playwright in Docker, overwrites baselines
2. `git add tests/visual/snapshots/ && git commit -m "test: update visual baselines"`
3. Push — CI passes against the new baselines

---

## Branch protection (one-time, manual)

To block merges to `main` when visual regression fails:

1. GitHub → Settings → Branches → Add rule for `main`
2. Enable "Require status checks to pass before merging" → add `visual-regression`
3. Enable "Do not allow bypassing"
