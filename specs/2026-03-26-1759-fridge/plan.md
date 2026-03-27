# Fridge Feature — Plan

**Date:** 2026-03-26
**Status:** ✅ Implemented

---

## Goal

Add a hidden "fridge" panel where the user can deselect ingredients they don't have at home. Recipes requiring unavailable ingredients are hidden. State is persisted in `localStorage`, like the spirit filters.

---

## Design Decisions

- **Presentation**: tiles with `✓` above the ingredient name when available (distinct from spirit pills)
- **Default state**: all 21 ingredients checked on first visit
- **Filtering logic**: AND logic — a recipe is hidden if ANY required ingredient is missing
- **Spirit + fridge interaction**: spirit filter (CSS `:has()`) and fridge filter (JS `.fridge-hidden` class) work independently and compose correctly
- **Panel**: bottom sheet, triggered by "Mon frigo" button in header top-right
- **Dot indicator**: small sage-green dot on the button when any ingredient is unchecked
- **localStorage key**: `fridge` (JSON array of available ingredient ids)

---

## Ingredient Taxonomy (21 items)

| Group | Id | Label |
|---|---|---|
| Frais | `menthe` | Menthe |
| Frais | `citron-vert` | Citron vert |
| Frais | `citron-jaune` | Citron |
| Frais | `basilic` | Basilic |
| Jus & fruits | `ananas` | Ananas |
| Jus & fruits | `framboise` | Framboise |
| Jus & fruits | `mangue` | Mangue |
| Jus & fruits | `passion` | Passion |
| Jus & fruits | `pomme` | Pomme |
| Sirops | `agave` | Agave |
| Sirops | `orgeat` | Orgeat |
| Sirops | `hibiscus` | Hibiscus |
| Sirops | `vanille` | Vanille |
| Sodas | `cola` | Cola |
| Sodas | `gingembre` | Gingembre |
| Sodas | `tonic` | Tonic |
| Sodas | `petillante` | Pétillante |
| Autres | `miel` | Miel |
| Autres | `oeuf` | Blanc d'œuf |
| Autres | `creme-coco` | Crème coco |
| Autres | `cannelle` | Cannelle |

---

## Recipe → Fridge Mapping

| Recipe | Required fridge ingredients |
|---|---|
| Mojito | citron-vert, agave, menthe, petillante |
| Daiquiri | citron-vert, agave |
| Caïpirinha | citron-vert, agave |
| Cuba Libre | citron-vert, cola |
| Pina Colada | ananas, creme-coco |
| Dark & Stormy | citron-vert, agave, gingembre |
| Jamaican Mule | citron-vert, agave, gingembre, menthe |
| Bourbon Mule | citron-vert, agave, gingembre, menthe |
| London Mule | citron-vert, agave, gingembre, menthe |
| Italian Mule | citron-vert, agave, gingembre, menthe |
| Gin Tonic | tonic |
| Clover Club | citron-vert, agave, framboise, oeuf |
| Gin Basil Smash | basilic, agave, citron-vert |
| Versailles | hibiscus, citron-vert, framboise, oeuf |
| Chenonceau | pomme, vanille, citron-jaune, cannelle |
| Whisky Sour | agave, citron-jaune, oeuf |
| Whisky Ginger Ale | gingembre, citron-vert |
| Whisky Apple | pomme, miel, citron-jaune, cannelle |
| Amaretto Sour | agave, citron-jaune, oeuf |
| Parrain (Godfather) | *(aucun — spirits + glaçons seulement)* |
| Madeleine | ananas, citron-vert, agave |
| Orange Spritz | tonic |
| Maï Taï | citron-vert, orgeat |
| Planteur | agave, citron-vert, mangue, passion, ananas, cannelle, vanille |

> Optional garnishes (facultatif) are excluded from fridge requirements.

---

## Files Changed

- `content/recettes/*.md` — added `fridge: [...]` frontmatter field to all 24 recipes
- `layouts/index.html` — fridge panel HTML, `data-fridge` on recipe cards, fridge JS
- `static/css/main.css` — fridge panel + tile styles

---

## Follow-up

- `specs/2026-03-27-fridge-icons/plan.md` — replaced `✓` with inline SVG icons per ingredient

---

## Possible Next Steps

- Add a "Tout cocher / Tout décocher" shortcut in the fridge panel
- Show a count badge ("3 recettes possibles") when fridge filter is active
- Dim recipe cards instead of hiding them (softer UX option)
- Add a recipe page indicator if an ingredient is missing from the fridge
