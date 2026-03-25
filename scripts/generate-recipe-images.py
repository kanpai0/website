#!/usr/bin/env python3
"""
Generate transparent PNG mocktail glass images via gpt-image-1.
Usage:
  python generate-recipe-images.py --dry-run
  python generate-recipe-images.py --slug amaretto-sour
  python generate-recipe-images.py
"""

import argparse
import base64
import os
import time
from pathlib import Path

# ---------------------------------------------------------------------------
# Recipe lookup tables
# ---------------------------------------------------------------------------

GLASS = {
    "amaretto-sour":    "coupe glass",
    "bourbon-mule":     "copper mug",
    "caipirinha":       "rocks glass",
    "chenonceau":       "rocks glass",
    "clover-club":      "coupe glass",
    "cuba-libre":       "highball glass",
    "daiquiri":         "coupe glass",
    "dark-stormy":      "highball glass",
    "gin-basil-smash":  "rocks glass",
    "gin-tonic":        "Copa balloon glass",
    "godfather":        "rocks glass",
    "italian-mule":     "copper mug",
    "jamaican-mule":    "copper mug",
    "london-mule":      "copper mug",
    "mai-tai":          "tiki glass",
    "mojito":           "highball glass",
    "orange-spritz":    "large wine glass",
    "pina-colada":      "hurricane glass",
    "planteur":         "tall highball glass",
    "madeleine":  "coupe glass",
    "versailles":       "coupe glass",
    "whisky-apple":     "rocks glass",
    "whisky-ginger-ale":"highball glass",
    "whisky-sour":      "coupe glass",
}

DRINK = {
    "amaretto-sour":    "pale amber liquid with a white foam cap",
    "bourbon-mule":     "iced amber drink",
    "caipirinha":       "crushed ice with pale citrus liquid",
    "chenonceau":       "pale amber liquid over ice",
    "clover-club":      "bright pink liquid with a white foam top",
    "cuba-libre":       "dark cola with ice cubes",
    "daiquiri":         "pale yellow-green liquid",
    "dark-stormy":      "dark ginger beer with ice, layered amber on top",
    "gin-basil-smash":  "pale green liquid over ice",
    "gin-tonic":        "clear sparkling tonic water with ice",
    "godfather":        "amber liquid over a large single ice cube",
    "italian-mule":     "iced amber drink",
    "jamaican-mule":    "iced golden-amber drink",
    "london-mule":      "iced pale drink",
    "madeleine":        "golden pineapple-citrus liquid",
    "mai-tai":          "golden amber tropical drink",
    "mojito":           "pale sparkling liquid with crushed ice and mint leaves",
    "orange-spritz":    "sparkling orange-amber liquid with ice",
    "pina-colada":      "creamy white tropical drink",
    "planteur":         "layered tropical drink from orange to deep red, with ice",
    "versailles":       "deep crimson hibiscus liquid with a white foam top",
    "whisky-apple":     "golden amber liquid",
    "whisky-ginger-ale":"golden amber liquid with ice",
    "whisky-sour":      "amber liquid with a thick white foam cap",
}

GARNISH = {
    "amaretto-sour":    "a lemon peel twist",
    "bourbon-mule":     "a lime wedge and a mint sprig",
    "caipirinha":       "lime quarters on the rim",
    "chenonceau":       "a cinnamon stick and ice",
    "clover-club":      "three fresh raspberries",
    "cuba-libre":       "a lime wedge",
    "daiquiri":         "",
    "dark-stormy":      "a lime wedge",
    "gin-basil-smash":  "a fresh basil leaf",
    "gin-tonic":        "a cucumber slice and a basil sprig",
    "godfather":        "an orange slice and a black cherry",
    "italian-mule":     "a lime wedge and a mint sprig",
    "jamaican-mule":    "a lime wedge and a mint sprig",
    "london-mule":      "a lime wedge and a mint sprig",
    "madeleine":        "a lime wheel",
    "mai-tai":          "a lime wheel",
    "mojito":           "a lime wedge",
    "orange-spritz":    "an orange slice",
    "pina-colada":      "a pineapple wedge",
    "planteur":         "",
    "versailles":       "a lime wheel",
    "whisky-apple":     "a cinnamon stick and a fan of apple slices",
    "whisky-ginger-ale":"a dried lemon slice",
    "whisky-sour":      "a lemon wheel",
}

PROMPT_TEMPLATE = """\
A single {glass} filled with {drink}{garnish_clause}. \
Clean 3D render, isolated object, transparent background, centered, \
soft diffuse lighting, slightly above eye level. \
No table, no floor, no bottle, no props, no people, no camera, no shadows on background. Absolutely nothing other than the cocktail. \
"""

OUTPUT_DIR = Path(__file__).parent.parent / "static" / "images" / "recettes"
RATE_LIMIT_SLEEP = 13  # seconds between API calls (max 5/min)


def build_prompt(slug: str) -> str:
    garnish = GARNISH[slug]
    garnish_clause = f", garnished with {garnish}" if garnish else ""
    return PROMPT_TEMPLATE.format(
        glass=GLASS[slug],
        drink=DRINK[slug],
        garnish_clause=garnish_clause,
    )


def generate_image(client, slug: str) -> None:
    out_path = OUTPUT_DIR / f"{slug}.png"
    if out_path.exists():
        print(f"  [skip] {slug}.png already exists")
        return

    prompt = build_prompt(slug)
    print(f"  [gen]  {slug}")

    try:
        response = client.images.generate(
            model="gpt-image-1",
            prompt=prompt,
            size="1024x1024",
            quality="medium",
            n=1,
            background="transparent",
        )
        image_data = base64.b64decode(response.data[0].b64_json)
    except Exception as e:
        # Fallback: dall-e-3 with URL + PIL white-to-alpha
        print(f"  [warn] gpt-image-1 failed ({e}), trying dall-e-3 fallback…")
        image_data = _dalle3_fallback(client, slug, prompt)

    out_path.write_bytes(image_data)
    print(f"  [ok]   saved → {out_path.relative_to(Path(__file__).parent.parent)}")


def _dalle3_fallback(client, slug: str, prompt: str) -> bytes:
    """dall-e-3 URL response + PIL white-to-alpha post-processing."""
    try:
        from PIL import Image
        import io
        import urllib.request
    except ImportError:
        raise SystemExit("PIL not installed. Run: pip install Pillow")

    response = client.images.generate(
        model="dall-e-3",
        prompt=prompt,
        size="1024x1024",
        quality="standard",
        n=1,
        response_format="url",
    )
    url = response.data[0].url
    with urllib.request.urlopen(url) as r:
        raw = r.read()

    import numpy as np
    img = Image.open(io.BytesIO(raw)).convert("RGBA")
    data = np.array(img)
    # Make near-white pixels transparent
    mask = (data[:, :, 0] > 230) & (data[:, :, 1] > 230) & (data[:, :, 2] > 230)
    data[mask, 3] = 0
    img = Image.fromarray(data, "RGBA")

    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def main():
    parser = argparse.ArgumentParser(description="Generate transparent mocktail images")
    parser.add_argument("--dry-run", action="store_true", help="Print prompts, no API calls")
    parser.add_argument("--slug", help="Generate only this slug")
    args = parser.parse_args()

    slugs = [args.slug] if args.slug else sorted(GLASS.keys())

    if args.dry_run:
        for slug in slugs:
            print(f"\n--- {slug} ---")
            print(build_prompt(slug))
        return

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise SystemExit("OPENAI_API_KEY environment variable not set")

    try:
        from openai import OpenAI
    except ImportError:
        raise SystemExit("openai not installed. Run: pip install openai")

    client = OpenAI(api_key=api_key)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for i, slug in enumerate(slugs):
        already_exists = (OUTPUT_DIR / f"{slug}.png").exists()
        generate_image(client, slug)
        if i < len(slugs) - 1 and not already_exists:
            time.sleep(RATE_LIMIT_SLEEP)

    print(f"\nDone. {len(slugs)} image(s) processed.")


if __name__ == "__main__":
    main()
