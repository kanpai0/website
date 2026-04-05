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
# 7b. Quality gate
# ---------------------------------------------------------------------------
echo ""
read -r -p "Run preflight checks (npm test + manual checklist)? [Y/n] " _run_preflight
if [[ ! "$_run_preflight" =~ ^[Nn] ]]; then
  bash "$REPO_ROOT/scripts/preflight.sh" || { echo "Aborted: fix preflight failures first."; exit 1; }
  read -r -p "Manual checklist complete? [Y/n] " _quality_ok
  [[ ! "$_quality_ok" =~ ^[Nn] ]] || { echo "Aborted."; exit 0; }
fi
echo ""

# ---------------------------------------------------------------------------
# 8. Interactive README.md backlog review — move items to Réalisées section
# ---------------------------------------------------------------------------
backlog_lines=()
while IFS= read -r line; do
  backlog_lines+=("$line")
done < <(grep -n '\- \[ \]' "$REPO_ROOT/README.md" 2>/dev/null || true)

if [[ ${#backlog_lines[@]} -gt 0 ]]; then
  echo "Backlog items — move to Réalisées? (space-separated numbers, or Enter to skip)"
  for i in "${!backlog_lines[@]}"; do
    label=$(echo "${backlog_lines[$i]}" | sed 's/^[0-9]*:- \[ \] //')
    printf "  %d. %s\n" $((i + 1)) "$label"
  done
  read -r -p "→ " picks

  items_to_add=()
  lines_to_delete=()
  for pick in $picks; do
    idx=$((pick - 1))
    if [[ $idx -ge 0 && $idx -lt ${#backlog_lines[@]} ]]; then
      lineno=$(echo "${backlog_lines[$idx]}" | cut -d: -f1)
      text=$(echo "${backlog_lines[$idx]}" | sed 's/^[0-9]*:- \[ \] //')
      items_to_add+=("$text")
      lines_to_delete+=("$lineno")
      echo "  ✓ Moving to Réalisées: ${text}"
    fi
  done

  if [[ ${#items_to_add[@]} -gt 0 ]]; then
    # Find the --- separator just before the backlog section (= end of Réalisées)
    backlog_header=$(grep -n "En cours" "$REPO_ROOT/README.md" | head -1 | cut -d: -f1)
    insert_before=$(awk -v stop="$backlog_header" 'NR < stop && /^---$/ {sep=NR} END {print sep-1}' "$REPO_ROOT/README.md")

    # Build space-delimited set of line numbers to skip (bash 3.2 compatible)
    skip_lines=" ${lines_to_delete[*]} "

    # Rewrite README: insert moved items just before the separator, remove originals
    tmp_readme=$(mktemp)
    line_num=0
    while IFS= read -r line; do
      line_num=$((line_num + 1))
      if [[ $line_num -eq $insert_before ]]; then
        for text in "${items_to_add[@]}"; do
          printf '%s\n' "- ${text}" >> "$tmp_readme"
        done
      fi
      if [[ "$skip_lines" != *" $line_num "* ]]; then
        printf '%s\n' "$line" >> "$tmp_readme"
      fi
    done < "$REPO_ROOT/README.md"
    mv "$tmp_readme" "$REPO_ROOT/README.md"
  fi
  echo ""
fi

# ---------------------------------------------------------------------------
# 9. Prompt for confirmation
# ---------------------------------------------------------------------------
read -r -p "Proceed with release v${new_version}? [Y/n] " answer
[[ ! "$answer" =~ ^[Nn] ]] || { echo "Aborted."; exit 0; }

# ---------------------------------------------------------------------------
# 9. Generate / prepend CHANGELOG.md
# ---------------------------------------------------------------------------
if [[ -f "$REPO_ROOT/CHANGELOG.md" ]]; then
  git-cliff --tag "v${new_version}" --unreleased --prepend "$REPO_ROOT/CHANGELOG.md"
else
  git-cliff --tag "v${new_version}" --output "$REPO_ROOT/CHANGELOG.md"
fi

# ---------------------------------------------------------------------------
# 10. Update version in hugo.toml
# ---------------------------------------------------------------------------
sed -i '' "s/version = \"${current_version}\"/version = \"${new_version}\"/" "$REPO_ROOT/hugo.toml"

# ---------------------------------------------------------------------------
# 11. Commit and tag (no push — push manually)
# ---------------------------------------------------------------------------
git -C "$REPO_ROOT" add \
  CHANGELOG.md \
  hugo.toml \
  README.md

git -C "$REPO_ROOT" commit -m "chore: release v${new_version}"
git -C "$REPO_ROOT" tag "v${new_version}"

echo ""
echo "✓ Tagged v${new_version} locally. Push with:"
echo "    git push origin main && git push origin v${new_version}"
