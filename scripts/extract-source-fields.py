#!/usr/bin/env python3
"""
Extract subtitle, glass type, steps and tips from sources/sober-spirits/ HTML files
and patch the corresponding content/recettes/*.md frontmatter.

Usage:
  python3 scripts/extract-source-fields.py            # dry-run (preview only)
  python3 scripts/extract-source-fields.py --write    # apply changes
"""

import re
import sys
import os
import html as html_module
from pathlib import Path

ROOT = Path(__file__).parent.parent
SOURCES = ROOT / "sources" / "sober-spirits"
RECIPES = ROOT / "content" / "recettes"

DRY_RUN = "--write" not in sys.argv

# data-id anchors (consistent across all source files)
ID_SUBTITLE = "gkJWPKJxhE"   # subtitle tagline (terracotta)
ID_TOOLS    = "grgfrw2dSI"   # tools / glass type
ID_STEPS    = "gbKLgKPFdg"   # preparation steps
ID_TIPS     = "g9B4AXL8n5"   # bartender advice (may be absent)

# Map source filename slug to markdown slug
SLUG_MAP = {
    "w-apple": "whisky-apple",
}

GLASS_MAP = [
    (["boisson courte", "short drink", "old fashioned", "whisky"],   "rocks"),
    (["mule", "cuivre", "copper"],                                    "mule-mug"),
    (["highball", "boisson longue", "long drink"],                    "highball"),
    (["collins"],                                                      "collins"),
    (["coupette", "champagne", "coupe"],                              "coupette"),
    (["martini", "cocktail glass"],                                    "martini"),
    (["margarita"],                                                    "margarita"),
    (["vin", "spritz", "wine"],                                       "vin"),
    (["verre à pied", "pied"],                                        "coupette"),
]


def extract_text_by_id(content: str, data_id: str) -> str:
    """Extract visible text from the element matching data-id="<data_id>"."""
    pattern = rf'data-id="{re.escape(data_id)}".*?<p>(.*?)</p>'
    m = re.search(pattern, content, re.DOTALL)
    if not m:
        return ""
    raw = m.group(1)
    # Take only first line (before <br/>) for glass type
    raw = re.split(r"<br\s*/?>", raw)[0]
    raw = re.sub(r"<[^>]+>", "", raw)
    raw = re.sub(r"\s+", " ", raw).strip()
    return html_module.unescape(raw)


def extract_steps(content: str) -> list[str]:
    """Extract steps as a list of strings, split on &nbsp; paragraph breaks."""
    pattern = rf'data-id="{re.escape(ID_STEPS)}".*?<div[^>]*data-gp-text[^>]*>(.*?)</div>'
    m = re.search(pattern, content, re.DOTALL)
    if not m:
        # fallback: search right after h6>Comment faire
        m = re.search(
            r"Comment faire.*?</h6>.*?<div[^>]*data-gp-text[^>]*>(.*?)</div>",
            content, re.DOTALL
        )
    if not m:
        return []
    raw = m.group(1)
    # Replace paragraph tags with newlines
    raw = re.sub(r"</?p>", "\n", raw)
    raw = re.sub(r"<[^>]+>", "", raw)
    # Split on &nbsp; paragraph separators
    raw = raw.replace("&nbsp;", "\n")
    steps = [re.sub(r"\s+", " ", s).strip() for s in raw.split("\n")]
    return [html_module.unescape(s) for s in steps if len(s) > 8]


def map_glass(raw: str) -> str:
    raw_l = raw.lower()
    for keywords, canonical in GLASS_MAP:
        if any(k in raw_l for k in keywords):
            return canonical
    # Unrecognised value (e.g. "Doseur", "Boisson à base d'alcool") → empty
    return ""


def yaml_str(s: str) -> str:
    """Wrap a string in YAML double quotes, escaping internal quotes."""
    return '"' + s.replace('"', '\\"') + '"'


def yaml_list(items: list[str]) -> str:
    """Format a list of strings as a YAML block sequence."""
    lines = []
    for item in items:
        lines.append('  - ' + yaml_str(item))
    return "\n".join(lines)


def patch_frontmatter(md_text: str, fields: dict) -> str:
    """
    Insert new fields into YAML frontmatter. Idempotent — replaces existing
    keys if they already exist (e.g. re-running the script).
    """
    # Split frontmatter from body
    m = re.match(r"^---\n(.*?)\n---\n?(.*)", md_text, re.DOTALL)
    if not m:
        return md_text
    fm, body = m.group(1), m.group(2)

    # Remove any existing keys we're about to insert
    for key in fields:
        # Remove simple key: value lines
        fm = re.sub(rf"^{key}:.*\n", "", fm, flags=re.MULTILINE)
        # Remove block list key:
        fm = re.sub(rf"^{key}:\n(  - .*\n)*", "", fm, flags=re.MULTILINE)

    fm = fm.rstrip("\n")

    # Append new fields
    additions = []
    if fields.get("subtitle"):
        additions.append(f'subtitle: {yaml_str(fields["subtitle"])}')
    if fields.get("glass"):
        additions.append(f'glass: {yaml_str(fields["glass"])}')
    if fields.get("steps"):
        additions.append(f'steps:\n{yaml_list(fields["steps"])}')
    if fields.get("tips"):
        additions.append(f'tips: {yaml_str(fields["tips"])}')

    new_fm = fm + "\n" + "\n".join(additions)
    return f"---\n{new_fm}\n---\n{body}"


def process_file(html_path: Path) -> bool:
    # Derive markdown slug from HTML filename
    stem = html_path.stem.removeprefix("mocktail-sober-")
    slug = SLUG_MAP.get(stem, stem)
    md_path = RECIPES / f"{slug}.md"

    if not md_path.exists():
        print(f"  SKIP  {html_path.name} → {md_path.name} not found")
        return False

    content = html_path.read_text(encoding="utf-8")
    md_text = md_path.read_text(encoding="utf-8")

    subtitle = extract_text_by_id(content, ID_SUBTITLE)
    glass_raw = extract_text_by_id(content, ID_TOOLS)
    glass = map_glass(glass_raw) if glass_raw else ""
    steps = extract_steps(content)
    tips_raw = extract_text_by_id(content, ID_TIPS)
    tips = html_module.unescape(re.sub(r"\s+", " ", tips_raw).strip())

    fields = {
        "subtitle": subtitle,
        "glass": glass,
        "steps": steps,
        "tips": tips,
    }

    tag = "DRY-RUN" if DRY_RUN else "WRITE  "
    print(f"  {tag}  {slug}")
    print(f"           subtitle : {subtitle!r}")
    print(f"           glass    : {glass!r}  (raw: {glass_raw!r})")
    print(f"           steps    : {len(steps)} steps")
    print(f"           tips     : {'yes' if tips else 'none'}")

    if not DRY_RUN:
        patched = patch_frontmatter(md_text, fields)
        md_path.write_text(patched, encoding="utf-8")

    return True


def main():
    print(f"Mode: {'DRY-RUN (pass --write to apply)' if DRY_RUN else 'WRITING'}\n")
    ok = 0
    for html_path in sorted(SOURCES.glob("mocktail-sober-*.html")):
        if process_file(html_path):
            ok += 1
    print(f"\nDone: {ok}/24 files processed.")


if __name__ == "__main__":
    main()
