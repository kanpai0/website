# Méthodes & outillage Ikima 1 → Kanpai Ø

Liste exhaustive des méthodes, scripts et structures d'Ikima 1
transposables à Kanpai Ø, établie le 2026-08-03 après inventaire
croisé des deux repos (Makefiles, tools/, scripts/, CI, hooks,
configs, docs). Non priorisée — on planifie lot par lot.

Effort indicatif : (S) < 1 h, (M) demi-journée, (L) plusieurs sessions.
Les items ~~barrés~~ sont faits.

**État au 2026-08-03** : A.1–A.6 (lot 1), B.7 + extraction de B.8,
C.16–C.18 (lot 2), D.19–D.20 (lot 3), B.10–B.13 (lot 4) livrés.
`make validate` = 7 checks ; la CI builde une fois et gate le deploy.
D.21 et D.23 écartés (décision Vincent) ; D.22 vérifié (pas de
deploy CF doublon). Restent : B.9, B.14, B.15, E, F, G.

---

## A. Quick wins outillage

1. ~~**Bump Playwright 1.59.1 → 1.62.1** + playwright-bdd 8.5 → 9.2 — version épinglée à 3 endroits : `package.json` (devDeps), script `pw` (tag image Docker), `container` de `ci.yml`. (S)~~
2. ~~**`check-pw-version.sh`** adapté aux 3 points de pin, source de vérité = package.json. (S)~~
3. ~~**`check-sh.sh`** — `bash -n` sur tous les scripts shell. (S)~~
4. ~~**`lint-sh.sh`** — shellcheck (épinglé dans `.mise.toml` mais jamais invoqué jusqu'ici). (S)~~
5. ~~**`scripts/lib/ok.sh`** + convention `QUIET=1` — sortie ✓ chronométrée uniforme des checks. (S)~~
6. ~~**Makefile self-documenté** — `.DEFAULT_GOAL := help`, descriptions `##`, `.PHONY`. (S)~~

## B. Gate unique `make validate`

7. ~~**Cible `validate`** avec `VALIDATE_CHECKS` + fan-out parallèle `gmake -j --output-sync`. (M)~~
8. ~~**Extraire les checks du pre-commit en scripts autonomes** (`check-fridge`, `check-flavors`, build Hugo) appelables par make et le hook. (M)~~ — reste le câblage CI (cf. D.19).
9. **`check-todos.sh`** — TODO sans référence backlog refusé (grep, pas rg — frugalité). (S)
10. ~~**Parseur strict du frontmatter en module Node testé** remplaçant les greps bash — « logique dans des modules, pas dans le shell ». (M)~~ — v1 : subset YAML maison (295 lignes) ; **révisé au palier 2 sur push-back Vincent** : extraction par `yq` (mikefarah, épinglé mise, `--front-matter=extract`), `frontmatter.mjs` réduit à la validation sémantique pure (144 lignes). Couvre glass/color (enums), source_* (checklist G mécanisée) et l'invariant recette ⊆ icônes **∩ inputs panel**.
11. ~~**Équivalent `check-dom.sh`** sur `public/` : sélecteurs consommés par le JS garantis dans le HTML généré. (M)~~ — inclut l'invariant dynamique `const FRIDGE` → inputs `fr-*`.
12. ~~**Parse at frontier sur le localStorage** (frigo) + scénarios BDD sur états corrompus — manque n°2 de la rétro. (M)~~ — unions discriminées, ne throw jamais ; 3 scénarios BDD (18/18 verts).
13. ~~**`check-design-system.sh`** — chaque partial référencé sur la page design-system. (S)~~ — noté : la section fridge-items duplique le markup du panel à la main (risque de drift, non traité).
14. **`validate-agent-safe`** — sous-ensemble exécutable en sandbox Claude/Cowork. (S)
15. **`watch-validate`** via watchexec (inutile de porter `watch-serve` : `hugo serve` hot-reload déjà). (S)

## C. Hooks git

16. ~~**Versionner le hook `commit-msg`** (`scripts/git-hooks/`) — était non versionné, snippet CLAUDE.md cassé. (S)~~
17. ~~**pre-commit = `mise exec -- make validate`** + bootstrap PATH pour hooks lancés par l'IDE. (S)~~
18. ~~**`make install-hooks` installe les deux hooks.** (S)~~

## D. CI/CD

19. ~~**Refonte `ci.yml` façon Ikima** : job `build` unique → artefact `public/` partagé → `validate` + `visual-regression` en parallèle → `deploy` gated par les deux. (M)~~ — `make validate-ci` en CI ; `lighthouse` déplacé post-deploy (le yml contredisait le README).
20. ~~Hygiène workflow : `permissions: contents: read`, `concurrency` sur deploy, `checkout@v6`. (S)~~
21. ~~**PR obligatoire + ruleset status checks + squash only + auto-delete branch** + PR template avec checklist. (S–M)~~ — **écarté** (2026-08-03) : pas de PR obligatoire en flux solo ; tout le reste en découlait. Gate réel = hooks locaux + CI au push.
22. **Vérifier qu'aucun deploy CF automatique** (intégration Git de Pages) ne double le deploy gated — le piège Workers Builds d'Ikima. (S, vérification dashboard CF par Vincent)
23. ~~Option : **migration CF Pages → Workers Static Assets**. (M)~~ — **écarté** (2026-08-03) : aucun gain fonctionnel, aucun exclusif Pages utilisé. Déclencheur de réouverture : lot E, si l'écart des deux pipelines de deploy devient un irritant concret.

## E. Release (convergence notée en mémoire Cowork 2026-05-11)

24. **Fichier `VERSION` comme source unique** au lieu du grep/sed sur `hugo.toml` (injection dans hugo.toml au release). (S)
25. **`release.sh` convergent**, paramétré par un `release.config.sh` listant les cibles d'injection (hugo.toml vs partial HTML) — et décider du sort des extras Kanpai (preflight interactif, revue backlog README). (M)
26. `cliff.toml` aligné — déjà quasi identiques, diff cosmétique. (S)
27. **Backlog README → `BACKLOG.md` format Ikima**, ce qui supprime la section interactive fragile de 40 lignes dans release.sh. (M)
28. **Corriger le drift doc** : CLAUDE.md décrit un release qui écrirait `specs/<date>-release/release-notes.md` — le script ne le fait pas. (S)

## F. Docs : ADR, RFC, process

29. **Extraire les vrais ADR de `specs/`** → `docs/adr/ADR-NNN` avec statut + déclencheur d'irréversibilité. Les 28 dossiers sont des plans horodatés ; trier : vraies décisions (semantic versioning, release tooling, visual regression, BDD, directory layout, abandon PWA…) vs plans de feature à archiver tels quels. (L)
30. **`docs/rfc/` parking lot avec déclencheurs** — candidats : section « V2 si le projet évolue » du README (SEO/schema.org, Pagefind, affiliation), monitoring JS prod et sitemap de la rétrospective. (M)
31. **`check-adr-trigger` / `check-rfc-trigger` / `check-scorecard`** une fois cette structure en place. (S, dépend de 29–30)
32. **`docs/MAP.md`** — flowchart Mermaid des décisions/liens. (S)
33. **`docs/dev-process/memory/*.md` versionnées** — la rétrospective note une mémoire Claude stale ; le pattern Ikima (mémoire durable dans le repo) règle ça. (S)
34. **CLAUDE.md refondu style Ikima** : court, principes, refus automatiques, checklist fin de tâche. (M)
35. **PROCESS.md + les trois principes ancrés** (ship-by-default, architect sous condition, RFC parking lot) adaptés au périmètre Kanpai. (M)
36. **Trancher la convention bilingue** — Kanpai mélange (CLAUDE.md en anglais, README en français) ; attention au README-vitrine Malt qui a ses propres contraintes. (S)

## G. Arborescence & configs

37. **`scripts/` → `tools/`** avec la même séparation qu'Ikima : gates (`check-*`), `git-hooks/`, `lib/` — et décider où vivent les pipelines de contenu Python (scrape, images), d'une autre nature. (M)
38. **Consolidation `docs/`** : specs/, design/, sources/ et docs/ actuels → une arbo unique (adr, rfc, dev-process, research, marketing). (M)
39. **`src/` avec Hugo** : possible via `contentDir`/`layoutDir`/`staticDir`/`assetDir` dans hugo.toml — à tester contre la CI et le deploy avant de s'engager. (M)
40. Divers : tsconfig modernisé (ES2022, bundler — actuellement ES2020/commonjs), `maxDiffPixelRatio` 0.01 → 0.001 ?, hygiène .gitignore (public/, test-results/). Biome sur tests/*.ts et *.mjs = palier T2, seulement si irritant mesuré. (S)

## Sens inverse (Kanpai → Ikima), pour la méthode commune

- `make doctor` (versions épinglées + dernière dispo)
- job **Lighthouse** avec budget.json
- rappel de **checklist manuelle** en fin de preflight
- README-vitrine structuré

## Notes pour la planification

- La T-012 d'Ikima liste l'harmonisation Ikima/Kanpai comme
  **déclencheur n°5 de réouverture** de la question du runner
  (mise tasks vs make) — le moment venu, elle se rouvre.
- Plusieurs items (rg, biome, dep-tree) ajoutent des outils : à passer
  au filtre irritant par paliers (T0→T3) avant adoption.
- Après tout bump Playwright : baselines visuelles à régénérer
  (`make test-update`) si Chromium a bougé.
