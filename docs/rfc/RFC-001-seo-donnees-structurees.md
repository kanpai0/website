# RFC-001 — SEO & données structurées

**Statut** : Ouverte

## Contexte

Le projet n'a délibérément aucun SEO intentionnel en v1 — le public cible est
les invités de l'auteur, pas Google (`docs/retrospective-manques.md`, § « Ce
qui est délibéré et non un manque »). Le README liste néanmoins « SEO
(Schema.org `Recipe` + Open Graph + meta description) » dans son bloc « V2 si
le projet évolue ». La rétrospective (§3, « Pas de sitemap ni de structured
data ») note que Hugo génère déjà un sitemap avec `enableRobotsTXT = true` à
coût quasi nul, et que `schema.org/Recipe` déclencherait des rich snippets
Google (temps de préparation, ingrédients, note) si l'audience venait à
s'élargir.

## Pistes envisagées (non tranchées)

1. Sitemap Hugo natif (`enableRobotsTXT = true`) — coût quasi nul, aucune
   décision d'architecture requise.
2. `schema.org/Recipe` en JSON-LD par page recette.
3. Open Graph + meta description par recette (photo, titre, ingrédients).

## Déclencheur de réouverture

1. L'audience du site s'élargit au-delà du cercle personnel de l'auteur.
2. Un premier besoin concret de rich snippets Google est identifié.
3. Le SEO devient un objectif intentionnel du projet (actuellement explicitement non désiré).

Source : README.md (§ « V2 si le projet évolue ») ; `docs/retrospective-manques.md` (§3).
