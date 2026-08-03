# Makefile — Kanpai Ø
#
# Point d'entrée unique des tâches de dev. Les outils sous-jacents (hugo, node,
# python, git-cliff, shellcheck, jq) sont épinglés dans .mise.toml.
# Machine neuve : `brew install mise`, puis `make bootstrap`.

.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash
.SHELLFLAGS := -ec

.PHONY: bootstrap install-hooks serve build test test-update release release-dry \
	preflight check-sh lint-sh check-pw-version doctor help

# --- Bootstrap (une seule fois après git clone) ---

bootstrap: ## Installation initiale : mise install + npm ci + hooks git
	mise install
	npm ci
	$(MAKE) install-hooks

install-hooks: ## (Ré)installe .git/hooks/pre-commit depuis scripts/pre-commit.sh
	@mkdir -p .git/hooks
	@cp scripts/pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "git hooks installed (pre-commit)"

# --- Dev loop ---

serve: ## Serveur de dev Hugo avec rechargement à chaud
	hugo serve

build: ## Génère le site statique dans public/
	hugo build

test: ## Lance la suite de tests npm (unit + visual + BDD)
	npm test

test-update: ## Régénère les baselines visuelles (npm run test:update)
	npm run test:update

release: ## Bump de version, changelog, commit + tag (scripts/release.sh)
	bash scripts/release.sh

release-dry: ## Prévisualise la release sans rien écrire
	bash scripts/release.sh --dry-run

preflight: ## Contrôle qualité complet avant push (scripts/preflight.sh)
	bash scripts/preflight.sh

# --- Outillage shell ---

check-sh: ## Vérifie la syntaxe des scripts shell (bash -n)
	@bash scripts/check-sh.sh

lint-sh: ## Lint des scripts shell (shellcheck)
	@bash scripts/lint-sh.sh

check-pw-version: ## Vérifie l'alignement de la version Playwright (3 points d'épinglage)
	@bash scripts/check-pw-version.sh

doctor: ## Affiche les versions épinglées + dernière version Hugo disponible
	@echo "=== Épinglé (.mise.toml) ==="
	@mise ls --current
	@echo "=== Hors mise ==="
	@git --version
	@docker --version 2>/dev/null || echo "docker: absent (requis par npm test)"
	@echo "=== Dernière version Hugo disponible ==="
	@curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r '.tag_name'

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
