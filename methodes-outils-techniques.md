# Méthodes, outils et techniques — Kanpai Ø

Inventaire exhaustif et commenté de tout ce qui a été mis en œuvre sur ce projet.  
Dernière mise à jour : 2026-04-14 (v1.11.0)

---

## I. Méthodes de travail & philosophie produit

### Approche de delivery

- **Deploy-first** — premier commit : une page blanche en production. L'infrastructure (Hugo, Cloudflare Pages, domaine, SSL, 301) est validée *avant* d'écrire une seule feature. Le risque d'architecture est éliminé au jour 1.
- **Petits incréments vérifiables** — chaque session produit une spec datée, un commit sémantique, et une version taguée. Rien de "en cours" dure plus d'une session.
- **Itération sur usage réel** — je suis le premier utilisateur. Le déplacement des spiritueux dans le frigo et la mise en avant des saveurs sont issus d'une observation directe de mes invités, pas d'une hypothèse.
- **Scope minimal assumé** — chaque spec note explicitement ce qui a été retiré volontairement (difficulté, temps de préparation, bouton commander, etc.). Le scope est arbitré, pas subi.
- **Adaptation au fil de la découverte** — PicoCSS, Pagefind, semantic-release : explorés sérieusement, puis abandonnés quand inutiles. Le plan est un outil, pas une contrainte.

### Documentation décisionnelle (ADR)

- **18 specs datées** en 3 semaines dans `specs/<date>-<sujet>/plan.md`
- Chaque spec contient : l'objectif, les alternatives considérées, les décisions et leur rationale, les fichiers modifiés, les edge cases rencontrés, les follow-ups
- **Tableau de comparaison systématique** avant tout choix d'outil majeur
- **Branche d'expérimentation** — `feat/semantic-release` créée et abandonnée *après test réel*, pas sur intuition
- **Renoncements documentés** — ce qui n'a *pas* été fait (et pourquoi) est aussi consigné que ce qui a été fait

### Qualité & validation humaine de l'IA

- **Review systématique des outputs IA** — 24 images générées par `gpt-image-1` vérifiées une à une ; 8 cas corrigés manuellement (image sélectionnée automatiquement ne correspondait pas au bon plan du verre)
- **`--dry-run` obligatoire avant tout script destructif** — génération d'images, release, migration de frontmatter : toujours prévisualisé avant exécution
- **Scraping IA-assisté, parsing humain** — l'extraction HTML est vérifiée et les edge cases sont documentés (deux `<span>` concaténés, recette pour 6 personnes, virgule finale)
- **Validation output Python** — les scripts de migration frontmatter sont idempotents et jouent sur un subset avant d'être appliqués aux 24 fichiers
- **CLAUDE.md comme contrat de session** — le contexte fourni à l'IA à chaque session (architecture, invariants, design tokens, commandes) garantit la cohérence des outputs sans redécouverte

### IA comme miroir de compétences implicites

Un effet inattendu et précieux du travail assisté par IA : l'analyse rétrospective du projet a produit des noms pour des pratiques appliquées intuitivement.

- "checkbox state machine" — pattern utilisé depuis le début, nommé en session d'analyse
- "ETL pipeline" — le scraping → YAML → Hugo était évident fonctionnellement, pas conceptuellement formalisé
- "body class theming" — décision CSS qui a un nom dans la littérature
- "ADR pattern" — format de spec utilisé sans connaître l'acronyme "Architecture Decision Record"

**Ce que ça révèle :** Connaître une technique et pouvoir la nommer sont deux compétences distinctes. L'IA agit ici comme un dictionnaire de vocabulaire professionnel appliqué au code existant — utile pour la communication avec une équipe ou un recruteur.

### Optimisation des tokens — rtk

- **rtk** (Rust Token Killer) — proxy CLI qui filtre les outputs verbeux avant qu'ils ne consomment du contexte Claude
- Toutes les commandes git, hugo, bash passent automatiquement par rtk via un hook Claude Code
- Analytics `rtk gain` pour mesurer les économies effectives
- Économies estimées : 60–90% sur les opérations de dev courantes (git log, build output, test output)

### Gestion de la qualité

- **Quality checklist** — `QUALITY_CHECKLIST.md` : 8 sections (A–H), matrice "type de changement → sections concernées", distinction auto/manuel
- **Pre-commit hook** — `hugo build` + vérification du schéma fridge à chaque commit
- **Preflight avant release** — build + tests + schema, déclenché automatiquement par `release.sh`
- **Conventional commits enforced** — hook local `commit-msg` avec regex, refus immédiat si le format est invalide
- **Schema invariant documenté** — `fridge[]` doit correspondre à `id="fi-<slug>"` dans `fridge-icons.html` ; violation détectée avant tout push

---

## II. Frontend — HTML5 sémantique

Chaque élément est choisi pour sa sémantique, pas seulement pour sa structure visuelle.

- `<header>` — en-tête de page avec `position: fixed`
- `<main>` — zone de contenu principal, `role="main"` + `aria-labelledby="recipe-title"`
- `<nav>` — barre de filtres saveurs avec `aria-label="Filtrer par saveur"`
- `<figure>` — photo recette (élément illustratif autonome)
- `<section>` — chaque bloc recette (ingrédients, ustensiles, préparation, conseils) avec `aria-labelledby`
- `<ol>` — étapes de préparation (liste ordonnée, l'ordre importe)
- `<ul>` — liste d'ingrédients (liste non ordonnée)
- `<footer>` — pied de page avec attribution légale conditionnelle
- `<h1>`, `<h2>` — hiérarchie de titres respectée : un seul `h1` par page, `h2` pour chaque section
- `<label>` + `<input type="checkbox">` — utilisés comme machine à états CSS (pattern détaillé en section III)
- `<noscript>` — fallback pour le chargement des polices si JS désactivé
- `lang="fr"` sur `<html>` — langue déclarée pour les lecteurs d'écran
- `<meta name="viewport" content="width=device-width, initial-scale=1.0">` — viewport mobile déclaré

---

## III. Frontend — CSS : techniques JS-free

Le principe central : **utiliser CSS comme machine à états** via des checkboxes cachées et `:has()`. Zéro JavaScript pour les interactions visuelles.

### Pattern checkbox-as-state-machine
```
<input type="checkbox" id="fridge-open" class="filter-cb">  ← état caché dans le DOM
<label for="fridge-open">Mon frigo</label>                  ← déclencheur cliquable
.home:has(#fridge-open:checked) .fridge-panel { ... }       ← CSS réagit à l'état
```
Ce pattern est utilisé 3 fois : panneau frigo (ouverture/fermeture), pills saveurs, items frigo.

### Techniques CSS sans JS

| Technique | Usage concret |
|---|---|
| **`:has()`** | Cascade inversée : un parent réagit à l'état d'un enfant. 4 usages distincts. |
| **Checkbox caché + `<label>`** | Toggle du panneau frigo sans `addEventListener`. L'état vit dans le DOM. |
| **`transform: translateY(100%)` → `translateY(0)`** | Bottom sheet animée, déclenchée uniquement par `:has(#fridge-open:checked)` — aucun JS |
| **`pointer-events: none/auto`** | Overlay du frigo activé/désactivé par CSS selon l'état du checkbox |
| **`opacity: 0/1` sur `.fridge-btn__dot`** | Indicateur "ingrédient manquant" : `.home:has(.fridge-cb:not(:checked)) .fridge-btn__dot { opacity: 1 }` |
| **`.fridge-item:has(.fridge-cb:checked)`** | Bordure sage sur l'item coché, stroke sage sur l'icône, texte encré — 3 propriétés en cascade depuis un seul `:has()` |
| **`.flavor-pill:has(.flavor-cb:checked)`** | Pill active (fond sage, texte blanc) |
| **`.flavor-pill:not(:has(...)):hover`** | État hover uniquement sur pills non actives |
| **`display: none` sur les checkboxes** | `.filter-cb`, `.flavor-cb`, `.fridge-cb` — invisibles, accessibles via `<label>` |
| **`transition` sur `transform`** | Animation du bottom sheet : `cubic-bezier(0.32, 0.72, 0, 1)` — easing spring-like |
| **`position: sticky`** | Header du panneau frigo reste visible pendant le scroll de la liste d'ingrédients |
| **`:focus-visible`** | Focus ring visible uniquement au clavier, jamais à la souris |

### CSS Grid moderne

- **`repeat(auto-fill, minmax(clamp(180px, 20% - 6px, 275px), 1fr))`** — grille responsive sans aucun breakpoint : 2 colonnes sur mobile (~375px), 4 sur tablette, 5+ sur desktop
- **`grid-template-columns: 1fr auto`** — layout 2 colonnes ingrédient/quantité sans `float`, sans `flex` séparé
- Grille frigo : `repeat(4, 1fr)` — 4 colonnes fixes pour les items frigo

### `clamp()` pour la typographie fluide

- Titre recette : `clamp(32px, 8vw, 48px)` — s'adapte du mobile au desktop sans media query
- Titre carte : `clamp(15px, 3.5vw, 20px)`
- Titre page prose : `clamp(1.5rem, 4vw, 2rem)`

### Propriétés logiques CSS

- `padding-inline`, `margin-inline` — au lieu de `padding-left/right`
- `padding-block` — au lieu de `padding-top/bottom`
- `inset: 0 0 auto 0` — au lieu de `top/right/bottom/left`
- `margin-inline: auto` pour le centrage horizontal

### Theming par body class + CSS custom property override (JS-free)

```css
/* `:root` définit le défaut */
:root { --accent: #C9865B; }

/* La class sur `<body>` override la variable */
body.vert   { --accent: var(--color-vert); }
body.rose   { --accent: var(--color-rose); }

/* Les composants consomment sans rien savoir du thème */
.recipe__subtitle { color: var(--accent); }
.recipe__step-num { color: var(--accent); }
```

Le frontmatter (`color: "vert"`) devient une classe sémantique sur `<body>` via Hugo (`{{ with .Params.color }} {{ . }}{{ end }}`). Zéro inline style, zéro JS — le theming par recette est entièrement déclaratif. Les classes sont inspectables en devtools, le mapping vit dans CSS.

**Décision documentée :** 24 hex uniques (extraits photo par photo) abandonnés en faveur de 4 catégories sémantiques. Plus cohérent visuellement, maintenable sur la durée.  
**Renommage de token :** `--subtitle` → `--accent` — le nom reflète le rôle dans tout le système, plus seulement l'élément d'origine.

### Autres techniques CSS modernes

- **`backdrop-filter: blur(12px)`** — effet verre dépoli sur les flavor pills (+ `-webkit-backdrop-filter`)
- **`aspect-ratio: 1`** sur `.recipe-card__photo` — prévient le layout shift (CLS) avant chargement de l'image
- **`font-variant-numeric: tabular-nums`** — quantités d'ingrédients alignées verticalement
- **`scrollbar-width: none` + `::-webkit-scrollbar { display: none }`** — barre saveurs scrollable sans scrollbar visible
- **`-webkit-overflow-scrolling: touch`** — scroll inertiel natif iOS sur la barre de saveurs
- **`user-select: none`** — empêche la sélection de texte sur les éléments interactifs (pills, items frigo)
- **`white-space: nowrap`** — quantités jamais coupées
- **`currentColor`** sur les icônes SVG — thème hérité du parent via cascade
- **`linear-gradient(...) fixed`** — dégradé de fond sans requête supplémentaire
- **`max-width` + `margin-inline: auto`** — contrainte de largeur maximale (1440px) centrée
- **`calc((100vw - var(--max-w)) / 2)`** — `--inset` : goutière latérale calculée dynamiquement pour l'alignement précis
- **`-webkit-font-smoothing: antialiased`** — rendu de police lissé sur macOS/iOS

---

## IV. Frontend — Performance

### Images

- **WebP** pour toutes les images recettes (~100–150 KB optimisé)
- **PNG transparent** pour les renders 3D (fond transparent natif, sans post-traitement)
- **`fetchpriority="high"`** sur la première image de la grille et la photo hero recette — guide le navigateur sur les ressources critiques
- **`loading="lazy"`** à partir de la 6ème image de la grille — les premières sont au-dessus du fold
- **`<link rel="preload" as="image">`** sur la photo hero des pages recettes — chargée avant que le parser HTML n'atteigne `<img>`
- **`width` et `height` explicites** sur tous les `<img>` — le navigateur réserve l'espace avant le chargement (zéro CLS)
- **`object-fit: contain`** — image non rognée, ratio préservé

### Polices

- **`<link rel="preconnect">`** sur `fonts.googleapis.com` et `fonts.gstatic.com` — handshake DNS/TLS anticipé
- **Chargement asynchrone non-bloquant** :
  ```html
  <link rel="preload" as="style" onload="this.onload=null;this.rel='stylesheet'">
  ```
  Les polices ne bloquent pas le rendu initial. La page est lisible en `system-ui` pendant le chargement.
- **`<noscript>` fallback** — `<link rel="stylesheet">` standard si JS désactivé

### Build & delivery

- **Hugo build ~11ms** — zéro pipeline Node.js, binaire Go
- **Cloudflare CDN mondial** — assets servis depuis le PoP le plus proche
- **Pas de runtime JS framework** — zéro bundle, zéro hydration, zéro TTI artificiel
- **CSS en un seul fichier** (~350 lignes) — une seule requête, pas de cascade de `@import`

---

## V. Frontend — Accessibilité (ARIA)

L'accessibilité est construite dès la structure, pas ajoutée en fin de projet.

### Structure sémantique
- `lang="fr"` sur `<html>`
- Un seul `<h1>` par page, hiérarchie `h1 → h2` respectée
- Skip link (lien d'évitement vers `#main`) pour la navigation clavier

### Rôles et labels
- `role="main"` + `aria-labelledby="recipe-title"` sur `<main>`
- `role="dialog"` + `aria-modal="true"` + `aria-labelledby="fridge-panel-title"` sur le panneau frigo
- `role="button"` sur les `<label>` utilisés comme boutons
- `role="group"` + `aria-labelledby` sur les groupes d'ingrédients dans le frigo
- `aria-label` sur `<nav>`, `<main>`, les `<ul>` d'ingrédients et d'étapes
- `aria-labelledby` sur chaque `<section>` recette (ingrédients, ustensiles, préparation, conseils)
- `aria-controls="fridge-panel"` sur le bouton déclencheur
- `aria-label="Retour à la liste des recettes"` sur le bouton back

### États dynamiques
- `aria-expanded` sur le bouton frigo — synced par JS quand le panneau s'ouvre/ferme
- `aria-hidden` sur le panneau frigo — synced avec l'état du checkbox
- `aria-hidden` sur les cartes recettes — mis à jour dynamiquement par `applyFilters()` quand une carte est masquée
- `aria-hidden="true"` sur tous les SVG décoratifs
- `tabindex="-1"` sur le checkbox caché (exclu de la navigation clavier)

### Gestion du focus
- Quand le panneau frigo s'ouvre : focus déplacé sur le premier élément interactif du panneau
- Quand il se ferme : focus retourné sur le bouton déclencheur
- `:focus-visible` — anneau de focus uniquement en navigation clavier

### Audit automatisé
- **Lighthouse CI** — audit Performance/Accessibilité/SEO/Best Practices à chaque push sur `main`
- Seuils minimaux définis dans `budget.json`

---

## VI. Architecture Hugo & templates

### Héritage de templates (`baseof.html`)

Hugo `block` / `define` — un template de base unique, surchargé par chaque layout :

```
layouts/_default/baseof.html      ← head, fonts, meta communs
  ├── layouts/index.html           ← {{ define "body" }}
  ├── layouts/recettes/single.html
  └── layouts/_default/design-system.html
```

- Zéro duplication du `<head>` entre les layouts (avant : copie identique dans 3 fichiers)
- `{{ block "head-meta" . }}{{ end }}` — slot surchargeable par page (preload image hero uniquement sur les recettes)
- `{{ block "fonts" . }}{{ end }}` — polices déclarées une seule fois dans la base
- DRY appliqué aux templates avec la même discipline qu'au code métier

### Principes de templating

- **Templates sans logique** — toute la logique de transformation (qty/name, title/text) est dans le frontmatter YAML, jamais dans les templates Go. Les templates itèrent, ils ne transforment pas.
- **Rendu conditionnel propre** — `{{ with .Params.glass }}`, `{{ if .Params.steps }}`, `{{ with .Params.tips }}` : une section n'est rendue que si la donnée existe. Zéro fallback vide dans le HTML.
- **Partials comme composants** — `glass-icon.html`, `fridge-icons.html`, `fridge-panel-body.html`, `footer.html` : chaque composant réutilisable est extrait
- **`{{ humanize }}`** — fonction Hugo pour transformer `mule-mug` → `Mule mug` sans JS
- **`delimit`** — transforme `fridge: ["rhum", "citron-vert"]` en `"rhum citron-vert"` pour l'attribut `data-fridge`
- **Indexation des images par slug** — `fetchpriority` conditionnel : `{{ if eq $i 0 }}high{{ else if ge $i 5 }}lazy{{ end }}`

### Frontmatter comme source de vérité

```yaml
# Avant : string opaque
ingredients:
  - "50 ml de Rhum Sober Spirits 0,0 %"

# Après : données structurées
ingredients:
  - name: "Rhum Sober Spirits 0,0 %"
    qty: "50 ml"
steps:
  - title: "Versez le jus dans le verre"
    text: "Ajoutez de la glace."
glass: "highball"
subtitle: "Sans alcool & rafraîchissant"
tips: "Servir très frais, verre givré."
```

Migration automatisée par Python sur 24 fichiers, regex adaptée aux deux patterns de quantité.

### Design system comme artefact de test

- Page `/design-system/` — liste exhaustive de tous les composants UI
- `data-ds="colors|typography|flavor-pills|..."` — attributs de ciblage pour les tests Playwright
- Sections statiques HTML pour les composants recettes (pas de dépendance à une recette réelle)
- Mise à jour des baselines visuelles déclenchée manuellement (`npm run test:update`) après un changement intentionnel

---

## VII. SVG custom & icônographie

### Partials d'icônes consolidés (v1.11.0)

- **`icon-social.html`** — Instagram, Pinterest, YouTube, Threads, Bluesky : toutes les icônes réseaux dans un seul partial
- **`icon-ui.html`** — icônes d'interface (back, close, etc.) extraites des templates où elles étaient inline
- Remplacement des SVG inline éparpillés dans footer et header par des appels `{{ partial "icon-social.html" "instagram" }}`
- Un seul endroit à modifier si un tracé change — maintenabilité garantie

### Actifs PWA (v1.8.0)

- **`favicon.svg`** — favicon vectoriel (zéro pixelisation à toute résolution, taille ~1 KB)
- **`apple-touch-icon.png`** — icône 180×180 pour "Ajouter à l'écran d'accueil" iOS
- **`<meta name="theme-color">`** — couleur de la barre de navigation mobile (chrome du navigateur)
- Fondations PWA posées sans Service Worker ni manifest.json pour l'instant — ajouts progressifs

### Liens sociaux dans le footer

- Composant `social-links` dans `footer.html` — Instagram, Pinterest, YouTube, Threads, Bluesky
- Documenté dans le design system avec baseline visuelle mise à jour
- Cohérence avec la stratégie de présence réseaux (handles réservés dès le début)

### Autres techniques SVG

- **SVG sprite `<symbol>` + `<use>`** — 25+ icônes frigo définies une fois dans `fridge-icons.html` (inséré en `display:none` dans le DOM), référencées partout via `<use href="#fi-rhum">`
- **SVG inline pour les icônes de verre** — `glass-icon.html` : 8 types canoniques (`rocks`, `highball`, `collins`, `mule-mug`, `coupette`, `martini`, `margarita`, `vin`) + fallback générique
- **`currentColor`** — les icônes héritent la couleur du parent (`var(--muted)` par défaut, `var(--sage)` quand coché) via `:has()`
- **Icônes dessinées à la main** — chaque icône est un tracé SVG original (paths, lines, rects) représentant fidèlement l'objet (bouteille de rhum, mug avec anse, coupe de champagne…)
- **`aria-hidden="true"`** systématique — les icônes ne portent pas de sens seules, le label texte le porte

---

## VIII. Tests — 3 niveaux imbriqués

### 1. Tests visuels (anti-régression design system)

- **Playwright `toHaveScreenshot()`** — comparaison pixel par pixel contre baselines Linux commitées
- **6 tests par section** — `colors`, `typography`, `flavor-pills`, `fridge-items`, `buttons`, `recipe-card`, + sections recettes et footer
- **`maxDiffPixelRatio: 0.01`** — seuil de tolérance
- **Docker obligatoire en local** — `mcr.microsoft.com/playwright:v1.59.1-jammy` pour parité exacte avec CI Ubuntu (rendu de polices identique)
- **Baselines jamais régénérées en CI** — CI compare, ne génère pas. Regen = workflow local explicite (`npm run test:update`)

### 2. Tests fonctionnels BDD (comportement utilisateur)

- **Gherkin `.feature` files** — 3 fichiers : `saveurs.feature`, `frigo.feature`, `navigation.feature`
- **11 scénarios** couvrant : filtre par défaut, logique AND, deselect/restore, ouverture/fermeture panneau, combinaison frigo+saveurs, navigation homepage→recette→retour
- **`playwright-bdd`** comme bridge — génère des specs Playwright depuis Gherkin, Playwright reste le runner (pas d'incompatibilité avec les fixtures)
- **`Background`** — reset `localStorage` + reload entre chaque scénario pour l'état déterministe
- **`page.evaluate`** pour les checkboxes `display:none` — `.checked = true` + `dispatchEvent(new Event('change', {bubbles:true}))` car Playwright refuse `force:true` sur des éléments cachés
- **Step disambiguation** — `Given I am on...` vs `Then I should be on...` pour éviter les conflits de steps dans playwright-bdd

### 3. Mobile-first dans les tests

- **`bdd-mobile` (Pixel 5, 393×851) est le projet primaire** — les scénarios BDD tournent d'abord sur mobile
- **`bdd-desktop` en smoke check** — mêmes scénarios, viewport Desktop Chrome, sans feature file séparée
- **Tests visuels à 1280×800** — design system testé en viewport "tablette large"

### Structure CI

```
push to main
├── visual-regression (ubuntu, Docker Playwright)   ← bloque le deploy si échec
├── lighthouse (post-deploy, live site)              ← audit perf/a11y
└── deploy (conditionné à visual-regression + lighthouse)
    └── hugo build + wrangler pages deploy
```

- **Jobs parallèles** — `visual-regression` et `lighthouse` tournent en parallèle
- **Artifacts de failure** — diffs Playwright uploadés 7 jours si le job échoue
- **`visual-regression` sur PR et push** — `lighthouse` uniquement sur push (audite le site live post-deploy)

---

## IX. Outillage release & versioning

- **Semantic Versioning (SemVer)** — version source dans `hugo.toml [params]`, exposée via `<meta name="version">` dans chaque page HTML
- **Conventional commits** — `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `ci:`, `refactor:` ; commit-msg hook local
- **git-cliff** — génération du CHANGELOG depuis les commits ; config Tera dans `cliff.toml` (groupement, format, exclusion des `chore:`)
- **Release script interactif** — preview groupé du CHANGELOG, confirmation `[y/N]` avant écriture, `--bump` override, `--dry-run` complet
- **Backlog promotion automatique** — à la release, les items `[ ]` cochés sont déplacés dans `## Réalisées ✅` dans le README (réécriture en un pass pour préserver l'ordre)
- **Makefile** — interface unifiée : `make serve`, `make build`, `make release`, `make release-dry`, `make doctor`, `make test`, `make preflight`
- **bash 3.2-compatible** — `mapfile` (bash 4+) remplacé par `while IFS= read -r line` pour fonctionner sur macOS sans Homebrew bash

---

## X. Scripts d'automatisation

| Script | Langage | Rôle | Caractéristique notable |
|---|---|---|---|
| `scrape-sober-spirits.py` | Python stdlib | Scraping des 24 pages HTML de soberspirits.com | Aucune dépendance (pas de BeautifulSoup) ; pause 0.5s entre requêtes |
| `download-recipe-images.sh` | bash + awk + curl | Extraction des images CDN depuis les HTML sources | Algo de sélection : tronque au "Comment faire", prend la dernière image CDN |
| `generate-recipe-images.py` | Python + openai | Génération des renders 3D transparents via `gpt-image-1` | `--dry-run`, `--slug`, idempotent, rate limit 13s, fallback `dall-e-3` |
| `extract-source-fields.py` | Python + regex | Extraction `subtitle`, `glass`, `steps`, `tips` depuis HTML sources | Mapping de 8 types de verres canoniques |
| `migrate-frontmatter.py` | Python + regex | Restructuration ingredients/steps en objets YAML | `--write` explicite, regex `\n?` pour le dernier item sans trailing newline |
| `release.sh` | bash | Release complète (bump, changelog, tag) | Preview interactif, bash 3.2-compat, pas de push auto |
| `pre-commit.sh` | bash | Build + schema fridge avant commit | Bloque le commit si `fridge[]` contient un slug sans icône |
| `preflight.sh` | bash | Validation complète avant release | Chaîne build → tests → schema |

---

## XI. Génération d'images IA — workflow complet

- **Modèle** : `gpt-image-1` (OpenAI) — seul modèle supportant `background: "transparent"` natif (PNG avec canal alpha sans post-traitement)
- **Prompt engineering itératif** — 3 générations de template avant d'obtenir le résultat attendu. Écartés : "Professional photography" (déclenche accessoires de studio, sol, viseur), descriptions génériques. Retenu : description d'objet isolé, termes techniques 3D ("soft diffuse lighting", "slightly above eye level")
- **Paramètres finaux** : `size=1024x1024`, `quality=medium`, `background=transparent`, `n=1`
- **Coût** : ~0.04$/image × 24 = ~0.96$ one-time
- **Alternatives testées et écartées** :
  - `rembg` + SDXL local (Apple Silicon) : le fond transparent du verre est supprimé avec le fond — image résultante vide
  - `dall-e-3` + suppression numpy du fond blanc : moins fiable sur les verres
- **Fallback automatique** vers `dall-e-3` si `gpt-image-1` échoue
- **Validation humaine** : 24 images vérifiées visuellement (fond en damier = transparent ✓), 8 cas corrigés manuellement

### Création de l'icône de l'application — cas difficile

L'objectif : une icône représentant un cocktail sans alcool. Visuellement, deux concepts contradictoires. Parcours complet d'outils testés :

| Outil | Résultat | Verdict |
|---|---|---|
| method.ac (éditeur SVG) | Contrôle total mais création manuelle | Trop long pour une icône complexe |
| lovable.dev | Génération IA générique | Trop générique, peu adaptatble |
| toolkit.artlist.io | Assets premium prêts à l'emploi | Pas d'icône cocktail 0% dans le catalogue |
| recraft.ai | Rendu correct | Pas assez de contrôle sur les détails |
| Gemini | **Meilleurs résultats** | Bonne compréhension des contraintes visuelles |
| Claude + Pencil | En cours d'exploration | Workflow intégré mais résultat partiel |

**Blocage identifié :** Le problème n'était pas l'outil — c'était l'absence de vocabulaire artistique précis pour décrire l'esthétique souhaitée. "Cocktail sans alcool" ne suffit pas pour un prompt de génération d'image. Les termes techniques (style graphique, traitement de couleur, référence artistique, niveau de stylisation) manquaient. **Leçon symétrique au vocabulaire technique** : on peut avoir l'œil pour évaluer un résultat sans avoir le vocabulaire pour le commander précisément.

---

## XII. Design avec Pencil (outil de maquette)

- **Maquettes mobile en amont du code** — frame 390×844 (écran de référence iPhone) avant toute implémentation CSS
- **Références visuelles** documentées dans la spec : Seedlip (minimalisme premium), Pinterest (vue plongeante, verre "intégré")
- **Design tokens définis dans la charte** avant d'être implémentés en CSS custom properties : couleurs, typographies, espacements
- **Pencil intégré dans Claude Code via MCP** — outil de design accessible directement depuis le workflow de développement
- **Génération d'images de spec** — captures exportées dans `specs/images/` pour documenter les états visuels attendus

---

## XIII. Branding & stratégie de nom

- **Processus de naming documenté** — exploration de 5 langues (japonais, maori, sanskrit, scandinave, français créatif) avec critères explicites : prononçable universellement, libre sur le web, distinctif visuellement
- **`Kanpai Ø`** — `kanpai` (乾杯, "santé" en japonais) + `Ø` (zéro barré, absent d'alcool, esthétique scandinave)
- **Disponibilité web vérifiée** — handle `kanpai0` libre sur 6 plateformes (Instagram, Pinterest, YouTube, Threads, Bluesky, GitHub)
- **Stratégie de protection de marque** scalable — domaines + réseaux en v1, dépôt INPI si le projet se concrétise, système de Madrid si expansion internationale
- **Domaines défensifs** — `kanpai0.com` et `kanpai0.co` réservés, redirection 301 dynamique de `.com` vers `.co`
- **Choix d'extension documenté** — `.co` retenu : générique (pas géolocalisation Colombie), plus disponible que `.com`, reconnu par Google

---

## XIV. Légal & attribution

- **Attribution source** — `source_url` et `source_image` dans chaque frontmatter recette ; crédit "Recette Sober Spirits" dans le footer de chaque page recette via partial conditionnel
- **Mentions légales** — page dédiée, template prose Hugo
- **Page légale dans la checklist** — section G de `QUALITY_CHECKLIST.md` : vérification de licence avant tout contenu externe

---

## XV. Modélisation du contenu & taxonomie

Compétence souvent invisible mais structurante : concevoir les données avant de coder.

- **Refactoring de vocabulaire sur 32 fichiers** (v1.11.0) — les clés de saveurs migrent du français vers l'anglais (`petillant` → `sparkling`, `plat` → `still`, etc.) pour cohérence avec le code, les scripts Python, les tests BDD, et les attributs HTML. Migration atomique : 24 fichiers markdown + layouts + CSS + tests + scripts en un seul commit.
- **Renommage de token sémantique** — `--subtitle` → `--accent` : le nom du token reflète son rôle dans le système entier, pas l'élément qui l'a introduit. Décision documentée dans la spec.

- **Taxonomie des ingrédients** — 26 slugs répartis en 6 groupes (Spiritueux, Frais, Jus & fruits, Sirops, Sodas, Autres) ; vocabulaire contrôlé, identifiants stables
- **8 types de verres canoniques** — `rocks`, `highball`, `collins`, `mule-mug`, `coupette`, `martini`, `margarita`, `vin` ; mapping depuis le texte libre des sources HTML vers une ontologie propre
- **9 catégories de saveurs** — `petillant`, `plat`, `fruite`, `acidule`, `sucre`, `epice`, `amer`, `herbace`, `cremeux` ; vocabulaire orienté usage ("qu'est-ce que j'ai envie de boire ?") et non technique
- **Pipeline ETL complet** — HTML brut (Shopify/GemPages) → scraping stdlib Python → YAML structuré → templates Hugo → HTML rendu. Chaque étape est réversible et rejouable.
- **Reverse engineering sans documentation** — identification de la structure HTML Shopify (GemPages page builder) par inspection, sans API ni docs. Décision `curl` vs Playwright documentée et justifiée (le contenu est dans le HTML statique, pas rendu côté client).
- **Vocabulaire orienté "logique métier"** — les slugs `data-fridge` et `data-flavors` sont identiques dans le frontmatter YAML, les attributs HTML, et le JS. Zéro couche de traduction.

---

## XVI. Budget & temps — évaluation et maîtrise

### Budget total du projet

| Poste | Type | Montant |
|---|---|---|
| Abonnement Claude Pro | Mensuel (1 mois) | 20 $ |
| Génération d'images (OpenAI `gpt-image-1`) | One-shot | ~1 $ |
| Domaine `kanpai0.com` | Annuel | 26 $ |
| Domaine `kanpai0.co` | Annuel | 11 $ |
| Cloudflare Pages | Gratuit | 0 $ |
| GitHub | Gratuit | 0 $ |
| Hugo, Playwright, git-cliff, Google Fonts | Open source | 0 $ |
| **Total lancement** | | **~58 $** |
| **Récurrent annuel** | (hors Claude) | **~38 $/an** |

### Temps investi

| Métrique | Valeur |
|---|---|
| Durée calendaire | 3 semaines |
| Jours ouvrés | 15 |
| Sessions | 15 demi-journées |
| Heures effectives (3h/session, estimation haute) | ~45h |
| Heures effectives (2h/session, estimation basse) | ~30h |

### Ce que 45h ont produit

Un site en production avec : 24 recettes structurées, 24 images IA, deux systèmes de filtres (frigo + saveurs), design system, 3 niveaux de tests automatisés, CI/CD avec gate, release automation, accessibilité complète, mentions légales, versioning sémantique.

Estimation équivalente sans assistance IA pour un résultat identique : 150–300h (×3 à ×6).  
**Levier IA mesuré : 3x à 6x sur le temps.**

### Maîtrise du coût — compétences en jeu

**Infrastructure à coût zéro par choix délibéré, pas par contrainte**
- Cloudflare Pages (CDN mondial, SSL, déploiement Git) : 0$
- GitHub (code, CI/CD, artifacts) : 0$
- Google Fonts, tous les outils OSS : 0$
- La stack est composée uniquement de tier gratuits stables, sans dépendance à une offre freemium fragile

**Build vs buy — arbitrage systématique et documenté**
- `git-cliff + bash` (157 lignes) vs `semantic-release` (329 packages npm, `package-lock.json` de 6122 lignes) → OSS léger retenu
- `playwright-bdd` (12 dépendances directes) vs `@cucumber/cucumber` (414 dépendances transitives) → dépendance minimale retenue
- Scraping `stdlib Python` vs `BeautifulSoup` / Playwright → zéro dépendance pip retenue
- CSS custom vs PicoCSS → framework abandonné quand inutile
- Chaque décision "build" est une décision de coût : maintenance, surface d'attaque, poids du projet

**Contrôle du coût IA**
- `--dry-run` obligatoire avant tout script appelant une API payante
- Scripts idempotents : si le fichier existe, l'appel est sauté — pas de double facturation
- `--slug` pour régénérer une seule image sans relancer les 24
- Coût calculé *a priori* dans la spec : "~$0.04/image × 24 = ~$0.96 one-time"
- Alternatives testées avant d'engager le budget (rembg + SDXL local d'abord, abandonné sur résultat, pas sur coût)

**Maîtrise du temps**
- **Spec avant code** — le périmètre est défini par écrit avant de toucher un fichier. Zéro implémentation sans objectif clair.
- **Renoncements explicites** — PicoCSS, Pagefind, semantic-release : explorés, documentés, abandonnés. Le temps non dépensé est aussi une décision.
- **Sessions bornées** — une feature par demi-journée. Pas de session ouverte sans livraison.
- **Hooks comme filets de sécurité** — pre-commit bloque les erreurs de schema. Le temps de correction post-merge est proche de zéro.
- **`--dry-run` + preview interactif** — aucune opération coûteuse (release, migration, génération) sans prévisualisation. Zéro rollback nécessaire sur ce projet.
- **Idempotence** — tous les scripts peuvent être relancés sans risque. Pas de temps perdu à "défaire" une exécution partielle.

**Distinction coût one-shot vs récurrent**
- Génération d'images (~1$) : investissement unique, pas de re-génération sauf changement de charte
- Domaines (37$/an) : coût récurrent, renégociable si le projet n'évolue pas
- Claude (20$/mois) : mutualisé sur d'autres projets — le coût réel pour ce seul projet est fractionnel
- Infrastructure : 0$ récurrent par architecture

---

## Synthèse : ce qui distingue ce projet

| Dimension | Ce qui est fait | Niveau |
|---|---|---|
| Architecture | Deploy-first, spec avant code, ADR documentés, `baseof.html` DRY | Staff engineer |
| CSS | `:has()` + checkbox state machine, theming par body class, zéro JS pour les interactions visuelles | Avancé |
| HTML5 | Sémantique complète, hiérarchie de titres, éléments structurels, PWA assets | Solide |
| Performance | `fetchpriority`, `loading=lazy`, preload, WebP, zéro CLS, favicon SVG | Avancé |
| Accessibilité | ARIA complet, gestion du focus, live regions, Lighthouse CI | Avancé |
| Tests | 3 niveaux (visuel, BDD, smoke), Docker pour parité, mobile-first, baselines mises à jour | Avancé |
| CI/CD | Jobs parallèles, gate avant deploy, artifacts de failure | Professionnel |
| Release | SemVer, conventional commits, CHANGELOG auto, release script interactif | Professionnel |
| IA | Génération d'images, prompt engineering, validation humaine systématique, levier ×3–6 | Maîtrisé |
| Produit | Itération sur usage réel, scope arbitré, renoncements documentés | Pragmatique |
| Modélisation | Taxonomie ingrédients/verres/saveurs, ETL complet, vocabulaire standardisé (EN) | Solide |
| Budget | Infrastructure 0$ by design, build vs buy documenté, coût IA contrôlé | Maîtrisé |
| Temps | 45h → projet production-ready, spec avant code, sessions bornées, levier IA ×3–6 | Maîtrisé |
| Refactoring | Renommage atomique 32 fichiers, tokens sémantiques, partials consolidés | Discipliné |
| IA outillage | rtk token proxy, sessions en anglais, IA comme miroir de compétences implicites | Maîtrisé |

---

## XVII. Questions ouvertes & décisions en suspens

### Lighthouse CI — couverture suffisante ?

Le job `lighthouse` dans la CI audite la homepage en post-deploy. Questions non tranchées :

- **Alternatives a11y** : axe-core ou pa11y pour un audit d'accessibilité plus exhaustif que Lighthouse seul ?
- **Couverture** : auditer également les pages recettes, pas seulement la homepage ?
- **PR vs post-deploy** : Lighthouse sur preview PR (détecte les regressions avant merge) vs sur site live (audite la réalité). Seul le post-deploy est implémenté — le PR preview n'est pas encore couvert.

**Piste :** Ajouter `@axe-core/playwright` dans les tests BDD comme assertion a11y automatique — coût faible, gain en couverture.

### Langue des sessions Claude — English ou français ?

Les sessions sont maintenant conduites en anglais (+ rtk pour l'optimisation des tokens). Gain réel difficile à mesurer :

- **Code et CLI** : la langue de session ne change probablement rien — le code est language-agnostic
- **Recherche et nuances techniques** : la documentation anglophone est statistiquement plus dense → légère amélioration possible
- **Contenu et UX du site** : le projet est francophone, les templates et CSS restent en français — l'anglais crée une friction de traduction mentale

**Hypothèse actuelle :** Gain marginal et contextuel. Continuer en anglais pour les sessions techniques pures, revenir au français pour les décisions de contenu ou d'UX.

### CLAUDE.md global machine

Un `CLAUDE.md` local (`01-mocktails/CLAUDE.md`) est en place et bien rempli. Manque : un `~/.claude/CLAUDE.md` global avec les convictions et conventions transverses à tous les projets (stack philosophy, naming conventions, reflex `/plan`, préférences de réponse).

**À faire :** Extraire les principes généraux du `CLAUDE.md` local et les élever au niveau global.
