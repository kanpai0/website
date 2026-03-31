# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
hugo serve          # Local dev server with hot reload
hugo build          # Generate static site to public/
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

Push to `main` → Cloudflare Pages auto-builds with `HUGO_VERSION=0.158.0`. No CI/CD config needed. Domain: kanpai0.co (301 from kanpai0.com).
