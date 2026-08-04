# RFC — Kanpai Ø

Un « parking lot » de questions vues passer, sourcées depuis le README (§ V2
si le projet évolue, § Alternatives écartées) ou `docs/retrospective-manques.md`.
**Aucune décision n'est prise dans ces documents.**

## Principe

Une RFC enregistre : une question vue passer, pourquoi elle n'est pas traitée
maintenant, et un **déclencheur de réouverture** explicite et numéroté. Une
RFC n'est **jamais inflatée en ADR** sans qu'un déclencheur ait été franchi —
`make check-rfc-trigger` refuse en revue toute RFC au statut `Ouvert*` sans ce
champ.

Structure plate (petit corpus, 5 RFC) — pas de sous-dossiers par catégorie.

## Index

| N° | Sujet | Statut |
|---|---|---|
| [RFC-001](RFC-001-seo-donnees-structurees.md) | SEO & données structurées | Ouverte |
| [RFC-002](RFC-002-recherche-pagefind.md) | Recherche Pagefind | Ouverte |
| [RFC-003](RFC-003-monitoring-js-production.md) | Monitoring JS en production | Ouverte |
| [RFC-004](RFC-004-mode-offline-pwa.md) | Mode hors-ligne / PWA | Ouverte |
| [RFC-005](RFC-005-monetisation-legere.md) | Monétisation légère | Ouverte |

## Statuts

- **Ouverte** : question parquée, déclencheur de réouverture non franchi.
- **Close → ADR-NNN** : la question a été tranchée, décision archivée dans
  l'ADR référencé.

Voir aussi `docs/adr/` (décisions tranchées, avec déclencheur d'irréversibilité)
et `docs/specs/` (historique de fabrication complet).
