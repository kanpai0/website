# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make bootstrap      # fresh clone: mise install + npm ci + git hooks
make install-hooks  # (re)install git hooks from scripts/git-hooks/

hugo serve          # Local dev server with hot reload
hugo build          # Generate static site to public/

make serve          # alias → hugo serve
make build          # alias → hugo build
make release        # bump version, generate CHANGELOG, commit, tag, push
make release-dry    # preview release without writing anything
make preflight      # full local quality gate before pushing (npm test)
make validate       # pre-commit gate: hugo build + check-sh/lint-sh/check-pw-version/check-fridge/check-flavors/test-unit
make validate-ci    # CI fan-out of the same checks, no hugo build (public/ comes from the build job's artifact)
make check-sh       # syntax-check all shell scripts (bash -n)
make lint-sh        # lint all shell scripts (shellcheck)
make check-pw-version # verify Playwright version pinned consistently (package.json + CI)
make doctor         # show pinned versions + latest available Hugo
```

## Toolchain

Tool versions are pinned in [`.mise.toml`](.mise.toml) and installed with
[`mise`](https://mise.jdx.dev/): `hugo-extended`, `node`, `python`, `git-cliff`,
`shellcheck`, `jq`. The same file drives CI (`jdx/mise-action` in
`.github/workflows/ci.yml`), so local and CI cannot drift — bumping Hugo means
editing `.mise.toml` only.

Prerequisites on a new machine: `brew install mise` (plus `make`, and Docker for
`npm test`), then `make bootstrap`. Activate mise in the shell
(`eval "$(mise activate zsh)"`) so pinned binaries land in `PATH`; otherwise
prefix commands with `mise exec --`.

Out of mise scope: Docker (Playwright image pinned in `package.json`) and the
Python dependencies of `scripts/*.py` (still managed by pip in `.venv`).

## Release workflow

```bash
bash scripts/release.sh              # auto bump (breaking→major, feat→minor, else patch)
bash scripts/release.sh --bump minor # override bump type
bash scripts/release.sh --dry-run    # preview only
```

Requires `git-cliff` (pinned in `.mise.toml` — run `make bootstrap`). Script requires a clean working tree.
Updates `hugo.toml`, `CHANGELOG.md`, `README.md`, writes `specs/<date>-release-vX.Y.Z/release-notes.md`,
then commits, tags, and pushes. Changelog format is defined in `cliff.toml`.

### Git hooks

Both `pre-commit` and `commit-msg` are versioned in `scripts/git-hooks/` and
installed into `.git/hooks/` by `make install-hooks` (also run by `make bootstrap`).
`pre-commit` runs `make validate`; `commit-msg` enforces Conventional Commits
(required by `git-cliff` to compute the next version).

## Architecture

**Hugo static site** — no Node.js, no build pipeline beyond `hugo`. Deploys automatically to Cloudflare Pages on push to main.

```
content/recettes/    # 24 recipe markdown files (source of truth)
layouts/             # Hugo templates
  index.html         # Homepage: recipe grid + fridge panel + filtering JS
  recettes/
    single.html      # Individual recipe page
  partials/
    fridge-icons.html        # SVG sprite (~25 ingredient/spirit icons)
    fridge-panel-body.html   # Fridge filter panel component
static/css/main.css  # All styles (~350 lines, no framework)
static/images/recettes/  # WebP cocktail images
scripts/             # Python/bash utilities for content & image generation
specs/               # Timestamped planning docs (ADRs)
design/              # Design file (kanpai0.pen) + mockups
docs/                # Reference docs, quality checklist, marketing
```

## Recipe Content Structure

Each recipe frontmatter:
```yaml
---
title: Mojito
slug: mojito
draft: false
fridge: ["rhum", "citron-vert", "agave", "menthe", "petillante"]
source_image: "https://..."
source_url: "https://..."
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"
---
```

The `fridge` array drives the ingredient filter system. Values must match icon IDs defined in `fridge-icons.html` (format: `fi-<slug>` — e.g., `#fi-rhum`, `#fi-whisky`).

## Filtering System (Homepage)

Vanilla JS + localStorage, no framework. Each recipe card has `data-fridge="rhum citron-vert menthe"` attributes. The fridge panel lets users check which ingredients they have; cards without matching ingredients get `.fridge-hidden`. The dot indicator on the fridge button uses CSS `:has()` pseudo-class — requires modern browser support.

## Design Tokens

CSS variables defined in `main.css`:
- `--bg`: #F7F4EE (cream background)
- `--ink`: #1A1A18 (text)
- `--sage`: #3D5A3E (primary accent)
- `--muted`: #6B6860
- `--border`: #E8E3D8

Fonts: Playfair Display (headings, italic), Inter (body). Mobile-first with `clamp()` for responsive type.

## Deployment

Push to `main` → GitHub Actions builds with the Hugo version pinned in `.mise.toml`, then deploys `public/` to Cloudflare Pages via `wrangler`. Domain: kanpai0.co (301 from kanpai0.com).

## Quality Gates

After completing any modification, check the relevant sections of `docs/QUALITY_CHECKLIST.md`:

| Change type                       | Checklist sections |
|-----------------------------------|--------------------|
| Add/modify recipe frontmatter     | A, G               |
| Add new fridge ingredient/icon    | A, C, D, E         |
| Add/modify CSS token or component | C, D, E            |
| Add new JS behavior               | C, E               |
| Add new page/layout               | B, C, F            |
| Any modification                  | B                  |

Run `make preflight` before pushing — validates schema, build, and all tests.
Run `npm run test:update` when visual baselines need updating after intentional design changes.

**Pre-commit hook** — runs `make validate` (hugo build + shell/Playwright checks +
fridge/flavors schema + unit tests) on every commit.
Reinstall after fresh clone: `make install-hooks` (also done by `make bootstrap`).

**Schema invariant:** `fridge[]` values MUST match `id="fi-<slug>"` in `layouts/partials/fridge-icons.html`.
Adding a new ingredient requires 3 steps: (1) `<symbol>` in `fridge-icons.html`, (2) `<label>` in `fridge-panel-body.html`, (3) update recipes using it.
