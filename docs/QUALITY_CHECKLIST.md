# Quality Checklist — Kanpai Ø

Reference for post-modification quality review. Items marked **[auto]** are checked by scripts; items marked **[manual]** require human judgment.

---

## A — Content schema [auto]

- [ ] All `fridge[]` values in recipe frontmatter match a `id="fi-<slug>"` in `layouts/partials/fridge-icons.html`
- [ ] No unknown or misspelled ingredient slugs introduced

> Checked by: `scripts/pre-commit.sh` (pre-commit hook — runs on every commit)

---

## B — Build integrity [auto]

- [ ] `hugo build` exits 0 with no warnings or errors
- [ ] No broken template references, missing partials, or invalid frontmatter

> Checked by: `scripts/pre-commit.sh` (pre-commit hook — runs on every commit)

---

## C — Accessibility [manual]

- [ ] New interactive elements (buttons, inputs, toggles) have `aria-label` or visible label
- [ ] SVG icons used decoratively have `aria-hidden="true"`
- [ ] Focus styles remain visible (not removed by new CSS)
- [ ] Color contrast meets WCAG AA for any new text/background combinations

---

## D — Design system [manual]

- [ ] New CSS custom property → added to `:root` block in `static/css/main.css`
- [ ] New reusable component → documented on `/design-system/` page (if it exists)
- [ ] Intentional visual change → run `npm run test:update` to update baselines and commit them

---

## E — Tests [auto + manual]

- [ ] `npm test` passes (visual regression + BDD scenarios)
- [ ] New user-facing behavior → new `.feature` scenario added in `features/`
- [ ] Visual baseline snapshots committed if updated

> Automated portion checked by: `scripts/preflight.sh` (called automatically by `release.sh`)

---

## F — Docs [manual]

- [ ] `CLAUDE.md` updated if architecture, commands, design tokens, or file structure changed
- [ ] README backlog current (items completed → moved to Réalisées)
- [ ] `specs/` ADR written for significant features or architectural decisions

---

## G — Legal attribution [manual]

- [ ] New recipes: `source_image` and `source_url` frontmatter fields are set
- [ ] External images or assets: license verified before use
- [ ] No unlicensed third-party content introduced

---

## H — Release readiness [manual]

- [ ] Version bump type is correct (breaking → major, new feature → minor, fix → patch)
- [ ] `specs/<date>-release-vX.Y.Z/` ADR written for significant releases
- [ ] CHANGELOG preview reviewed before tagging

---

## Quick reference — which sections apply?

| Change type                       | Sections |
|-----------------------------------|----------|
| Add/modify recipe frontmatter     | A, G     |
| Add new fridge ingredient/icon    | A, C, D, E |
| Add/modify CSS token or component | C, D, E  |
| Add new JS behavior               | C, E     |
| Add new page/layout               | B, C, F  |
| Any modification                  | B        |
| Before releasing                  | H        |
