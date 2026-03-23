Objectif : Sortir une page minimale en production pour valider l'architecture.
                                                                                                                              
---                                                                                                                         
Ce qui a été fait

1. Hugo installé (v0.158.0 via Homebrew)
2. Site minimal créé — hugo.toml + layouts/index.html avec juste le titre, build en 11ms
3. Premier commit poussé sur github.com/kanpai0/website (semantic commit : feat: initial Hugo site — Kanpai Ø)
4. Cloudflare Pages configuré — build hugo, output public, HUGO_VERSION=0.158.0
5. Domaine kanpai0.co branché sur Cloudflare Pages (SSL automatique)
6. Redirection 301 dynamique kanpai0.com → https://kanpai0.co${http.request.uri}

  ---                                                                                                                         
Prochaines étapes logiques
- Intégrer PicoCSS
- Créer le layout de base et les premières recettes
- Configurer Pagefind pour la recherche
