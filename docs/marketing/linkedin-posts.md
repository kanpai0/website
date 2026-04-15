# Posts LinkedIn — Kanpai Ø

## Sélection (7 posts retenus)

| # | Angle | Date de publication |
|---|-------|---------------------|
| 1 | Deploy first — pensée produit + gestion du risque | Mercredi 15 avril, soir |
| 2 | Design system embarqué + régression visuelle | Lundi 20 avril, soir |
| 3 | ADR sur un projet perso — culture de la décision | Jeudi 23 avril, midi |
| 4 | Release automation sans npm — philosophie de stack | Lundi 27 avril, soir |
| 5 | CI/CD + quality gates — chaîne de gardes fous | Jeudi 30 avril, midi |
| 6 | Feedback terrain — je suis mon propre utilisateur | Lundi 4 mai, soir |
| 7 | CTA missions + teasing prochain projet | Jeudi 7 mai, midi |

---

## Post 1 — "Mettre en prod avant d'écrire la première feature"

Le premier commit d'un projet n'a pas à contenir de code métier. Sur Kanpai Ø — un site de recettes de cocktails sans alcool — le premier commit installe Hugo, branche Cloudflare Pages, configure le domaine avec un 301. Build en 11 ms. Aucune recette, aucune interface. L'objectif n'était pas d'avoir un produit fonctionnel, c'était de valider l'infrastructure avant d'y investir du contenu.

Cette séparation entre hypothèse technique et hypothèse produit est quelque chose que j'applique systématiquement. Résoudre les deux en même temps, c'est accepter de mélanger les risques. Si le déploiement posait un problème — pipeline, domaine, CORS, configuration Hugo — je voulais le découvrir sans 24 recettes à réécrire. Ce n'est pas de la prudence excessive : c'est de la gestion de risque élémentaire.

Ce réflexe vient de projets où le pipeline a été configuré trop tard, quand le coût du changement était déjà élevé. Deploy first reste l'une des décisions les plus simples à prendre et les plus difficiles à transmettre en équipe.

Le repo est privé mais accessible sur demande si vous voulez voir la structure réelle. Et si vous cherchez quelqu'un avec ce type de réflexes sur un projet — je suis disponible pour des missions freelance.

---

## Post 2 — "Un design system embarqué dans le site — pas dans un Storybook"

Sur Kanpai Ø, la page `/design-system/` est une vraie page du site, servie par Hugo, accessible publiquement. Elle liste les 13 composants du site — palette, typographie, pills de saveurs, icônes d'ingrédients, types de verres, carte de recette, footer — chacun annoté avec un attribut `data-ds` qui sert de cible aux tests Playwright.

L'idée de départ était simple : si le design system est séparé du site, il va dériver. Si les composants vivent dans le site lui-même et sont testés visuellement par section (et non en full-page, plus difficile à déboguer), chaque régression est localisable immédiatement. Les snapshots sont générés localement dans un conteneur Docker officiel Playwright — même version que la CI — pour garantir que les polices rendent de façon identique sur macOS et sur Linux. La CI compare, elle ne génère jamais.

Ce n'est pas une approche courante sur un site statique solo. Mais la question n'était pas « est-ce que c'est nécessaire ? » — c'était « est-ce que je veux découvrir une régression visuelle deux semaines après l'avoir introduite ? ». La réponse était non. 13 sections testées, seuil à 1 % de diff pixels, bloque les merges.

Le repo est privé mais partageable sur demande. Je suis disponible pour des missions freelance.

---

## Post 3 — "Écrire des ADR sur un projet perso"

Les ADR — Architecture Decision Records — sont souvent réservés aux grandes équipes, aux projets avec plusieurs contributeurs, aux contextes où les décisions doivent être auditables. Sur Kanpai Ø, il n'y a qu'un seul développeur. J'ai quand même 22 ADR datés.

Le format est simple : un dossier horodaté dans `specs/`, un fichier `plan.md` avec le contexte, les alternatives considérées, la décision retenue, et le rationale explicite. L'ADR sur le release tooling compare git-cliff et semantic-release avec un tableau de décision. L'ADR sur les tests visuels documente pourquoi Cypress est écarté (plugin screenshot payant), pourquoi BackstopJS est trop lourd, pourquoi Playwright est retenu. La branch `feat/semantic-release` a été créée, testée, et abandonnée — la trace reste dans le git.

La valeur d'un ADR n'est pas dans la documentation pour les autres. Elle est dans la discipline qu'il impose à soi-même : formuler un problème clairement, nommer les alternatives, expliciter pourquoi on ne les a pas choisies. Cela prend 20 minutes. Cela évite de répéter les mêmes erreurs six mois plus tard.

Le repo est privé mais accessible sur demande. Ces pratiques prennent encore plus de sens en équipe — je cherche des missions freelance en ingénierie, architecture, ou lead technique.

---

## Post 4 — "Release automation sans npm dans un repo Hugo"

Hugo n'a pas de `package.json`. Ajouter semantic-release pour automatiser les releases aurait introduit 329 packages npm et un `package-lock.json` de 6122 lignes dans un projet qui n'en a délibérément aucun. J'ai créé la branch, installé le package, et observé le résultat. Puis j'ai supprimé la branch.

À la place : git-cliff (binaire Go, installé via Homebrew) et 157 lignes de bash. `make release-dry` affiche le prochain numéro de version et le changelog prévu. `make release` demande une confirmation interactive avant d'écrire quoi que ce soit. La commande bumpe la version dans `hugo.toml`, génère le CHANGELOG, crée le commit et le tag. L'override `--bump minor` est disponible quand les commits ne reflètent pas l'intention réelle.

La décision n'était pas de fuir la complexité — c'était de refuser d'introduire un outil dont la philosophie de stack est orthogonale au projet. Un bon outil s'adapte à la stack existante. Un outil qui redéfinit la stack pour exister n'est pas le bon outil.

Repo accessible sur demande. Je suis ouvert à des missions freelance — ingénierie logicielle, architecture, outillage de delivery.

---

## Post 5 — "Le deploy ne se déclenche pas sans que les tests aient passé"

Sur Kanpai Ø, la ligne `needs: [lighthouse, visual-regression]` dans le workflow GitHub Actions dit une chose simple : le deploy ne se déclenche pas sans que les tests de régression visuelle et l'audit Lighthouse aient passé. Pas une convention — une contrainte mécanique.

La couche locale est en dessous : un hook pre-commit exécute `hugo build` et valide le schéma des données frontmatter à chaque commit. `make preflight` joue le rôle d'un second avis avant push — build complet, validation de schéma, tests Playwright dans le même conteneur Docker que la CI. L'idée était simple : une régression détectée en commit local coûte 30 secondes. Détectée en prod, elle coûte un rollback et une investigation.

Sur un projet solo, il n'y a pas de code review humaine pour absorber les erreurs. La CI est la seule paire d'yeux extérieure. La réponse n'était pas d'accepter ce risque — c'était de le compenser par une chaîne de gardes fous qui s'activent en couches successives : hook local, tests visuels sur PR, Lighthouse sur push, deploy conditionnel. Chaque couche rattrape ce que la précédente peut rater.

Le repo est privé mais accessible sur demande. Je cherche des missions où cette rigueur est partagée — ingénieur senior, architecte, ou lead technique selon le contexte.

---

## Post 6 — "Je suis mon propre utilisateur — et mes amis m'ont changé le produit"

Kanpai Ø est un outil que j'utilise vraiment. Chaque fois que j'ai des invités, il est ouvert sur un téléphone posé sur le comptoir. Ce feedback direct — immédiat, sans filtre — a conduit à plus de changements que je n'aurais prévu.

En montrant le site à des amis, j'ai observé ce qu'ils cherchaient réellement : pas un type de spiritueux — une humeur, une saveur. Cette observation a motivé le déplacement des spiritueux vers le « frigo » et la mise en avant des pills de saveurs comme premier critère de filtrage. Des ajustements cosmétiques et ergonomiques ont suivi chaque session : la taille des cards, l'ordre des sections, la lisibilité des filtres sur mobile. Rien de radical en apparence — mais rien n'était juste avant d'avoir vu de vraies personnes utiliser le produit sur un vrai écran.

Ce que ce projet m'a rappelé, c'est quelque chose que je trouve trop rare en mission : la proximité réelle avec les utilisateurs. Pas les personas, pas les analytics — les personnes qui utilisent le produit et qui montrent, en temps réel, ce qui ne fonctionne pas encore. C'est une forme de feedback qui manque dans beaucoup d'équipes, et que je cherche activement dans les contextes où je travaille.

Le repo est privé mais partageable sur demande. Je suis disponible pour des missions freelance — et si possible dans des équipes proches de leurs utilisateurs.

---

## Post 7 — "Ce projet est la réponse à la question : à quoi ressemble votre travail ?"

Kanpai Ø est un site de recettes de cocktails sans alcool — 24 recettes, un système de filtres par ingrédients et saveurs, une interface en Hugo + vanilla CSS, déployé sur Cloudflare Pages. Un projet simple en apparence, mais que j'ai intentionnellement construit comme je construis du logiciel professionnel : spécifications avant code, ADR pour les décisions d'architecture, tests de régression visuelle, pipeline CI/CD qui bloque les merges en cas d'échec, release automation versionnée. Le tout en ~45h de travail effectif sur 3 semaines, pour un coût de lancement de 58€.

Ce n'est pas un projet portfolio conçu pour paraître impressionnant. C'est un outil que j'utilise vraiment, dont les décisions techniques ont été prises pour de bonnes raisons documentées, et dont le code est lisible par quelqu'un qui ne l'a jamais vu.

En route pour le prochain side project.

Si vous cherchez un ingénieur senior, architecte logiciel ou lead technique pour une mission freelance — quelqu'un qui livre régulièrement en production, documente ses décisions, et sait conduire une équipe vers ces standards — je suis disponible. Le repo est privé mais je le partage volontiers. Un message suffit. Profil complet sur LinkedIn.

---

## Notes de format

La première phrase de chaque post doit tenir seule, sans contexte — c'est ce qui s'affiche avant le « voir plus ».

Règles structurelles :
- Pas de liste à puces
- Ouvre sur un fait concret ou une décision, jamais sur une question rhétorique
- CTA final : repo sur demande + disponibilité freelance (les deux, dans cet ordre)
