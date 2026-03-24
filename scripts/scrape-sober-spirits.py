#!/usr/bin/env python3
"""
Parse les HTML Sober Spirits (dans _sources/sober-spirits/) → fichiers Hugo markdown.

Usage:
    python scripts/scrape-sober-spirits.py           # génère tous les content/recettes/*.md
    python scripts/scrape-sober-spirits.py --dry-run # affiche sans sauvegarder

Dépendances : aucune (stdlib uniquement)
"""

import re
import sys
import argparse
import html as html_lib
from pathlib import Path

ROOT        = Path(__file__).parent.parent
SOURCES_DIR = ROOT / "_sources" / "sober-spirits"
OUTPUT_DIR  = ROOT / "content" / "recettes"

RECIPES = [
    ("mocktail-sober-madeleine",         "sober-madeleine"),
    ("mocktail-sober-italian-mule",      "italian-mule"),
    ("mocktail-sober-bourbon-mule",      "bourbon-mule"),
    ("mocktail-sober-amaretto-sour",     "amaretto-sour"),
    ("mocktail-sober-godfather",         "godfather"),
    ("mocktail-sober-w-apple",           "whisky-apple"),
    ("mocktail-sober-chenonceau",        "chenonceau"),
    ("mocktail-sober-whisky-sour",       "whisky-sour"),
    ("mocktail-sober-whisky-ginger-ale", "whisky-ginger-ale"),
    ("mocktail-sober-clover-club",       "clover-club"),
    ("mocktail-sober-versailles",        "versailles"),
    ("mocktail-sober-jamaican-mule",     "jamaican-mule"),
    ("mocktail-sober-london-mule",       "london-mule"),
    ("mocktail-sober-gin-basil-smash",   "gin-basil-smash"),
    ("mocktail-sober-gin-tonic",         "gin-tonic"),
    ("mocktail-sober-mojito",            "mojito"),
    ("mocktail-sober-cuba-libre",        "cuba-libre"),
    ("mocktail-sober-caipirinha",        "caipirinha"),
    ("mocktail-sober-dark-stormy",       "dark-stormy"),
    ("mocktail-sober-pina-colada",       "pina-colada"),
    ("mocktail-sober-planteur",          "planteur"),
    ("mocktail-sober-daiquiri",          "daiquiri"),
    ("mocktail-sober-mai-tai",           "mai-tai"),
    ("mocktail-sober-orange-spritz",     "orange-spritz"),
]

# ─────────────────────────────────────────────────────────────
# Pattern qui reconnaît le DÉBUT d'un ingrédient
# ─────────────────────────────────────────────────────────────
INGREDIENT_START = re.compile(
    r"""(?x)
    \d+(?:[,.]\d+)*\s*(?:ml|cl|dl|g|kg|l)\b   # mesure : 50 ml, 0,5 cl …
    | \d+\s+(?:demi|blanc|brin|tranche|quartier|feuille|gousse|bouchon|
               giclée|trait|pincée|zeste|morceau|bâton|branche|citron|
               pomme|pêche|fraise|framboise)\b  # count + unité/ingrédient
    | \d+\s+[a-záàâéèêëîïôùûüçœ]               # count + mot minuscule
    | Glaçons?\b                                # Glace / Glaçons
    | (?:Un[e]?|Quelques?)\s+                   # articles indéfinis
    | (?:Tranche|Brin|Zeste|Jus|Sel|Sucre|Sirop|Glace)\b  # mots-clés autonomes
    """,
    re.IGNORECASE,
)


def split_by_starters(text: str) -> list[str]:
    """
    Découpe un texte en ingrédients en détectant les positions de début.
    Ex : '50 ml de Sober Spirits 0,0 % 1 demi-citron pressé 10 ml de sirop Glace'
      → ['50 ml de Sober Spirits 0,0 %', '1 demi-citron pressé', '10 ml de sirop', 'Glace']
    """
    positions = [m.start() for m in INGREDIENT_START.finditer(text)]
    if not positions:
        stripped = text.strip()
        return [stripped] if stripped else []
    parts = []
    for i, start in enumerate(positions):
        end = positions[i + 1] if i + 1 < len(positions) else len(text)
        part = text[start:end].strip()
        if part:
            parts.append(part)
    return parts


def p_to_ingredients(p_inner: str) -> list[str]:
    """
    Transforme le contenu intérieur d'un <p> en liste d'ingrédients.
    Stratégie 1 : utilise les <br> comme séparateurs.
    Stratégie 2 (fallback) : split par détection de début d'ingrédient.
    """
    # 1. Remplacer les <br> par des sauts de ligne
    html = re.sub(r"<br\s*/?>", "\n", p_inner, flags=re.IGNORECASE)
    # 2. Supprimer les autres balises
    text = re.sub(r"<[^>]+>", "", html)
    # 3. Décoder les entités HTML
    text = html_lib.unescape(text)
    # 4. Normaliser les espaces dans chaque ligne
    lines = [re.sub(r"\s+", " ", ln).strip() for ln in text.split("\n")]
    lines = [l for l in lines if l]

    result = []
    for line in lines:
        # Fallback : si la ligne est longue et contient plusieurs patterns de quantité,
        # on essaie de la découper par starters.
        qty_count = len(re.findall(r'\d+\s*(?:ml|cl|g|kg)\b', line, re.IGNORECASE))
        if qty_count > 1 or (qty_count == 0 and len(line) > 60 and INGREDIENT_START.search(line)):
            result.extend(split_by_starters(line))
        else:
            result.append(line)

    return [r for r in result if r]


NOISE_MARKERS = ("display:", "padding:", "margin:", "Panier", "boutique",
                 "navigation", "JavaScript", "@media", "font-family", "color:")


def is_noise(p_inner: str) -> bool:
    return any(m in p_inner for m in NOISE_MARKERS)


def parse_html(html: str, source_slug: str) -> dict:
    # ── Titre ──
    m = re.search(r'<meta property="og:title" content="([^"]+)"', html)
    raw_title = m.group(1) if m else source_slug.replace("-", " ").title()
    title = html_lib.unescape(re.sub(r"<[^>]+>", "", raw_title)).strip()

    # ── Image Shopify CDN ──
    m = re.search(r'src="(//www\.soberspirits\.com/cdn/shop/t/\d+/assets/[^"]+\.webp[^"]*)"', html)
    source_image = ("https:" + m.group(1)) if m else ""

    # ── Blocs <p> ──
    p_tags = re.findall(r"<p[^>]*>(.*?)</p>", html, re.DOTALL)

    ingredients: list[str] = []
    in_block = False
    STOP_WORDS = ("ustensiles", "comment faire", "préparation", "conseils du barman", "les origines")

    for p_inner in p_tags:
        if is_noise(p_inner):
            continue

        plain = re.sub(r"<[^>]+>", " ", p_inner)
        plain = html_lib.unescape(re.sub(r"\s+", " ", plain).strip()).lower()

        if plain == "ingrédients":
            in_block = True
            continue

        if in_block:
            if any(plain.startswith(s) for s in STOP_WORDS):
                break
            if plain in ("", "&nbsp;"):
                continue
            for ing in p_to_ingredients(p_inner):
                ingredients.append(ing)

    return {
        "title": title,
        "source_image": source_image,
        "ingredients": ingredients,
        "source_url": f"https://www.soberspirits.com/fr/pages/{source_slug}",
    }


def to_yaml_str(s: str) -> str:
    needs_quotes = any(c in s for c in ['"', "'", ":", "#", "&", "*", "?", "|", "<", ">", "=", "!", "%", "@", "`"])
    if needs_quotes:
        return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'
    return s


def build_markdown(data: dict, hugo_slug: str) -> str:
    lines = [
        "---",
        f"title: {to_yaml_str(data['title'])}",
        f"slug: {hugo_slug}",
        "draft: false",
    ]
    if data["source_image"]:
        lines.append(f"source_image: {to_yaml_str(data['source_image'])}")
    lines.append(f"source_url: {to_yaml_str(data['source_url'])}")
    lines.append("ingredients:")
    for ing in data["ingredients"]:
        lines.append(f"  - {to_yaml_str(ing)}")
    lines.append("---")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not SOURCES_DIR.exists():
        print(f"Erreur : {SOURCES_DIR} introuvable")
        sys.exit(1)

    if not args.dry_run:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    warnings = []

    for source_slug, hugo_slug in RECIPES:
        html_file = SOURCES_DIR / f"{source_slug}.html"
        if not html_file.exists():
            warnings.append(f"✗ {source_slug}.html introuvable")
            continue

        data = parse_html(html_file.read_text(encoding="utf-8"), source_slug)

        if not data["ingredients"]:
            warnings.append(f"⚠ {hugo_slug} — aucun ingrédient")

        md = build_markdown(data, hugo_slug)

        if args.dry_run:
            print(f"\n{'─' * 50}\n# {hugo_slug}.md\n{md}")
        else:
            (OUTPUT_DIR / f"{hugo_slug}.md").write_text(md, encoding="utf-8")
            print(f"  ✓ {hugo_slug}.md  ({len(data['ingredients'])} ingrédients)")

    if warnings:
        print("\nAvertissements :")
        for w in warnings:
            print(f"  {w}")

    if not args.dry_run:
        print(f"\n{len(RECIPES)} recettes → {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
