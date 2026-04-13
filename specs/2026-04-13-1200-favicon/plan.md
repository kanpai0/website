# Favicon & Apple Touch Icon

**Date**: 2026-04-13
**Status**: Implemented

---

## What was built

Added browser favicon and iOS home screen icon support:

- `static/favicon.svg` — SVG icon served at `/favicon.svg`
- `static/apple-touch-icon.png` — 180×180 PNG served at `/apple-touch-icon.png`
- `<link>` tags + `theme-color` meta added to all 3 Hugo templates

---

## Changes

Three templates each received the same 3-line block, inserted after `<meta name="viewport">`:

```html
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<meta name="theme-color" content="#F7F4EE">
```

Files modified:
- `layouts/index.html`
- `layouts/_default/single.html`
- `layouts/_default/design-system.html`

No shared `baseof.html` exists — each template has its own `<head>`, so the block was added to all three independently.

---

## Decisions

**No `favicon.ico`** — dropped entirely. An SVG favicon covers all modern browsers; ICO is legacy overhead with no real benefit for this stack.

**No PWA manifest** — deferred to a next step. The `theme-color` meta is already in place so it can be replaced (or kept alongside) a `<link rel="manifest">` when the manifest is added.

**`theme-color: #F7F4EE`** — matches `--bg`, the cream background. This makes the Android/iOS browser toolbar blend with the page rather than showing default grey chrome.

**Asset source** — user-provided. The SVG and PNG were not generated from design tokens; they are original brand assets dropped into `static/`.

**180×180 for apple-touch-icon** — the single size that covers all current iOS devices (the OS downscales as needed). No 152×152 or 120×120 variants were added — unnecessary for a single-target deployment.
