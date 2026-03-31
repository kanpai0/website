#!/usr/bin/env bash
# Semantic release using git-cliff for changelog + version bump detection.
#
# Usage:
#   bash scripts/release.sh              # auto-determine bump via git-cliff
#   bash scripts/release.sh --bump minor # override bump (major|minor|patch)
#   bash scripts/release.sh --dry-run    # preview, write nothing

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false
BUMP_OVERRIDE=""

# ---------------------------------------------------------------------------
# 1. Parse flags
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=true ;;
    --bump)      shift; BUMP_OVERRIDE="$1" ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# 2. Assert dependencies
# ---------------------------------------------------------------------------
if ! command -v git-cliff &>/dev/null; then
  echo "ERROR: git-cliff not found. Install with: brew install git-cliff"
  exit 1
fi

# ---------------------------------------------------------------------------
# 3. Assert clean working tree
# ---------------------------------------------------------------------------
if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean. Commit or stash changes first."
  exit 1
fi

# ---------------------------------------------------------------------------
# 4. Read current version from hugo.toml
# ---------------------------------------------------------------------------
current_version=$(grep -E '^  version = ' "$REPO_ROOT/hugo.toml" \
  | sed 's/.*version = "\(.*\)"/\1/')

if [[ -z "$current_version" ]]; then
  echo "ERROR: Could not read version from hugo.toml."
  exit 1
fi

# ---------------------------------------------------------------------------
# 5. Determine next version
# ---------------------------------------------------------------------------
if [[ -n "$BUMP_OVERRIDE" ]]; then
  IFS='.' read -r major minor patch <<< "$current_version"
  case "$BUMP_OVERRIDE" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
    *) echo "ERROR: Invalid bump type: $BUMP_OVERRIDE (expected major|minor|patch)"; exit 1 ;;
  esac
  new_version="${major}.${minor}.${patch}"
else
  bumped=$(git-cliff --bumped-version 2>/dev/null || echo "")
  # Strip leading "v"
  new_version="${bumped#v}"
fi

# ---------------------------------------------------------------------------
# 6. Abort if nothing to release
# ---------------------------------------------------------------------------
if [[ "$new_version" == "$current_version" ]]; then
  echo "No releasable commits since v${current_version}. Nothing to release."
  echo "(Only breaking changes, feat:, fix:, perf:, refactor: trigger a release.)"
  echo "Use --bump patch to force a patch release."
  exit 0
fi

release_date=$(date +%Y-%m-%d)

# ---------------------------------------------------------------------------
# 7. Preview changelog via git-cliff (stdout only)
# ---------------------------------------------------------------------------
echo ""
echo "==============================="
echo "  Release preview"
echo "==============================="
echo "  Current : v${current_version}"
echo "  Next    : v${new_version}"
echo "  Date    : ${release_date}"
echo ""
git-cliff --tag "v${new_version}" --unreleased
echo "==============================="
echo ""

if $DRY_RUN; then
  echo "[dry-run] No files written, no commits, no tags."
  exit 0
fi

# ---------------------------------------------------------------------------
# 8. Interactive README.md backlog review
# ---------------------------------------------------------------------------
backlog_lines=()
while IFS= read -r line; do
  backlog_lines+=("$line")
done < <(grep -n '- \[ \]' "$REPO_ROOT/README.md" 2>/dev/null || true)

if [[ ${#backlog_lines[@]} -gt 0 ]]; then
  echo "Backlog items — mark as done? (space-separated numbers, or Enter to skip)"
  for i in "${!backlog_lines[@]}"; do
    # Strip leading line number and "- [ ] " prefix for display
    label=$(echo "${backlog_lines[$i]}" | sed 's/^[0-9]*:- \[ \] //')
    printf "  %d. %s\n" $((i + 1)) "$label"
  done
  read -r -p "→ " picks
  for pick in $picks; do
    idx=$((pick - 1))
    if [[ $idx -ge 0 && $idx -lt ${#backlog_lines[@]} ]]; then
      lineno=$(echo "${backlog_lines[$idx]}" | cut -d: -f1)
      # Replace [ ] with [x] on that exact line number
      sed -i '' "${lineno}s/- \[ \]/- [x]/" "$REPO_ROOT/README.md"
      label=$(echo "${backlog_lines[$idx]}" | sed 's/^[0-9]*:- \[ \] //')
      echo "  ✓ Marked done: ${label}"
    fi
  done
  echo ""
fi

# ---------------------------------------------------------------------------
# 9. Prompt for confirmation
# ---------------------------------------------------------------------------
read -r -p "Proceed with release v${new_version}? [y/N] " answer
[[ "$answer" =~ ^[Yy] ]] || { echo "Aborted."; exit 0; }

# ---------------------------------------------------------------------------
# 9. Generate / prepend CHANGELOG.md
# ---------------------------------------------------------------------------
if [[ -f "$REPO_ROOT/CHANGELOG.md" ]]; then
  git-cliff --tag "v${new_version}" --unreleased --prepend "$REPO_ROOT/CHANGELOG.md"
else
  git-cliff --tag "v${new_version}" --output "$REPO_ROOT/CHANGELOG.md"
fi

# ---------------------------------------------------------------------------
# 10. Write specs/<date>-release-vX.Y.Z/release-notes.md
# ---------------------------------------------------------------------------
specs_dir="$REPO_ROOT/specs/${release_date}-release-v${new_version}"
mkdir -p "$specs_dir"
git-cliff --tag "v${new_version}" --unreleased --output "${specs_dir}/release-notes.md"

# ---------------------------------------------------------------------------
# 11. Update version in hugo.toml
# ---------------------------------------------------------------------------
sed -i '' "s/version = \"${current_version}\"/version = \"${new_version}\"/" "$REPO_ROOT/hugo.toml"

# ---------------------------------------------------------------------------
# 12. Commit, tag, push
# ---------------------------------------------------------------------------
git -C "$REPO_ROOT" add \
  CHANGELOG.md \
  hugo.toml \
  README.md \
  "specs/${release_date}-release-v${new_version}/release-notes.md"

git -C "$REPO_ROOT" commit -m "chore: release v${new_version}"
git -C "$REPO_ROOT" tag "v${new_version}"

git -C "$REPO_ROOT" push origin main
git -C "$REPO_ROOT" push origin "v${new_version}"

echo ""
echo "✓ Released v${new_version}"
