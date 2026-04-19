---
date: 2026-04-19
title: PWA — Decision record
status: rejected
---

## Decision

Not implementing PWA support for kanpai0.co.

## Context

Evaluated whether adding a Progressive Web App manifest + service worker would benefit users of this recipe site.

## Options considered

- **Full PWA** (manifest + service worker + offline cache)
- **Manifest only** (splash screen, theme color, standalone mode)
- **Status quo** (plain static site)

## Decision rationale

The primary PWA gain over a plain Hugo static site would be **offline caching** — letting users access recipes without signal (e.g. in a kitchen with spotty wifi). However:

- iOS "Add to Home Screen" without a PWA manifest already gives standalone mode and a home screen icon.
- The additional iOS PWA gains (splash screen, theme color) are cosmetic.
- Apple's PWA support remains limited: background sync and push notifications require iOS 16.4+ and user permission grants that are disproportionate for a recipe site.
- Adding a service worker introduces cache invalidation complexity for a site that is already fast as a static build deployed on Cloudflare Pages.

The offline use case is not strong enough to justify the added complexity at this stage.

## Consequences

No service worker, no web app manifest. Revisit if user research confirms offline kitchen use is a real pain point.