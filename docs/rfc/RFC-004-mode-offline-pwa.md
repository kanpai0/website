# RFC-004 — Mode hors-ligne / PWA

**Statut** : Ouverte

## Contexte

Le sujet a été évalué le 2026-04-19 (`docs/specs/2026-04-19-1543-pwa/plan.md`,
`status: rejected`) : le gain visé par une PWA (manifeste + service worker) —
cache offline en cuisine, wifi instable — a été jugé insuffisant. Ce n'est
pas une décision d'architecture verrouillée (rien n'a été codé, rien n'est
irréversible) : c'est un arbitrage produit réversible à faible coût, qui
n'a donc pas sa place en ADR. Cette RFC est la seule trace de cet arbitrage
et de sa réouverture éventuelle.

## Pistes envisagées (non tranchées)

1. **Statu quo** — aucune PWA, aucun cache (option actuelle).
2. **PWA complète** (manifeste + service worker + cache offline) — écartée : l'invalidation de cache qu'elle introduit n'est pas justifiée sur un site déjà rapide en statique (build Hugo, Cloudflare Pages).
3. **Manifeste seul** (splash screen, thème, mode standalone) sans service worker — écarté : les gains visés (icône d'accueil, mode standalone) sont déjà obtenus sur iOS via « Ajouter à l'écran d'accueil » sans manifeste PWA ; le reste (splash screen, couleur de thème) est cosmétique.
4. PWA avec cache automatique de la dernière page consultée — non évaluée en détail, listée pour mémoire.

## Déclencheur de réouverture

1. Un usage mobile réel et récurrent est constaté (au-delà d'une simple consultation ponctuelle).
2. Une demande explicite d'utilisation sans réseau est formulée par un utilisateur.

Source : docs/specs/2026-04-19-1543-pwa/plan.md (status: rejected, § Decision rationale).
