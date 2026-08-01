# Makefile — Kanpai Ø
#
# Point d'entrée unique des tâches de dev. Les outils sous-jacents (hugo, node,
# python, git-cliff, shellcheck, jq) sont épinglés dans .mise.toml.
# Machine neuve : `brew install mise`, puis `make bootstrap`.

.PHONY: bootstrap install-hooks serve build test test-update release release-dry doctor preflight

# --- Bootstrap (une seule fois après git clone) ---

bootstrap:
	mise install
	npm ci
	$(MAKE) install-hooks

install-hooks:
	@mkdir -p .git/hooks
	@cp scripts/pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "git hooks installed (pre-commit)"

# --- Dev loop ---

serve:
	hugo serve

build:
	hugo build

test:
	npm test

test-update:
	npm run test:update

release:
	bash scripts/release.sh

release-dry:
	bash scripts/release.sh --dry-run

preflight:
	bash scripts/preflight.sh

doctor:
	@echo "=== Épinglé (.mise.toml) ==="
	@mise ls --current
	@echo "=== Hors mise ==="
	@git --version
	@docker --version 2>/dev/null || echo "docker: absent (requis par npm test)"
	@echo "=== Dernière version Hugo disponible ==="
	@curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r '.tag_name'
