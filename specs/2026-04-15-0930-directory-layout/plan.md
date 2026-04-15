# Directory Layout Reorganization

## What was built

Reorganized the project root to reduce clutter and better separate concerns. Three concrete changes:

### 1. `docs/` — new directory for reference documentation

Moved 5 markdown files out of root:

| File | Old location | New location |
|------|-------------|--------------|
| `QUALITY_CHECKLIST.md` | root | `docs/` |
| `methodes-outils-techniques.md` | root | `docs/` |
| `retrospective-manques.md` | root | `docs/` |
| `SOCIAL.md` | root | `docs/marketing/` |
| `linkedin-posts.md` | root | `docs/marketing/` |

Kept at root: `README.md` (GitHub visibility), `CLAUDE.md` (Claude Code requirement), `CHANGELOG.md` (git-cliff convention).

### 2. `design/` — new directory for design artifacts

Extracted from `specs/`, which was mixing two unrelated concerns:

| File | Old location | New location |
|------|-------------|--------------|
| `kanpai0.pen` | `specs/` | `design/` |
| `specs/images/*.png` | `specs/images/` | `design/mockups/` |

`specs/` now holds only timestamped ADR folders. Its purpose is unambiguous.

### 3. `sources/` — renamed from `_sources/`

The leading underscore was a Python-module convention that signalled nothing useful here. `sources/` is explicit and has no misleading connotations.

Updated `scripts/download-recipe-images.sh` (2 path constants).

## Why

Root had accumulated 8 markdown files alongside config files, making it hard to distinguish project documentation from tooling. The three problems were independent and each had a clear fix:

- Documentation files with no GitHub/tooling reason to be at root → `docs/`
- Design infrastructure (`.pen` file, mockups) mixed into ephemeral ADR log → `design/`
- Opaque directory name with misleading underscore convention → `sources/`

## Decisions

**`docs/` vs. no move**: Only moved files with no tooling dependency on their root location. `CHANGELOG.md` stays at root because git-cliff writes it there; moving it would require a `cliff.toml` override for marginal gain.

**`design/` as top-level vs. inside `specs/`**: The Pencil file is living infrastructure, not a timestamped decision record. It deserves a stable home independent of the ADR log.

**`sources/` vs. `data/raw/`**: Hugo reserves `data/` for template data files. Using `data/raw/` risked a namespace collision if Hugo data features are ever adopted. `sources/` is equally clear with no collision risk.

**`scripts/` not split**: Only 8 files; splitting hooks from utilities would create a subdirectory with one file. Not worth the churn.

## Files updated

- `CLAUDE.md` — updated `QUALITY_CHECKLIST.md` path reference and architecture directory listing
- `scripts/download-recipe-images.sh` — updated `_sources/` → `sources/` in 2 path constants
