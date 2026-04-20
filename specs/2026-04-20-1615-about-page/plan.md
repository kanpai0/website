# Page About — Storytelling Kanpai Ø

## Pourquoi

Le site n'avait aucune page identitaire. Deux publics n'avaient pas de point d'entrée :

- Les **curieux** qui veulent comprendre le nom, l'icône et les deux fonctionnalités du site.
- Les **recruteurs** qui cherchent à comprendre la démarche technique derrière un projet solo.

## Ce qui a été construit

### `content/about.md`

Page Hugo avec `layout: about`, exclue du sitemap (`sitemap.disable: true`) et indexation désactivée (`noindex`). Pas de contenu Markdown — tout vit dans le layout.

### `layouts/about.html`

Hérite de `baseof.html` via les blocs Hugo. Body class `about-page` pour les overrides CSS.

Structure de la page :

| Section | Contenu |
|---|---|
| Hero | `favicon.svg` à 140px, coins arrondis (22%, style app iOS), titre en Playfair italic, sous-titre en japonais |
| Le nom | Étymologie de Kanpai (乾杯) et Ø, unicité de kanpai0 |
| Deux usages | Deux cartes côte à côte : invité (goûts → pilules de saveurs) et hôte (frigo → panneau Mon frigo) |
| La démarche | Liste factuelle de 5 décisions techniques + liens Design System et LinkedIn |

### `static/css/main.css`

Section `.about-*` ajoutée (~80 lignes) :
- Grille deux colonnes pour les cartes, passage à une colonne sous 480px
- Bordure gauche sage pour la liste technique
- `border-radius: 22%` sur l'icône pour l'effet app icon

### `layouts/partials/footer.html`

Lien "À propos" ajouté avant "Mentions légales" dans `.site-footer__meta`.

## Décisions

**Lien dans le footer uniquement** — La page est utile mais périphérique. Le header reste épuré (juste le logo). Un lien footer discret suffit sans encombrer la navigation principale.

**Contenu dans le layout, pas dans le Markdown** — La page est structurée visuellement (cartes, listes), pas en prose libre. Le Markdown ne serait pas adapté. Le layout contrôle entièrement le rendu.

**Icône via `<img src="/favicon.svg">`** — Le SVG est déjà optimisé dans `static/`. L'intégrer via `<img>` évite de dupliquer le code SVG dans le template et permet au navigateur de le mettre en cache.

**Ton factuel pour la démarche** — Choix délibéré : liste de faits courts (sans narration) pour un lecteur recruteur qui scanne. Contraste avec les sections invité/hôte, plus narratives.

**Ordre des items techniques** — Réorganisé manuellement après génération : Deploy first → Décisions documentées → Qualité intégrée → Sobriété technique → CSS comme machine d'état. Logique narrative : du process vers l'implémentation.
