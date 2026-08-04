# ADR-001 — Générateur de site : Hugo

**Date** : 2026-03-23
**Statut** : Accepté (rétroactif, 2026-03-23 — à signer)
**Palier d'outillage** : 2 — binaire autonome (Hugo, un seul exécutable Go), contre les générateurs à écosystème Node (Eleventy, Astro…) qui imposeraient `node_modules` pour un site sans besoin de build applicatif.
**Déclencheur d'irréversibilité** : le contenu est structuré en frontmatter Hugo dès la première fiche recette (commit `10cae5a`, 2026-03-24), et les templates ainsi que les URLs publiées (`/recettes/<slug>/`) en découlent directement. Changer de générateur de site statique impose de réécrire tous les templates, de migrer le frontmatter des 24 recettes vers le nouveau moteur, et risque de casser des URLs déjà publiées. Coût déjà > 1 jour dès l'import du catalogue complet (commit `3c1ba56`, le soir même).

## Contexte

Premier commit du projet (`4597ac9`, 2026-03-23 15h24) : une page d'accueil de 11 lignes affichant uniquement le titre du site — un démarrage délibérément minimal. Ce même commit inclut `BRIEF.md` (123 lignes), dont le tableau « Stack technique » retient déjà Hugo : « Binaire Go, ultra rapide, zéro dépendance Node, maturité ». Ce choix n'est donc pas improvisé au fil de l'eau : il est écrit avant la première ligne de contenu réel.

La suite confirme le critère qui a guidé ce choix. Le lendemain (`10cae5a`, 2026-03-24 15h32) : une unique fiche recette, mobile-first, charte visuelle codée en CSS custom. Le soir même (`3c1ba56`, 21h32) : les 24 recettes Sober Spirits importées d'un coup, la fiche devient catalogue. Un outil à itération rapide — binaire unique, aucun build Node à maintenir — était la condition pour tenir ce rythme (page-titre → fiche → catalogue en moins de 30 heures). Le tableau « Stack technique » du BRIEF migre ensuite tel quel dans le README (commit `80cfbff`, 2026-03-31, migration BRIEF→README) : le rationale ci-dessous est donc traçable de bout en bout depuis le jour 1, pas reconstruit après coup.

## Décision

**Générateur de site statique** : Hugo (binaire Go, zéro dépendance Node).

## Alternatives écartées

Le plan source (`plan.md` du 2026-03-23) ne documente aucune alternative explicitement comparée à Hugo — la décision y est actée directement (« Hugo installé », « site minimal créé »), sans table d'arbitrage dans le fichier lui-même. Le rationale existe cependant ailleurs, écrit le jour même :

| Alternative (implicite) | Raison du rejet (source : `BRIEF.md`, commit `4597ac9`, tableau « Stack technique ») |
|---|---|
| *(aucune alternative nommée dans le plan ou le BRIEF)* | Hugo retenu pour : « Binaire Go, ultra rapide, zéro dépendance Node, maturité ». Aucun concurrent (Jekyll, Eleventy, Astro…) n'est cité ni comparé dans les sources disponibles, jour 1 ou rétroactives. |

## Conséquences

- Zéro pipeline Node ou PHP au runtime du site — cohérent avec toutes les décisions d'outillage ultérieures (ADR-003, ADR-005).
- Le frontmatter Hugo devient la source de vérité du contenu (validé plus tard par `check-content`, lot B.10).
- Déploiement automatique dès le premier commit — aucune étape manuelle de mise en prod à partir de là.
- **Hébergement (mention, pas une décision de cette ADR)** : le choix initial — Cloudflare Pages, retenu dès le BRIEF jour 1 pour « Gratuit, CDN mondial, déploiement Git » (« Push → Cloudflare Pages build automatique ») — visait précisément à éviter de monter un pipeline CI/CD au démarrage. Remplacé le 2026-04-02 (commit `b5b5746`, v1.5.2) par un déploiement via GitHub Actions + `wrangler`, quand l'arrivée de la régression visuelle (ADR-004) a créé le besoin d'un gate avant mise en prod. Doctrine appliquée ici : une bascule d'hébergeur statique se fait en ~30 minutes et se décide en message de commit, pas en ADR — elle n'a donc pas sa propre entrée dans ce document.

Source : docs/specs/2026-03-23-1645-minimal-website/plan.md ; BRIEF.md (commit `4597ac9`) ; historique git (commits `10cae5a`, `3c1ba56`, `80cfbff`, `b5b5746`).
