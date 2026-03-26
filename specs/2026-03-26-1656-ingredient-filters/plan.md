# Plan: Ingredient Filters by Spirit Type

## Context
The homepage shows 24 mocktail recipe cards in a 2-column grid. Users need to filter by the type of zero-alcohol spirit used (Rhum, Whisky, Gin, Amaretto, Spritz). Filters must persist via localStorage so returning users see their last selection. The solution must be simple, in-place (no API/JSON fetch), and ideally leverage CSS `:has()` for the filtering logic itself — keeping JS to localStorage-only (~20 lines).

---

## Spirit Mapping (from ingredient analysis)

| Spirit | Recipes |
|--------|---------|
| **rhum** | caipirinha, cuba-libre, daiquiri, dark-stormy, jamaican-mule, mai-tai, mojito, pina-colada, planteur |
| **whisky** | bourbon-mule, chenonceau, godfather*, whisky-apple, whisky-ginger-ale, whisky-sour |
| **gin** | clover-club, gin-basil-smash, gin-tonic, london-mule, versailles |
| **amaretto** | amaretto-sour, godfather*, italian-mule, madeleine |
| **spritz** | orange-spritz |

*godfather uses both Whisky + Amaretto

---

## Approach: CSS `:has()` + minimal localStorage JS

**Filtering mechanics (pure CSS):**
```css
/* Hide all when a filter is checked */
.home:has(.filter-cb:checked) .recipe-card { display: none; }
/* Show matching cards per active filter */
.home:has(#f-rhum:checked) .recipe-card[data-spirits~="rhum"] { display: flex; }
/* etc. */
```

The `[data-spirits~="word"]` CSS selector matches space-separated values — perfect for multi-spirit recipes like godfather.

**localStorage JS (~20 lines, inline `<script>`):**
- On load: restore checked state from `localStorage.getItem('spirit-filters')`
- On change: save array of checked values to localStorage

---

## Files Modified

### 1. `content/recettes/*.md` (24 files)
Added `spirits` array to each recipe's YAML frontmatter:
```yaml
spirits:
  - rhum
```
For godfather:
```yaml
spirits:
  - whisky
  - amaretto
```

### 2. `layouts/index.html`
- Added hidden checkboxes: `<input type="checkbox" id="f-rhum" class="filter-cb" value="rhum">`
- Added filter nav with pill labels: `<nav class="filters"><label for="f-rhum" class="filter-pill">Rhum</label>...</nav>`
- Added `data-spirits` attribute to each recipe card: `data-spirits="{{ delimit .Params.spirits " " }}"`
- Added inline `<script>` for localStorage restore + save

Filter order (by recipe count): **Rhum · Whisky · Gin · Amaretto · Spritz**

### 3. `static/css/main.css`
- Hidden checkboxes: `.filter-cb { display: none; }`
- Fixed filter bar below fixed header:
  ```css
  .filters {
    position: fixed;
    top: var(--header-h);
    left: 0; right: 0;
    z-index: 50;
    display: flex; gap: 8px; overflow-x: auto;
    padding: 12px 16px;
  }
  ```
- Added `--filters-h: 58px` CSS variable
- Pill styles: border-radius 20px, inactive = `--border`, active = `--sage` background + white text via `:has()`
- Grid top padding: `calc(var(--header-h) + var(--filters-h) + 8px)`
- CSS `:has()` hide/show rules

---

## Verification
1. `hugo server` — check filter pills render below header on homepage
2. Click a spirit filter — only matching cards should remain visible
3. Click godfather recipe via Whisky and Amaretto filters both
4. Refresh page — previously selected filters should be restored (localStorage)
5. Click same active filter again — it toggles off, all cards return
6. Multiple filters active simultaneously = union of results (OR logic)
