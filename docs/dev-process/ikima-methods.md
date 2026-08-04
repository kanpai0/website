# Méthodes & outillage Ikima 1 → Kanpai Ø

Liste exhaustive des méthodes, scripts et structures d'Ikima 1
transposables à Kanpai Ø, établie le 2026-08-03 après inventaire
croisé des deux repos (Makefiles, tools/, scripts/, CI, hooks,
configs, docs). Non priorisée — on planifie lot par lot.

Effort indicatif : (S) < 1 h, (M) demi-journée, (L) plusieurs sessions.
Les items ~~barrés~~ sont faits.

**État au 2026-08-04** : A (lot 1), B.7–8 + C (lot 2), D.19–20
(lot 3), B.10–13 (lot 4, révisé yq lot 5), G (lot 6), F.29–31 +
E.28 (lot 7) livrés, F.32–36 (lot 10) livrés. `make validate` = 10
checks ; CI build unique + deploy gated ; arbo `src/` + `tools/` +
`docs/{adr,ddr,specs}`.
**ADR-001…005 rétroactifs en attente de signature Vincent.**
D.21/D.23 écartés, D.22 vérifié.
Restent : B.9, B.14, B.15, E.24–27 (release).

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
28. ~~**Corriger le drift doc** : CLAUDE.md décrivait un release qui écrirait `specs/<date>-release/release-notes.md` + un push automatique — le script ne fait ni l'un ni l'autre. (S)~~ — soldé au lot F (même phrase, même cause).

## F. Docs : ADR, DDR, process

29. ~~**Extraire les vrais ADR de `specs/`** → `docs/adr/ADR-NNN` avec statut + déclencheur d'irréversibilité. (L)~~ — **5 ADR** rétroactifs (à signer), avec en-tête doctrine dans `docs/adr/README.md` (ship-by-default, > 1 j, 3 paliers) et ligne « Palier d'outillage » par ADR. Sources primaires retrouvées dans le git (BRIEF jour 1, commit `4597ac9`).
30. ~~**`docs/ddr/` parking lot avec déclencheurs**. (M)~~ — DDR-001 SEO/schema.org, 002 Pagefind, 003 monitoring JS, 004 PWA, 005 monétisation. Structure plate, sourcées README + rétro + BRIEF jour 1 (renommées DDR le 2026-08-04).
31. ~~**`check-adr-trigger` / `check-ddr-trigger` / `check-scorecard`**. (S)~~ — câblés dans validate (10 checks).
32. ~~**`docs/MAP.md`** — flowchart Mermaid des décisions/liens. (S)~~ — 5 ADR + 5 DDR, liens sourcés (zéro-Node, runner Playwright, plan PWA refusé, README V2, rétrospective §1).
33. ~~**`docs/dev-process/memory/*.md` versionnées** — la rétrospective note une mémoire Claude stale ; le pattern Ikima (mémoire durable dans le repo) règle ça. (S)~~ — 3 fiches seed (bash 3.2, paliers d'outillage, logique en modules), format Ikima name/description/type.
34. ~~**CLAUDE.md refondu style Ikima** : court, principes, refus automatiques, checklist fin de tâche. (M)~~ — réécriture complète en français, 3 principes ancrés (dont architect sous condition, conservé).
35. ~~**PROCESS.md + les trois principes ancrés** (ship-by-default, architect sous condition, DDR parking lot) adaptés au périmètre Kanpai. (M)~~ — nouveau fichier, grille de triage + paliers + table des 10 checks.
36. ~~**Trancher la convention bilingue** — Kanpai mélange (CLAUDE.md en anglais, README en français) ; attention au README-vitrine Malt qui a ses propres contraintes. (S)~~ — **tranché 2026-08-04 : doc projet FR / code EN**, décidé avec F.34.

## G. Arborescence & configs

37. ~~**`scripts/` → `tools/`** avec la séparation Ikima : gates (`check-*`), `git-hooks/`, `lib/`, release, preflight. (M)~~ — `scripts/` ne garde que les pipelines de contenu (python + download-recipe-images.sh).
38. ~~**Consolidation `docs/`** partielle : design/ → docs/design, sources/ → docs/sources. (M)~~ — **`specs/` ne bouge pas** : son triage (F.29) décidera des destinations.
39. ~~**`src/` avec Hugo** via `contentDir`/`layoutDir`/`staticDir`. (M)~~ — vérifié `public/` byte-identique. Piège : les clés doivent être **au top-level du TOML, avant `[params]`** (sinon capturées par la table et silencieusement ignorées).
40. ~~Divers : tsconfig ES2022/bundler/noEmit, `maxDiffPixelRatio` 0.01 → 0.001, `.gitignore` + playwright-report/. (S)~~ — Biome **écarté** (frugalité, pas d'irritant mesuré).

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
