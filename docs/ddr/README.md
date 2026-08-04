# DDR — Kanpai Ø

**DDR — Deferred Decision Record (décision différée).** Une DDR enregistre
une question vue passer, pourquoi elle n'est pas traitée maintenant, et le
déclencheur explicite qui la rouvrira. Rien n'y est proposé ni soumis à
commentaires — c'est ce qui la distingue d'une RFC au sens classique. Une
DDR n'est jamais convertie en décision sans qu'un déclencheur soit franchi.

Sourcées depuis le README (§ V2 si le projet évolue, § Alternatives
écartées) ou `docs/retrospective-manques.md`.

## Principe

Une DDR enregistre : une question vue passer, pourquoi elle n'est pas traitée
maintenant, et un **déclencheur de réouverture** explicite et numéroté. Une
DDR n'est **jamais inflatée en ADR** sans qu'un déclencheur ait été franchi —
`make check-ddr-trigger` refuse en revue toute DDR au statut `Ouvert*` sans ce
champ.

Structure plate (petit corpus, 5 DDR) — pas de sous-dossiers par catégorie.

## Index

| N° | Sujet | Statut |
|---|---|---|
| [DDR-001](DDR-001-seo-donnees-structurees.md) | SEO & données structurées | Ouverte |
| [DDR-002](DDR-002-recherche-pagefind.md) | Recherche Pagefind | Ouverte |
| [DDR-003](DDR-003-monitoring-js-production.md) | Monitoring JS en production | Ouverte |
| [DDR-004](DDR-004-mode-offline-pwa.md) | Mode hors-ligne / PWA | Ouverte |
| [DDR-005](DDR-005-monetisation-legere.md) | Monétisation légère | Ouverte |

## Statuts

- **Ouverte** : question parquée, déclencheur de réouverture non franchi.
- **Close → ADR-NNN** : la question a été tranchée, décision archivée dans
  l'ADR référencé.

Voir aussi `docs/adr/` (décisions tranchées, avec déclencheur d'irréversibilité)
et `docs/specs/` (historique de fabrication complet).
