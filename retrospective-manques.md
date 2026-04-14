# Retrospective — Manques et angles morts

Analyse critique du projet Kanpai Ø basée sur l'historique git, les specs, et les conversations.  
Dernière mise à jour : 2026-04-10

---

## Contexte de lecture

Ce projet est un **outil personnel en premier lieu** : barman de mes propres soirées + mes invités. Pas de validation d'audience externe requise, pas de SEO intentionnel, pas de monétisation en v1. L'itération est volontairement adaptative.

Ce cadre est posé ici pour éviter de projeter des critiques qui ne s'appliquent pas.

---

## Manques techniques confirmés

### 1. Pas de monitoring JS en production

Si le filtrage frigo ou saveurs casse sur un navigateur non couvert par les tests (Safari iOS, vieux Android WebView), je ne le saurai pas. Les tests BDD passent en Chromium/Pixel5 simulé — la prod est plus diverse.

**Options légères :** Cloudflare Web Analytics error tracking, ou un simple `window.onerror` qui log quelque part.

---

### 2. Tests BDD : états corrompus non couverts

Le `Background` clear localStorage est bon. Mais la robustesse de la désérialisation n'est pas testée : que se passe-t-il si `localStorage.fridge` contient un JSON invalide, un array vide, ou des slugs qui n'existent plus dans le catalogue ?

**À vérifier :** le code JS a-t-il un fallback propre sur `JSON.parse` qui échoue ?

---

### 3. Pas de sitemap ni de structured data

Pas un oubli critique vu la nature du projet, mais `schema.org/Recipe` déclencherait des rich snippets Google (temps de préparation, ingrédients, note) si l'audience venait à s'élargir. Hugo génère un sitemap avec `enableRobotsTXT = true` — coût quasi nul.

---

### 4. Dépendance éditoriale à une seule source

24 recettes viennent toutes de Sober Spirits. Attribution présente dans le footer, mais :
- Fragilité si Sober Spirits change de politique de contenu
- Aucune recette originale — différenciation nulle sur le fond
- Le contenu ne peut pas évoluer sans une nouvelle extraction

---

## Manques de méthode

### 5. Pas de post-mortem documenté

Les specs/plan.md documentent les décisions prises. Aucune ne consigne ce qui ne s'est pas passé comme prévu :
- Le bug YAML du dernier item dans `orange-spritz.md` (regex `\n` vs `\n?`)
- La branch `feat/semantic-release` abandonnée après comparaison
- L'abandon de PicoCSS et Pagefind (initialement prévus, jamais intégrés)

Documenter les renoncements et les corrections est aussi précieux que les décisions — surtout pour reprendre le projet après une pause.

---

### 6. Pas de définition d'acceptation fonctionnelle

La `QUALITY_CHECKLIST.md` est orientée technique (build, tests, ARIA, légal). Il n'existe pas de critère du type :  
*"Un utilisateur peut identifier et sélectionner une recette faisable avec ce qu'il a dans son frigo en moins de 30 secondes sur mobile."*

Ce n'est pas bloquant pour un outil personnel avec un seul utilisateur qui connaît le produit — mais utile si un tiers reprend le projet ou si l'ambition évolue.

---

### 7. La mémoire de contexte (Claude) est stale

Le fichier `memory/project_setup.md` liste encore PicoCSS et Pagefind comme "à intégrer". Ces deux choix ont été abandonnés.

**Action :** mettre à jour ce fichier (déjà demandé — voir fin de ce document).

---

## Ce qui est délibéré et non un manque

| Item | Pourquoi ce n'est pas un angle mort |
|------|-------------------------------------|
| Pas d'analytics | Je suis mon propre utilisateur. Le feedback est direct et continu. |
| Pas de SEO | Le public cible est mes invités, pas Google. |
| Monétisation absente | Déplacée en v2 optionnelle, pour amortir les coûts si besoin. |
| Pas de framework CSS ou JS | Choix philosophique cohérent avec la stack Hugo. Pas une omission. |
| 24 recettes seulement | Suffisant pour l'usage actuel. L'expansion est un choix, pas une urgence. |

---

## Actions potentielles (par priorité personnelle)

1. **Court terme** : `window.onerror` minimal pour savoir si le JS casse en prod
2. **Moyen terme** : tester la robustesse de `JSON.parse` sur `localStorage.fridge`
3. **Si l'audience grandit** : `schema.org/Recipe` + sitemap Hugo
4. **Si reprise après pause** : écrire un post-mortem des abandons (PicoCSS, Pagefind, semantic-release)

---

## Erreurs de méthode — apprentissages en cours de projet

### 8. Retard sur les outils de vérification

Les outils de qualité ont été mis en place trop tard dans le projet :
- La **page design system** (`/design-system/`) aurait dû exister dès les premières composantes CSS
- **Playwright** et la **pipeline CI/CD** sont arrivés après que le code fonctionnel était déjà en place
- Résultat : les premières features n'ont pas de baseline visuelle ; les regressions sont impossibles à dater avec précision

**Ce qui aurait dû se passer :** Setup de la pipeline en session 2 ou 3, juste après le premier deploy. Les tests auraient forcé une conception plus propre dès le départ.

---

### 9. Réflexe `/plan` encore insuffisant

Pour les opérations importantes (migration de frontmatter, restructuration de taxonomie, refactoring de templates), la planification `/plan` a parfois été sautée au profit de l'implémentation directe.

**Impact :** Quelques allers-retours évitables, une migration validée mentalement mais pas exécutée (voir section 10).

**Règle à s'imposer :** Toute opération touchant plus de 3 fichiers ou impliquant un changement de structure = `/plan` d'abord.

---

## Challenges — tensions récurrentes

### 10. Le sentiment étrange : planification vs exécution

À deux reprises sur ce projet, une piste a été étudiée en profondeur, une direction choisie — et le fichier n'a pas été modifié. Mais la conviction d'avoir validé était réelle.

**Ce qui s'est probablement passé :** Le mode `/plan` produit une décision claire, mais si la session se termine sans passer en mode exécution, la décision "vit" dans la mémoire de session et non dans le code. La prochaine session part avec la conviction que c'est fait.

**Piste de solution :** Tout plan validé devrait se terminer soit par une exécution immédiate, soit par une note explicite `TODO : non encore exécuté` dans le fichier concerné. Ne pas fermer une session de planification sans ancrer l'état.

---

### 11. Trop de custom vs configuration globale

Tendance à reconfigurer des comportements déjà définis globalement — par exemple, des instructions passées à Claude en session qui auraient pu être dans un `CLAUDE.md` global à la machine.

**Symptôme :** Les préférences (style de réponse, conventions de nommage, philosophie de stack) sont redécouvertes ou réintroduites à chaque conversation.

**Solution identifiée :** Créer un `CLAUDE.md` global (`~/.claude/CLAUDE.md`) avec les convictions et conventions transverses. Ce projet a bien un `CLAUDE.md` local — mais le niveau machine manque encore.

---

### 12. Nommage des variables — manque d'orientation métier

Certaines variables CSS et JS restent trop techniques ou trop génériques : `cb`, `item`, `el`, `val`. Le refactoring `--subtitle` → `--accent` est une bonne illustration de ce qui manquait dès le départ.

**Principe à appliquer :** Un nom de variable doit répondre à "à quoi ça sert dans le domaine ?" pas "quel type de données c'est ?". `--accent` dit son rôle. `--subtitle` disait son origine.

---

### 13. Propositions d'outils non adaptées à la stack

À plusieurs reprises, des outils ont été suggérés (Python, Node.js, libraries tierces) alors que des solutions natives ou plus légères existaient.

Exemples concrets :
- **Python → bash** : certains scripts utilitaires ont été réécrits en bash pur après avoir été générés en Python
- **Node.js / semantic-release → bash + git-cliff** : voir arbre ci-dessous
- **CSS au lieu de JS** : le panneau frigo, les pills de saveurs, l'indicateur frigo — tous résolus CSS-only grâce à `:has()` et checkbox state machine

**Leçon :** L'outil proposé par défaut est souvent le plus connu de l'IA, pas le plus adapté à la stack. Recadrer explicitement en début de session ("stack bash uniquement", "pas de Node", "CSS d'abord") évite les propositions hors-contexte.

---

## Alternatives explorées — arbre de décision

Chaque piste ci-dessous a été évaluée sérieusement avant d'être abandonnée. Le renoncement est documenté, pas subi.

```
Release tooling
├── [ABANDONNÉ] semantic-release (Node.js)
│   ├── Testé : branch feat/semantic-release créée
│   ├── Résultat : 8263 fichiers installés via npm
│   ├── Verdict : philosophiquement incompatible avec "pas de Node dans un repo Hugo"
│   └── → bash + git-cliff retenu (157 lignes, 0 dépendance Node)
│
├── [ABANDONNÉ] PicoCSS
│   ├── Évalué : intégration partielle testée
│   ├── Résultat : surcharge de reset non voulue, conventions qui entrent en conflit
│   └── → CSS custom retenu (350 lignes, contrôle total)
│
└── [ABANDONNÉ] Pagefind
    ├── Évalué : recherche full-text côté client
    ├── Résultat : 24 recettes → recherche inutile, le filtre frigo suffit
    └── → non intégré

Tests
├── [FAIT] Playwright (visual regression + BDD)
│   └── Choisi sur Cypress (screenshot test payant) et BackstopJS (trop lourd)
│
└── [FAIT] playwright-bdd
    └── Choisi sur @cucumber/cucumber (414 dépendances transitives vs 12)

Génération d'images
├── [ABANDONNÉ] rembg + SDXL local (Apple Silicon)
│   └── Fond transparent du verre supprimé avec le fond — image vide
├── [ABANDONNÉ] dall-e-3 + suppression numpy du fond blanc
│   └── Moins fiable sur les verres transparents
└── [FAIT] gpt-image-1 avec background: "transparent" natif

Icône de l'application
├── [TESTÉ] method.ac (éditeur SVG en ligne)
├── [TESTÉ] lovable.dev (génération IA)
├── [TESTÉ] toolkit.artlist.io
├── [TESTÉ] recraft.ai
├── [TESTÉ] Gemini → meilleurs résultats visuels
├── [EN COURS] Claude + Pencil
└── Blocage identifié : vocabulaire artistique insuffisant pour décrire l'esthétique précise souhaitée (cocktail 0% — mélange de concepts contradictoires visuellement)
```

---

## Questions en suspens

### Lighthouse CI — est-ce suffisant ?

Lighthouse CLI est intégré dans la pipeline CI/CD (`lighthouse` job post-deploy). Questions ouvertes :
- Y a-t-il des alternatives plus exhaustives pour un audit a11y (axe-core, pa11y) ?
- Le job actuel audite uniquement la homepage — devrait-on auditer les pages recettes aussi ?
- Lighthouse sur site live (post-deploy) vs Lighthouse sur preview PR : les deux sont utiles, seul le post-deploy est implémenté

**Décision à prendre :** Ajouter axe-core comme second niveau d'audit a11y dans la CI, ou considérer que Lighthouse est suffisant pour ce projet.

---

### L'anglais dans les conversations IA — vraiment utile ?

Les sessions Claude sont maintenant conduites en anglais (+ rtk pour l'optimisation des tokens). Question légitime : est-ce que ça change quelque chose aux outputs ?

**Hypothèse :** La connaissance stockée par un LLM est statistiquement plus riche en anglais (davantage de contenu technique anglophone). Mais pour un projet francophone avec du contenu, des templates et du CSS en français, le gain réel est difficile à mesurer.

**Intuition actuelle :** Le gain est marginal pour les tâches de code (le code est language-agnostic), plus notable pour les tâches de recherche ou de nuance technique. À réévaluer sur quelques sessions.

---

## Ce que l'IA a révélé sur mes propres compétences

Un effet inattendu et précieux : en analysant avec l'IA tout ce qui a été mis en place, des techniques et méthodes connues mais pas nommées ont émergé.

Exemples : "checkbox state machine", "body class theming", "ETL pipeline", "ADR pattern" — des pratiques appliquées intuitivement, que l'inventaire a nommées et formalisées.

**Ce que ça révèle :** Je connais ces techniques bien assez pour les appliquer correctement — mais sans le vocabulaire précis, les expliquer à un recruteur ou une équipe est difficile. L'IA comme outil de formalisation de compétences implicites est un usage sous-estimé.

Le même déficit de vocabulaire s'applique au design et à l'art : le challenge de la création d'icône (section "arbre de décision") vient en partie de l'impossibilité de décrire précisément l'esthétique souhaitée avec les bons termes artistiques.
