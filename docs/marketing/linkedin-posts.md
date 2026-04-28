# Posts LinkedIn - Kanpai Ø

## Sélection (7 posts retenus)

| # | Angle | Date de publication |
|---|-------|---------------------|
| 1 | Deploy first - pensée produit + gestion du risque | Mercredi 15 avril, soir |
| 2 | Design system embarqué + régression visuelle | Lundi 20 avril, soir |
| 3 | ADR sur un projet perso - culture de la décision | Jeudi 23 avril, midi |
| 4 | Release automation sans npm - philosophie de stack | Lundi 27 avril, soir |
| 5 | CI/CD + quality gates - chaîne de gardes fous | Jeudi 30 avril, midi |
| 6 | La proximité avec les utilisateurs, ça ne se simule pas | Lundi 4 mai, soir |
| 7 | CTA missions + teasing prochain projet | Jeudi 7 mai, midi |

---

## [PUBLIÉ] Post 1 - "Mettre en prod avant d'écrire la première feature"

Le premier commit d'un projet n'a pas à contenir de code métier. Sur Kanpai Ø (kanpai0.co, un site de recettes de cocktails sans alcool), le premier commit installe Hugo, branche Cloudflare Pages, configure le domaine avec un 301. Build en 11 ms. Aucune recette, aucune interface. L'objectif n'était pas d'avoir un produit fonctionnel, c'était de valider l'infrastructure avant d'y investir du contenu.

Cette séparation entre hypothèse technique et hypothèse produit est quelque chose que j'applique systématiquement. Résoudre les deux en même temps, c'est accepter de mélanger les risques. Si le déploiement posait un problème (pipeline, domaine, CORS, configuration Hugo), je voulais le découvrir sans 24 recettes à réécrire. Ce n'est pas de la prudence excessive : c'est de la gestion de risque élémentaire.

Ce réflexe vient de projets où le pipeline a été configuré trop tard, et les mises en production trop rares. Les écarts entre environnements ne se révèlent jamais au bon moment si on les laisse s'accumuler. Deploy first, ce n'est pas seulement valider que la pipeline fonctionne : c'est poser l'habitude de livrer régulièrement en prod pour s'assurer que l'environnement est opérationnel et que tout est correctement configuré. Ce qui ne passe pas par la prod reste une hypothèse. Deploy first reste l'une des décisions les plus simples à prendre et les plus difficiles à transmettre en équipe.

--  
Le repo est privé mais accessible sur demande si vous voulez voir la structure réelle. Et si vous cherchez quelqu'un avec ce type de réflexes sur un projet, je suis disponible pour des missions freelance.

---

## [PUBLIÉ] Post 2 - "Un design system embarqué dans le site, pas dans un Storybook"

Sur Kanpai Ø, la page `/design-system/` est une vraie page du site, servie par Hugo, accessible publiquement sur kanpai0.co/design-system/. Elle liste les 14 composants du site : palette, typographie, pills de saveurs, icônes d'ingrédients, types de verres, carte de recette, footer. Chacun est annoté avec un attribut `data-ds` qui sert de cible aux tests Playwright.

Pourquoi pas Storybook ? Parce qu'il aurait introduit une grosse dépendance Node.js sur un site statique Hugo qui n'en avait pas besoin. L'arbitrage serait différent avec une équipe multi-métiers, un catalogue plus large, ou un framework SPA (React, Vue, Angular). Sur Kanpai Ø, la page `/design-system/` native remplit le même rôle sans ajouter de stack.

L'idée de départ était simple : si le design system est séparé du site, il va dériver. Si les composants vivent dans le site lui-même et sont testés visuellement par section (et non en full-page, plus difficile à déboguer), chaque régression est localisable immédiatement. Les snapshots sont générés localement dans un conteneur Docker officiel Playwright (même version que la CI) pour garantir que les polices rendent de façon identique sur macOS et sur Linux. La CI compare, elle ne génère jamais.

Ce n'est pas une approche courante sur un site statique solo. Mais la nécessité n'est pas le bon angle : c'est d'abord un garde-fou, notamment contre les régressions introduites par du code généré par IA. 14 sections testées, seuil à 1 % de diff pixels, bloque les merges.

--  
Le repo est privé mais partageable sur demande. Je suis disponible pour des missions freelance où la sobriété technique est un critère.

---

## [PUBLIÉ] Post 3 - "Écrire des ADR sur un projet perso"

Les ADR (Architecture Decision Records) sont souvent réservés aux grandes équipes, aux projets avec plusieurs contributeurs, aux contextes où les décisions doivent être auditables. Sur Kanpai Ø, il n'y a qu'un seul développeur. J'ai quand même 27 ADR datés.

Le format est simple : un dossier horodaté dans `specs/`, un fichier `plan.md` avec le contexte, les alternatives considérées, la décision retenue, et le rationale explicite. L'ADR sur le release tooling compare git-cliff et semantic-release avec un tableau de décision. L'ADR sur les tests visuels documente pourquoi Cypress est écarté (plugin screenshot payant), pourquoi BackstopJS est trop lourd, pourquoi Playwright est retenu. La branch `feat/semantic-release` a été créée, testée, et abandonnée, la trace reste dans le git.

La valeur d'un ADR n'est pas seulement dans la documentation pour les autres. Elle est dans la discipline qu'il impose à soi-même : formuler un problème clairement, nommer les alternatives, expliciter pourquoi on ne les a pas choisies. Cela prend 20 minutes. Cela évite de répéter les mêmes erreurs six mois plus tard et la mémoire d'un développeur étant très courte, cela permet de se rappeler pourquoi on a choisi ou écarter telle solution.

--  
Le repo est privé mais accessible sur demande. Ces pratiques prennent encore plus de sens en équipe, je cherche des missions freelance en ingénierie, architecture, ou lead technique.

---

## Post 4 - "Release automation sans npm dans un repo Hugo"

Hugo n'a pas de `package.json`. Ajouter semantic-release pour automatiser les releases aurait introduit 329 packages npm et un `package-lock.json` de 6122 lignes dans un projet qui n'en a délibérément aucun. J'ai créé la branche, installé le package, et observé le résultat. Puis j'ai supprimé la branche.

À la place : git-cliff (binaire Go, installé via Homebrew) et 157 lignes de bash. `make release-dry` affiche le prochain numéro de version et le changelog prévu. `make release` demande une confirmation interactive avant d'écrire quoi que ce soit. La commande bumpe la version dans `hugo.toml`, génère le CHANGELOG, crée le commit et le tag. L'override `--bump minor` est disponible quand les commits ne reflètent pas l'intention réelle.

La règle que j'applique n'est pas « pas de npm ». Elle est plus précise : un outil qui redéfinit la stack doit passer trois filtres. Existe-t-il une alternative qui s'inscrit dans la stack existante ? Apporte-t-il une valeur que rien d'autre ne couvre ? Le ratio entre son coût en dépendances et sa valeur réelle est-il favorable ? semantic-release échoue sur les trois : git-cliff fait le travail, le besoin est trivial, et 329 packages pour générer un changelog est un mauvais ratio.

Playwright, lui, passe les trois filtres. Pas d'équivalent Go/Rust mature pour piloter un vrai navigateur. La valeur est unique : bloquer les régressions visuelles, y compris celles introduites par du code généré par IA. Et 60 packages pour cette garantie sur l'ensemble du site, c'est un ratio que j'assume. Une philosophie de stack n'a pas besoin d'exceptions tant qu'elle a des critères clairs.

--  
Repo public : github.com/kanpai0/website. Je suis ouvert à des missions freelance : ingénierie logicielle, architecture, outillage de delivery.

---

## Post 5 - "Le deploy ne se déclenche pas sans que les tests aient passé"

Sur Kanpai Ø, la ligne `needs: [lighthouse, visual-regression]` dans le workflow GitHub Actions dit une chose simple : le deploy ne se déclenche pas sans que les tests de régression visuelle et l'audit Lighthouse aient passé. Pas une convention, une contrainte mécanique.

La couche locale est en dessous : un hook pre-commit exécute `hugo build` et valide le schéma des données frontmatter à chaque commit. `make preflight` joue le rôle d'un second avis avant push : build complet, validation de schéma, tests Playwright dans le même conteneur Docker que la CI. L'idée était simple : une régression détectée en commit local coûte 30 secondes. Détectée en prod, elle coûte un rollback et une investigation.

Sur un projet solo, l'absence de code review rend simplement le besoin de CI plus lisible. Ce n'est pas une question d'effectif : en équipe, la relecture humaine et les tests automatisés sont deux couches distinctes, chacune rattrape ce que l'autre ne voit pas systématiquement. La réponse n'était pas d'accepter ce risque, c'était de le compenser par une chaîne de gardes fous qui s'activent en couches successives : hook local, tests visuels sur PR, Lighthouse sur push, deploy conditionnel. Chaque couche rattrape ce que la précédente peut rater.

--  
Repo public : github.com/kanpai0/website. Je cherche des missions où cette rigueur est partagée : ingénieur senior, architecte, ou lead technique selon le contexte.

---

## Post 6 - "La proximité avec les utilisateurs, ça ne se simule pas"

Kanpai Ø (kanpai0.co) est un outil que j'utilise vraiment. Chaque fois que j'ai des invités, il est ouvert sur un téléphone posé sur le comptoir. Le plaisir a été de les voir palper le produit, de vérifier si l'objectif est rempli, d'ajuster le tir en direct.

En montrant le site à des amis, j'ai observé ce qu'ils cherchaient réellement : pas un type de spiritueux, mais une humeur, une saveur. Cette observation a motivé le déplacement des spiritueux vers le « frigo » et la mise en avant des pills de saveurs comme premier critère de filtrage. La suite a été surtout des micro-ajustements : des recettes plus lisibles avec quelques touches de couleur, des boutons plus accessibles, les filtres affinés sur mobile. Des ajustements qu'on ne fait qu'en regardant quelqu'un s'en emparer vraiment.

Ce projet m'a aussi permis de faire quelque chose que j'aime : être au contact des utilisateurs, comprendre leurs attentes, construire une réponse qui s'affine au fil des échanges. Pas les personas, pas les analytics, mais les personnes qui utilisent le produit et montrent, en temps réel, ce qui peut encore s'améliorer. C'est quelque chose que je trouve trop rare en mission, et que j'aimerais voir plus souvent dans les contextes où je travaille.

--  
Repo public : github.com/kanpai0/website. Je suis disponible pour des missions freelance, et si possible dans des équipes proches de leurs utilisateurs.

---

## Post 7 - "Ce projet est la réponse à la question : à quoi ressemble votre travail ?"

Kanpai Ø (kanpai0.co) est un site de recettes de cocktails sans alcool : 24 recettes, un système de filtres par ingrédients et saveurs, une interface en Hugo + vanilla CSS, déployé sur Cloudflare Pages. Un projet simple en apparence, mais que j'ai intentionnellement construit comme je construis du logiciel professionnel : spécifications avant code, ADR pour les décisions d'architecture, tests de régression visuelle, pipeline CI/CD qui bloque les merges en cas d'échec, release automation versionnée. Le tout en ~45h de travail effectif sur 3 semaines, pour un coût de lancement de 58€.

Ce n'est pas un projet portfolio conçu pour paraître impressionnant. C'est un outil que j'utilise vraiment, dont les décisions techniques ont été prises pour de bonnes raisons documentées, et dont le code est lisible par quelqu'un qui ne l'a jamais vu.

En route pour le prochain side project !

--  
Si vous cherchez un ingénieur senior, architecte logiciel ou lead technique pour une mission freelance, quelqu'un qui livre régulièrement en production, documente ses décisions, et sait conduire une équipe vers ces standards, je suis disponible. Repo public : github.com/kanpai0/website. Un message suffit. Profil complet sur LinkedIn.

---

## Notes de format

La première phrase de chaque post doit tenir seule, sans contexte - c'est ce qui s'affiche avant le « voir plus ».

Règles structurelles :
- Pas de liste à puces
- Ouvre sur un fait concret ou une décision, jamais sur une question rhétorique
- CTA final : repo sur demande + disponibilité freelance (les deux, dans cet ordre)
