.PHONY: serve build test test-update release release-dry doctor preflight

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
	@echo "=== Installed ==="
	@hugo version
	@git-cliff --version
	@python3 --version
	@git --version
	@echo "=== Latest Hugo ==="
	@curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
	  | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])"
