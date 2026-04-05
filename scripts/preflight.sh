#!/usr/bin/env bash
# Full local quality gate — run before pushing or releasing.
# Usage: bash scripts/preflight.sh
#        make preflight
#
# Note: fridge schema (A) and hugo build (B) are already guaranteed by the
# pre-commit hook on every commit. This script covers what the hook skips:
#
#   E. npm test — visual regression + BDD suite (requires Docker, ~60s)
#
# Ends with a reminder to complete manual checklist items (C, D, F, G).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo ""
echo "==============================="
echo "  Kanpai Ø — preflight check"
echo "==============================="

# ---------------------------------------------------------------------------
# E. npm test (visual regression + BDD)
# ---------------------------------------------------------------------------
echo ""
echo "[ E ] npm test (visual + BDD)"
cd "$REPO_ROOT"
if ! npm test 2>&1; then
  echo ""
  echo "  ✗ npm test failed — fix before pushing."
  exit 1
fi
echo "  ✓ npm test passed"

# ---------------------------------------------------------------------------
# Manual checklist reminder
# ---------------------------------------------------------------------------
echo ""
echo "==============================="
echo "  ✓ Automated checks passed"
echo "==============================="
echo ""
echo "Manual checklist — verify before pushing:"
echo ""
echo "  [ C ] ARIA labels on new interactive elements?"
echo "        SVG icons decorative → aria-hidden=\"true\"?"
echo "        Focus styles intact?"
echo ""
echo "  [ D ] New CSS token → added to :root in main.css?"
echo "        Visual change → npm run test:update + commit baselines?"
echo ""
echo "  [ F ] CLAUDE.md updated (architecture/commands/tokens changed)?"
echo "        README backlog current?"
echo ""
echo "  [ G ] New recipes: source_image + source_url set?"
echo "        External assets: license verified?"
echo ""
echo "See QUALITY_CHECKLIST.md for full details."
echo ""
