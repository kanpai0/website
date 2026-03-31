.PHONY: serve build release release-dry doctor

serve:
	hugo serve

build:
	hugo build

release:
	bash scripts/release.sh

release-dry:
	bash scripts/release.sh --dry-run

doctor:
	@echo "=== Installed ==="
	@hugo version
	@git-cliff --version
	@python3 --version
	@git --version
	@echo "=== Latest Hugo ==="
	@curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
	  | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])"
