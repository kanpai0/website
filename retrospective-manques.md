# Retrospective — Manques et angles morts

Analyse critique du projet Kanpai Ø basée sur l'historique git, les specs, et les conversations.  
Dernière mise à jour : 2026-04-10

---

## Contexte de lecture

Ce projet est un **outil personnel en premier lieu** : barman de mes propres soirées + mes invités. Pas de validation d'audience externe requise, pas de SEO intentionnel, pas de monétisation en v1. L'itération est volontairement adaptative.

Ce cadre est posé ici pour éviter de projeter des critiques qui ne s'appliquent pas.

---

## Manques techniques confirmés

### 1. Pas de monitoring JS en production

Si le filtrage frigo ou saveurs casse sur un navigateur non couvert par les tests (Safari iOS, vieux Android WebView), je ne le saurai pas. Les tests BDD passent en Chromium/Pixel5 simulé — la prod est plus diverse.

**Options légères :** Cloudflare Web Analytics error tracking, ou un simple `window.onerror` qui log quelque part.

---

### 2. Tests BDD : états corrompus non couverts

Le `Background` clear localStorage est bon. Mais la robustesse de la désérialisation n'est pas testée : que se passe-t-il si `localStorage.fridge` contient un JSON invalide, un array vide, ou des slugs qui n'existent plus dans le catalogue ?

**À vérifier :** le code JS a-t-il un fallback propre sur `JSON.parse` qui échoue ?

---

### 3. Pas de sitemap ni de structured data

Pas un oubli critique vu la nature du projet, mais `schema.org/Recipe` déclencherait des rich snippets Google (temps de préparation, ingrédients, note) si l'audience venait à s'élargir. Hugo génère un sitemap avec `enableRobotsTXT = true` — coût quasi nul.

---

### 4. Dépendance éditoriale à une seule source

24 recettes viennent toutes de Sober Spirits. Attribution présente dans le footer, mais :
- Fragilité si Sober Spirits change de politique de contenu
- Aucune recette originale — différenciation nulle sur le fond
- Le contenu ne peut pas évoluer sans une nouvelle extraction

---

## Manques de méthode

### 5. Pas de post-mortem documenté

Les specs/plan.md documentent les décisions prises. Aucune ne consigne ce qui ne s'est pas passé comme prévu :
- Le bug YAML du dernier item dans `orange-spritz.md` (regex `\n` vs `\n?`)
- La branch `feat/semantic-release` abandonnée après comparaison
- L'abandon de PicoCSS et Pagefind (initialement prévus, jamais intégrés)

Documenter les renoncements et les corrections est aussi précieux que les décisions — surtout pour reprendre le projet après une pause.

---

### 6. Pas de définition d'acceptation fonctionnelle

La `QUALITY_CHECKLIST.md` est orientée technique (build, tests, ARIA, légal). Il n'existe pas de critère du type :  
*"Un utilisateur peut identifier et sélectionner une recette faisable avec ce qu'il a dans son frigo en moins de 30 secondes sur mobile."*

Ce n'est pas bloquant pour un outil personnel avec un seul utilisateur qui connaît le produit — mais utile si un tiers reprend le projet ou si l'ambition évolue.

---

### 7. La mémoire de contexte (Claude) est stale

Le fichier `memory/project_setup.md` liste encore PicoCSS et Pagefind comme "à intégrer". Ces deux choix ont été abandonnés.

**Action :** mettre à jour ce fichier (déjà demandé — voir fin de ce document).

---

## Ce qui est délibéré et non un manque

| Item | Pourquoi ce n'est pas un angle mort |
|------|-------------------------------------|
| Pas d'analytics | Je suis mon propre utilisateur. Le feedback est direct et continu. |
| Pas de SEO | Le public cible est mes invités, pas Google. |
| Monétisation absente | Déplacée en v2 optionnelle, pour amortir les coûts si besoin. |
| Pas de framework CSS ou JS | Choix philosophique cohérent avec la stack Hugo. Pas une omission. |
| 24 recettes seulement | Suffisant pour l'usage actuel. L'expansion est un choix, pas une urgence. |

---

## Actions potentielles (par priorité personnelle)

1. **Court terme** : `window.onerror` minimal pour savoir si le JS casse en prod
2. **Moyen terme** : tester la robustesse de `JSON.parse` sur `localStorage.fridge`
3. **Si l'audience grandit** : `schema.org/Recipe` + sitemap Hugo
4. **Si reprise après pause** : écrire un post-mortem des abandons (PicoCSS, Pagefind, semantic-release)
