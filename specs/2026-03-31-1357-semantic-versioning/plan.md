# Semantic Versioning — Kanpai Ø

**Date:** 2026-03-31
**Version:** 1.0.0

## Strategy

Three-layer approach: git tag (source of truth) + Hugo param (single update point) + HTML meta tag (runtime visibility).

No `package.json` — this is a pure Hugo project with no Node.js pipeline.

## Changes

### 1. `hugo.toml` — add `[params] version`
```toml
[params]
  version = "1.0.0"
```
Single place to bump the version. Referenced in templates via `{{ .Site.Params.version }}`.

### 2. `layouts/index.html` — add meta tag in `<head>`
```html
<meta name="version" content="{{ .Site.Params.version }}">
```

### 3. `layouts/recettes/single.html` — same meta tag
```html
<meta name="version" content="{{ .Site.Params.version }}">
```

### 4. Git tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Update process (future releases)

1. Bump `version` in `hugo.toml`
2. Commit: `git commit -m "chore: bump version to X.Y.Z"`
3. Tag: `git tag vX.Y.Z && git push origin vX.Y.Z`
