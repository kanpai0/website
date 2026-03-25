#!/usr/bin/env bash
# Download the hero image for each recipe from the Sober Spirits CDN.
# Image selection: last CDN webp src appearing before "Comment faire" in each HTML file.
#
# Usage:
#   bash scripts/download-recipe-images.sh
#
# Output: _sources/imgs/<html-filename>.webp  (24 files)

set -euo pipefail

SOURCES_DIR="$(cd "$(dirname "$0")/.." && pwd)/_sources/sober-spirits"
OUTPUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/_sources/imgs"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

mkdir -p "$OUTPUT_DIR"

count=0
errors=0

for html_file in "$SOURCES_DIR"/*.html; do
    name=$(basename "$html_file" .html)

    # Keep only lines before "Comment faire", then grab the last CDN src= (not data-src/srcset)
    src=$(awk '/Comment faire/{exit} {print}' "$html_file" \
        | grep -o ' src="//www\.soberspirits\.com/cdn/shop/[^"]*\.webp[^"]*"' \
        | tail -1 \
        | sed 's/^ src="//;s/"$//')

    if [ -z "$src" ]; then
        echo "✗ image introuvable : $name"
        ((errors++)) || true
        continue
    fi

    url="https:${src}"
    out="${OUTPUT_DIR}/${name}.webp"

    curl -s -L -A "$UA" "$url" -o "$out"
    size=$(wc -c < "$out")
    echo "✓ ${name}.webp  (${size} bytes)"
    ((count++)) || true
done

echo ""
echo "${count} images → ${OUTPUT_DIR}"
if [ "${errors}" -gt 0 ]; then
    echo "${errors} erreurs"
    exit 1
fi
