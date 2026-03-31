# ADR — Release Tooling: git-cliff + bash vs semantic-release

**Date**: 2026-03-31
**Status**: Decided — git-cliff + bash
**Context**: Choosing a release automation strategy for the Kanpai Ø Hugo site.

---

## Decision

Use **git-cliff + bash** (`scripts/release.sh` + `cliff.toml`).

---

## Options considered

| | **git-cliff + bash** | **semantic-release** |
|--|--|--|
| **Files** | `scripts/release.sh` (157 lines) + `cliff.toml` | `scripts/release.sh` (24 lines) + `.releaserc.json` + `scripts/prepare-release.sh` + `package.json` + `package-lock.json` (6122 lines) |
| **Dependencies** | `brew install git-cliff` — single binary, no lockfile | 329 npm packages (~6 MB `node_modules`) |
| **Version bump** | `git cliff --bumped-version` | Automatic via `@semantic-release/commit-analyzer` |
| **Changelog** | `git cliff --tag vX.Y.Z --unreleased --prepend CHANGELOG.md` | `@semantic-release/changelog` — standard Keep a Changelog format |
| **Interactive** | Yes — shows preview, asks `[y/N]` before writing anything | No — fires immediately, no confirmation prompt |
| **`--bump` override** | Yes — `bash scripts/release.sh --bump minor` | Not supported — commit types drive everything |
| **Template control** | `cliff.toml` — Tera template, full control over grouping/format | Limited — needs `@semantic-release/release-notes-generator` config |
| **Dry-run** | Full preview, nothing written | `--dry-run` flag, but still hits GitHub API |

---

## Rationale

git-cliff wins for this project:

- **No `node_modules` in a Hugo repo.** This site has zero Node.js by design. Adding a 329-package lockfile for a release script contradicts the stack's philosophy.
- **Interactive confirmation before tagging.** semantic-release fires immediately with no prompt. The bash script shows a grouped changelog preview and asks `[y/N]` — safer for a solo workflow.
- **`--bump` override.** Useful when commit history doesn't reflect the intended bump (e.g. a batch of `docs:` commits that still deserve a patch release).
- **Full template control.** `cliff.toml` uses a Tera template — group names, ordering, and skipping `chore:` commits from the changelog are all configurable without plugin overhead.

semantic-release shines in CI pipelines, GitHub Releases automation, and multi-package monorepos. Not the right fit here.

---

## Implementation

- `scripts/release.sh` — orchestrates the full release flow
- `cliff.toml` — commit grouping template and changelog format
- `Makefile` — `make release` / `make release-dry` / `make doctor`
- `.git/hooks/commit-msg` — conventional commits validator (local only, not version-controlled)

The `feat/semantic-release` branch was created for comparison and then discarded.
