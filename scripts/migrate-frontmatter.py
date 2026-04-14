#!/usr/bin/env python3
"""
Migrate recipe frontmatter to structured ingredient and step format.

ingredients: ["50 ml de Rhum..."]
→ ingredients:
     - name: "Rhum..."
       qty: "50 ml"

steps: ["Versez...le verre. Ajoutez plus de glace."]
→ steps:
     - title: "Versez...le verre"
       text: "Ajoutez plus de glace."

Usage:
  python3 scripts/migrate-frontmatter.py            # dry-run
  python3 scripts/migrate-frontmatter.py --write    # apply
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
RECIPES = ROOT / "content" / "recettes"
DRY_RUN = "--write" not in sys.argv

# ── Ingredient parsing ────────────────────────────────────────────────────────

# Pattern 1: "50 ml de Rhum..." / "10 ml d'agave..."
_RE_QTY_DE = re.compile(
    r'^([\d½¼¾][\d\s,./-]*(?:\s*(?:ml|cl|g|kg|l))?)\s+(?:de |d\')(.+)$',
    re.IGNORECASE
)
# Pattern 2: "1 demi-citron..." / "3-4 glaçons" (number then name, no unit/de)
_RE_QTY_PLAIN = re.compile(
    r'^([\d½¼¾][\d,./-]*)\s+([A-Za-zÀ-ÿ].+)$'
)

def parse_ingredient(raw: str) -> tuple[str, str]:
    """Return (name, qty). qty is '' if not parseable."""
    raw = raw.strip()
    m = _RE_QTY_DE.match(raw)
    if m:
        return m.group(2).strip(), m.group(1).strip()
    m = _RE_QTY_PLAIN.match(raw)
    if m:
        return m.group(2).strip(), m.group(1).strip()
    return raw, ""


# ── Step parsing ──────────────────────────────────────────────────────────────

def parse_step(raw: str) -> tuple[str, str]:
    """Split at first '. ' to get (title, remaining_text)."""
    parts = raw.split(". ", 1)
    title = parts[0].rstrip(".")
    text = parts[1] if len(parts) > 1 else ""
    return title, text


# ── YAML helpers ─────────────────────────────────────────────────────────────

def _qs(s: str) -> str:
    """Double-quote a YAML string value, escaping internal quotes."""
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


def format_ingredients(items: list[tuple[str, str]]) -> str:
    lines = []
    for name, qty in items:
        lines.append(f'  - name: {_qs(name)}')
        lines.append(f'    qty: {_qs(qty)}')
    return "\n".join(lines)


def format_steps(items: list[tuple[str, str]]) -> str:
    lines = []
    for title, text in items:
        lines.append(f'  - title: {_qs(title)}')
        lines.append(f'    text: {_qs(text)}')
    return "\n".join(lines)


# ── Frontmatter patching ──────────────────────────────────────────────────────

def extract_yaml_list(fm: str, key: str) -> list[str]:
    """Extract a simple YAML list from frontmatter text."""
    pattern = rf'^{key}:\n((?:  - .*\n?)+)'
    m = re.search(pattern, fm, re.MULTILINE)
    if not m:
        return []
    block = m.group(1)
    items = re.findall(r'^  - (.+)$', block, re.MULTILINE)
    return [i.strip().strip('"') for i in items]


def remove_yaml_key(fm: str, key: str) -> str:
    """Remove a YAML key (scalar or list) from frontmatter."""
    fm = re.sub(rf'^{key}: .*\n', '', fm, flags=re.MULTILINE)
    fm = re.sub(rf'^{key}:\n(  - .*\n?)*', '', fm, flags=re.MULTILINE)
    return fm


def patch_frontmatter(md_text: str) -> tuple[str, bool]:
    """
    Returns (patched_text, changed).
    Skips files already using structured format (ingredients have 'name:' key).
    """
    m = re.match(r'^---\n(.*?)\n---\n?(.*)', md_text, re.DOTALL)
    if not m:
        return md_text, False
    fm, body = m.group(1), m.group(2)

    # Already migrated?
    if re.search(r'^    name:', fm, re.MULTILINE) or re.search(r'^    qty:', fm, re.MULTILINE):
        return md_text, False

    # Parse existing lists
    raw_ings  = extract_yaml_list(fm, 'ingredients')
    raw_steps = extract_yaml_list(fm, 'steps')

    if not raw_ings and not raw_steps:
        return md_text, False

    # Remove old keys
    fm = remove_yaml_key(fm, 'ingredients')
    fm = remove_yaml_key(fm, 'steps')
    fm = fm.rstrip('\n')

    # Rebuild with structured format
    if raw_ings:
        parsed_ings = [parse_ingredient(r) for r in raw_ings]
        fm += '\ningredients:\n' + format_ingredients(parsed_ings)

    if raw_steps:
        parsed_steps = [parse_step(r) for r in raw_steps]
        fm += '\nsteps:\n' + format_steps(parsed_steps)

    return f"---\n{fm}\n---\n{body}", True


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    print(f"Mode: {'DRY-RUN (pass --write to apply)' if DRY_RUN else 'WRITING'}\n")
    changed = 0
    for md_path in sorted(RECIPES.glob("*.md")):
        text = md_path.read_text(encoding='utf-8')
        patched, did_change = patch_frontmatter(text)
        status = "CHANGE" if did_change else "skip  "
        print(f"  {status}  {md_path.name}")
        if did_change and not DRY_RUN:
            md_path.write_text(patched, encoding='utf-8')
        changed += did_change
    print(f"\nDone: {changed}/24 files would change.")


if __name__ == '__main__':
    main()
