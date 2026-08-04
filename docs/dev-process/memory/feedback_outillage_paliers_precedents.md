---
name: feedback-outillage-paliers-precedents
description: Précédents concrets Kanpai pour arbitrer un palier d'outillage (1/2/3)
type: feedback
---

# Précédents d'arbitrage par palier d'outillage

**Règle** : à chaque introduction d'outil, situer le choix sur les 3 paliers (natif
POSIX → binaire autonome → écosystème de paquets) et citer un précédent si possible.

**Why** : la doctrine (`docs/adr/README.md`, PROCESS.md §Paliers) exige une
justification explicite au palier 3 — ces précédents montrent comment elle a déjà
été rendue.

**How to apply** — précédents tracés :

- **`git-cliff` (palier 2) vs `semantic-release` (palier 3, 329 paquets)** — testé
  sur une branche `feat/semantic-release` puis abandonné, 2026-03-31. `docs/adr/ADR-003`.
- **`yq` (palier 2) vs parseur YAML maison (295 lignes)** — révisé 2026-08-03 sur
  push-back Vincent. `docs/dev-process/ikima-methods.md` (item 10).
- **`playwright-bdd` = palier 3 assumé et borné** — 12 dépendances vs 414 pour
  `@cucumber/cucumber` direct, 2026-04-02. `docs/adr/ADR-005`.
- **Biome écarté** — faute d'irritant mesuré. `docs/dev-process/ikima-methods.md` (item 40).
