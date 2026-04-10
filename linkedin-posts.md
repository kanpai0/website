# Sujets et posts LinkedIn — Kanpai Ø

Basé sur l'analyse du projet, de l'historique git, et des specs.

---

## Angle général

Le signal fort : **pratiques d'ingénierie professionnelle (ADR, design system, visual regression, BDD, release automation) appliquées à un side project à stack minimale et volontairement sobre.** La sophistication est dans le *comment*, pas dans la complexité de la stack.

---

## Posts à écrire

### A — "J'ai mis un site en prod en une journée — sans écrire une seule feature"

**Angle :** Deploy first, build second. Le premier commit ne fait que valider l'architecture — Hugo installé, Cloudflare Pages branché, domaine avec 301, build en 11ms. Aucune feature. L'objectif n'est pas d'avoir un produit, c'est de supprimer le risque d'infrastructure avant d'investir dans le contenu.

**Signal pour recruteur :** pensée produit, distinction entre hypothèse technique et hypothèse produit, gestion du risque.

---

### B — "Écrire des ADR sur un projet perso"

**Angle :** `specs/2026-03-31-1627-release-tooling-adr/plan.md` compare git-cliff vs semantic-release avec tableau de décision, rationale explicite, branch `feat/semantic-release` créée pour comparaison puis abandonnée. Chaque spec a une date, un statut, une liste de décisions explicitement justifiées.

**Signal pour recruteur :** culture de la décision documentée, pensée staff engineer, trace écrite des trade-offs.

---

### C — "Design system avant les features — même sur un projet solo"

**Angle :** Page `/design-system/` standalone créée tôt dans le projet, avec `data-ds` attributes ciblés pour les tests, visual regression Playwright section par section, Docker pour la parité Linux/macOS en local. Un design system n'est pas réservé aux grandes équipes — c'est un contrat sur l'intention visuelle.

**Signal pour recruteur :** engineering discipline, refus de la dette visuelle, testing.

---

### D — "Visual regression testing sur un site statique — sans Cypress, sans budget"

**Angle :** Playwright `toHaveScreenshot()` built-in, Docker pour la parité de rendu (les fonts rendent différemment sur macOS vs Linux CI), 6 tests par section plutôt qu'un full-page (plus actionable en cas d'échec). Les snapshots sont toujours générés en local, jamais en CI — la CI compare, elle ne génère pas.

**Décision notable :** Cypress nécessite un plugin payant pour le screenshot testing. Playwright l'a nativement. BackstopJS est trop lourd pour ce besoin. La décision de dépendance est explicite.

**Signal pour recruteur :** pragmatisme outil, CI/CD, quality gates.

---

### E — "BDD + Gherkin pour valider un système de filtres vanilla JS"

**Angle :** Scénarios Gherkin pour le frigo (panel open/close, uncheck ingredient, combinaison fridge+flavor) et les saveurs (AND logic, deselect restores). Le problème concret résolu : les checkboxes sont `display:none` en CSS, Playwright refuse de les interagir même avec `force:true`. Solution : `page.evaluate` + dispatch `change` event.

**Décision notable :** `playwright-bdd` (12 dépendances directes) choisi sur `@cucumber/cucumber` (~414 dépendances transitives) pour garder Playwright comme runner.

**Signal pour recruteur :** BDD, test design, résolution de problèmes concrets, choix de dépendances raisonné.

---

### F — "Release automation sans npm dans un projet Hugo"

**Angle :** `make release` / `make release-dry` / `make doctor`. git-cliff + bash, pas de package-lock.json dans un repo Hugo par philosophie. Preview interactif avant tout écrit, `--bump` override quand les commits ne reflètent pas l'intent réel.

**Angle complémentaire :** conventional commits hook local, cliff.toml template Tera pour le format CHANGELOG — les outils sont adaptés à la stack, pas l'inverse.

**Signal pour recruteur :** tooling ownership, cohérence philosophique de stack, release engineering.

---

### G — "Structured frontmatter : rendre les templates stupides"

**Angle :** Migration de `"50 ml de Rhum Sober Spirits"` (string opaque) vers `{name: "Rhum Sober Spirits", qty: "50 ml"}` dans le markdown, via scripts Python sur 24 fichiers. La décision documentée : "templates stay dumb, content is self-describing." Les templates Hugo n'ont plus de `replaceRE` ni de `split`.

**Signal pour recruteur :** separation of concerns, pensée long terme sur la maintenabilité du contenu, scripting d'automatisation.

---

### H — "Je suis mon propre premier utilisateur — et c'est délibéré"

**Angle :** Kanpai Ø est d'abord un outil pour moi (barman de mes soirées) et mes invités. Pas d'analytics, pas de SEO intentionnel — ce n'est pas un oubli, c'est une hypothèse. Le feedback loop est personnel et immédiat. Le déplacement des spiritueux vers le frigo et la mise en avant des saveurs vient d'une observation directe : mes invités cherchent une humeur ("quelque chose de fruité") pas un type d'alcool. C'est du jobs-to-be-done sans framework.

**Signal pour recruteur :** clarté sur le scope d'un projet, décision produit ancrée dans une observation réelle, honnêteté sur les objectifs.

---

### I — "ARIA sur un site de recettes — pourquoi c'est non-négociable"

**Angle :** Skip links, `role="main"`, `aria-labelledby`, live regions sur les filtres dynamiques. Pas une case à cocher — un engagement dès le début du projet. Lighthouse CI qui audite à chaque push.

**Signal pour recruteur :** accessibilité comme discipline, pas comme afterthought.

---

## Format recommandé pour chaque post

- Ouvrir sur le problème / la décision, pas sur la solution
- 1 décision concrète documentée avec son contexte
- 1 alternative explicitement rejetée et pourquoi
- Clore sur le principe général applicable ailleurs

**Longueur :** 150–300 mots. Éviter les listes à puces sur LinkedIn — les paragraphes courts performent mieux.
