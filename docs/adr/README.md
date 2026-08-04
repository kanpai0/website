# ADR — Kanpai Ø

Décisions d'architecture, formalisées **rétroactivement** à partir des `plan.md`
horodatés sous `docs/specs/` (triage F.29) et, quand ils sont plus riches, de
l'historique git (commits cités par leur sha). Chaque ADR est signée par
Vincent avant de perdre la mention « à signer » dans son statut.

## Doctrine

Le défaut est de coder et de livrer : une ADR n'existe que si le retour en
arrière coûte **plus d'une journée de retravail** — cf. le **Déclencheur
d'irréversibilité** obligatoire dans chaque fichier, contrôlé par
`make check-adr-trigger`. En-dessous de ce seuil, la décision se prend, et se
change, en message de commit.

Tout choix d'outillage se classe sur trois paliers, cités dans chaque ADR
concernée (**Palier d'outillage**) :

1. **Natif POSIX / plateforme** — rien à installer.
2. **Binaire autonome** — un seul exécutable, zéro arbre de dépendances transitives.
3. **Écosystème de paquets** — `node_modules` ou équivalent. Exige une justification explicite : pourquoi les paliers 1 et 2 ne suffisent pas.

Une question identifiée mais pas encore tranchée n'est pas une ADR « au cas
où » : elle part en DDR (`docs/ddr/`), avec un **déclencheur de réouverture**
explicite, contrôlé par `make check-ddr-trigger`.

Refus type rencontrés en triant les 28 specs (F.29) — restent des plans, pas
des ADR : la structure d'un répertoire, la forme d'une donnée locale (un
objet JS plutôt qu'un fichier), le choix d'un wrapper de commande. Ce niveau
de détail se décide, et se change, en message de commit.

## Index

| N° | Titre | Date | Statut |
|---|---|---|---|
| [ADR-001](ADR-001-stack-hugo-cloudflare-pages.md) | Générateur de site : Hugo | 2026-03-23 | Accepté (rétroactif — à signer) |
| [ADR-002](ADR-002-css-custom-vs-framework.md) | CSS custom plutôt qu'un framework (PicoCSS) | 2026-03-24 | Accepté (rétroactif — à signer) |
| [ADR-003](ADR-003-release-tooling-git-cliff-bash.md) | Outillage de release : git-cliff + bash | 2026-03-31 | Accepté (rétroactif — à signer) |
| [ADR-004](ADR-004-outillage-visual-regression-playwright.md) | Outillage de régression visuelle : Playwright | 2026-04-02 | Accepté (rétroactif — à signer) |
| [ADR-005](ADR-005-bdd-playwright-bdd.md) | Tests fonctionnels BDD : playwright-bdd | 2026-04-02 | Accepté (rétroactif — à signer) |

Voir aussi `docs/ddr/` (décisions différées, pas encore tranchées) et
`docs/specs/` (l'historique de fabrication complet, 28 dossiers horodatés).
