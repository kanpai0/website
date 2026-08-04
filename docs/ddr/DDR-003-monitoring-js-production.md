# DDR-003 — Monitoring JS en production

**Statut** : Ouverte

## Contexte

`docs/retrospective-manques.md` (§1, « Pas de monitoring JS en production »)
note que si le filtrage frigo ou saveurs casse sur un navigateur non couvert
par les tests (Safari iOS, vieux Android WebView), l'auteur ne le saura pas :
les tests BDD passent en Chromium/Pixel 5 simulé, la production est plus
diverse. La rétrospective cite deux options légères : Cloudflare Web
Analytics (error tracking) ou un simple `window.onerror` qui logge quelque
part.

## Pistes envisagées (non tranchées)

1. Cloudflare Web Analytics — déjà sur la même plateforme d'hébergement (Cloudflare Pages), pas de nouveau fournisseur.
2. `window.onerror` minimal — aucune dépendance, logge où ? (à définir si retenu).

Aucune des deux pistes n'a été comparée en détail ni chiffrée ; la
rétrospective les cite comme « options légères », pas comme un arbitrage.

## Déclencheur de réouverture

1. Un premier signalement utilisateur (invité) d'un filtre cassé, sans qu'il soit reproductible localement.
2. L'audience dépasse le cercle personnel de l'auteur (perte du feedback direct et continu actuel).

Source : docs/retrospective-manques.md (§1).
