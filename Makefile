# Makefile — Kanpai Ø
#
# Point d'entrée unique des tâches de dev. Les outils sous-jacents (hugo, node,
# python, git-cliff, shellcheck, jq) sont épinglés dans .mise.toml.
# Machine neuve : `brew install mise`, puis `make bootstrap`.
#
# `make validate` requiert GNU Make 4+ (fan-out parallèle via --output-sync) :
# macOS livre make 3.81, installer `brew install make` (fournit `gmake`).

.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash
.SHELLFLAGS := -ec

.PHONY: bootstrap install-hooks serve build test test-update release release-dry \
	preflight check-sh lint-sh check-pw-version check-content check-dom \
	check-design-system test-unit validate validate-ci doctor help

# --- Bootstrap (une seule fois après git clone) ---

bootstrap: ## Installation initiale : mise install + npm ci + hooks git
	mise install
	npm ci
	$(MAKE) install-hooks

install-hooks: ## (Ré)installe les hooks git versionnés depuis scripts/git-hooks/
	@mkdir -p .git/hooks
	@cp scripts/git-hooks/pre-commit .git/hooks/pre-commit
	@cp scripts/git-hooks/commit-msg .git/hooks/commit-msg
	@chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
	@echo "git hooks installed (pre-commit, commit-msg)"

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

check-content: ## Valide le frontmatter des recettes (parseur strict + règles fridge/flavors/glass/color)
	@node scripts/check-content.mjs

check-dom: ## Vérifie que public/ contient tous les sélecteurs consommés par fridge.js
	@bash scripts/check-dom.sh

check-design-system: ## Vérifie que chaque partial a sa section dans design-system.html
	@bash scripts/check-design-system.sh

test-unit: ## Tests unitaires node --test (dot ; ligne ✓ résumée si QUIET=1)
	@if [ "$${QUIET:-}" = "1" ]; then \
		_t=$$(node -p "Date.now()"); \
		out=$$(node --test --test-reporter=spec tests/unit/*.test.mjs 2>&1) && rc=0 || rc=$$?; \
		if [ $$rc -eq 0 ]; then \
			printf '\033[32m✓\033[0m tests \033[90m%dms\033[0m\n' "$$(( $$(node -p "Date.now()") - $$_t ))"; \
		else \
			printf '%s\n' "$$out" >&2; exit $$rc; \
		fi; \
	else \
		node --test --test-reporter=dot tests/unit/*.test.mjs; \
	fi

# --- Validation (pipeline pré-merge) ---

VALIDATE_CHECKS := check-sh lint-sh check-pw-version check-content check-dom check-design-system test-unit

validate: ## Pipeline complet : hugo build puis fan-out parallèle des checks (requiert gmake 4+)
	@hugo build --quiet
	@QUIET=1 gmake -j$$(sysctl -n hw.logicalcpu 2>/dev/null || nproc 2>/dev/null || echo 4) --output-sync=target --no-print-directory \
		$(VALIDATE_CHECKS)

validate-ci: ## Pipeline CI — fan-out parallèle sans build (public/ fourni par l'artefact CI)
	@QUIET=1 gmake -j$$(nproc 2>/dev/null || echo 4) --output-sync=target --no-print-directory \
		$(VALIDATE_CHECKS)

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
