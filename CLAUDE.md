# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
hugo serve          # Local dev server with hot reload
hugo build          # Generate static site to public/

make serve          # alias → hugo serve
make build          # alias → hugo build
make release        # bump version, generate CHANGELOG, commit, tag, push
make release-dry    # preview release without writing anything
make doctor         # show installed versions + latest available Hugo
```

## Release workflow

```bash
bash scripts/release.sh              # auto bump (breaking→major, feat→minor, else patch)
bash scripts/release.sh --bump minor # override bump type
bash scripts/release.sh --dry-run    # preview only
```

Requires `git-cliff` (`brew install git-cliff`). Script requires a clean working tree.
Updates `hugo.toml`, `CHANGELOG.md`, `README.md`, writes `specs/<date>-release-vX.Y.Z/release-notes.md`,
then commits, tags, and pushes. Changelog format is defined in `cliff.toml`.

### Conventional commits hook (local only, not version-controlled)

The hook is already installed at `.git/hooks/commit-msg`. On a fresh clone, re-install with:

```bash
cp scripts/release.sh /dev/null   # (hook is .git/hooks/commit-msg — reinstall manually)
# or simply:
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/sh
pattern="^(feat|fix|docs|chore|refactor|perf|test|style|ci|build)(\(.+\))?(!)?:.+"
msg=$(head -1 "$1")
if ! echo "$msg" | grep -qE "$pattern"; then
  echo "ERROR: Commit message must follow Conventional Commits format."
  echo "  Expected: <type>[optional scope][optional !]: <description>"
  echo "  Got: $msg"
  exit 1
fi
EOF
chmod +x .git/hooks/commit-msg
```

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
_sources/            # Raw HTML from Sober Spirits (not served)
specs/               # Timestamped planning docs
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

Push to `main` → Cloudflare Pages auto-builds with `HUGO_VERSION=0.159.1`. No CI/CD config needed. Domain: kanpai0.co (301 from kanpai0.com).
