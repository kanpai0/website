// scripts/lib/frontmatter.mjs — PURE library, no IO, no yq dependency. Owns
// recipe *shape* and *semantic* validation only. YAML front-matter
// extraction is yq's job (tier-2 pinned binary — see .mise.toml), invoked by
// the check-content.mjs CLI (the IO shell) which then hands the parsed
// value to this lib.
//
// Why yq and not a hand-rolled parser: Vincent's tooling doctrine ranks
// POSIX > standalone binary > ecosystem. yq (mikefarah, single static Go
// binary) has native `--front-matter=extract` support and is a real YAML
// parser, so this lib no longer needs to reinvent one. An earlier lot did
// carry a hand-rolled grammar here (retired — see git history) built to
// fix the historical orange-spritz last-item bug; yq being a real parser
// makes that whole class of bug structurally impossible without a
// bespoke grammar to maintain.
//
// Covered directly by tests/unit/frontmatter.test.mjs (pure, yq-free — the
// yq integration point is check-content.mjs itself, exercised against the
// real content/recettes/*.md files by `make validate`).

/**
 * @typedef {{ ok: true, data: Record<string, unknown> }} ShapeOk
 * @typedef {{ ok: false, message: string }} ShapeErr
 */

/**
 * Confirms a yq-extracted, JSON.parse'd value is actually a YAML mapping
 * (plain object) — the only shape validateRecipe can work with. yq itself
 * has no concept of "this isn't front-matter": a file with no "---" block
 * at all, an empty "---\n---\n" block, or a top-level scalar/array all
 * yq-parse successfully (as a string, null, or array respectively) instead
 * of failing inside yq. This is that missing check, done once, at the
 * frontier, before any field is read.
 * @param {unknown} value
 * @returns {ShapeOk | ShapeErr}
 */
export function assertRecipeShape(value) {
  if (value === null) {
    return { ok: false, message: 'no frontmatter found (file has no "---" block, or it is empty)' };
  }
  if (Array.isArray(value)) {
    return { ok: false, message: 'no frontmatter found (top-level YAML value is an array, not a mapping)' };
  }
  if (typeof value !== 'object') {
    return {
      ok: false,
      message: `no frontmatter found (top-level YAML value is a ${typeof value}, not a mapping)`,
    };
  }
  return { ok: true, data: value };
}

/**
 * @typedef {{
 *   iconSlugs: string[],
 *   panelSlugs: string[],
 *   flavorSlugs: string[],
 *   glassIds: string[],
 *   colorNames: string[],
 * }} RecipeRefs
 */

const REQUIRED_FIELDS = ['title', 'slug', 'fridge', 'flavors', 'glass', 'color', 'source_image', 'source_url'];

/**
 * Pure semantic validation of already-parsed frontmatter data against the
 * site's cross-reference sets. Returns a flat list of `{ field, message }`
 * violations (empty array = valid). `field` names the top-level frontmatter
 * key the violation is about (never null/undefined) so the CLI can point
 * back at the line that key was declared on — see check-content.mjs.
 * @param {Record<string, unknown>} data
 * @param {RecipeRefs} refs
 * @param {string} filename e.g. "mojito.md"
 * @returns {{ field: string, message: string }[]}
 */
export function validateRecipe(data, refs, filename) {
  const errors = [];
  const flag = (field, message) => errors.push({ field, message });

  for (const field of REQUIRED_FIELDS) {
    const value = data[field];
    const missing = !(field in data) || (typeof value === 'string' && value.trim() === '');
    if (missing) flag(field, `missing required field "${field}"`);
  }

  const stem = filename.replace(/\.md$/, '');
  if (typeof data.slug === 'string' && data.slug !== stem) {
    flag('slug', `slug "${data.slug}" does not match filename "${stem}"`);
  }

  if ('draft' in data && typeof data.draft !== 'boolean') {
    flag('draft', `"draft" must be a boolean (true/false), got ${JSON.stringify(data.draft)}`);
  }

  if ('fridge' in data) {
    if (!Array.isArray(data.fridge)) {
      flag('fridge', '"fridge" must be an array');
    } else if (data.fridge.length === 0) {
      flag('fridge', '"fridge" must not be empty');
    } else {
      for (const slug of data.fridge) {
        if (!refs.iconSlugs.includes(slug)) {
          flag('fridge', `unknown fridge slug "${slug}" (no id="fi-${slug}" in fridge-icons.html)`);
        } else if (!refs.panelSlugs.includes(slug)) {
          flag(
            'fridge',
            `fridge slug "${slug}" has an icon but no id="fr-${slug}" input in fridge-panel-body.html`,
          );
        }
      }
    }
  }

  if ('flavors' in data) {
    if (!Array.isArray(data.flavors)) {
      flag('flavors', '"flavors" must be an array');
    } else if (data.flavors.length === 0) {
      flag('flavors', '"flavors" must not be empty');
    } else {
      for (const flavor of data.flavors) {
        if (!refs.flavorSlugs.includes(flavor)) {
          flag('flavors', `unknown flavor "${flavor}" (not in the FLAVORS constant)`);
        }
      }
    }
  }

  if ('glass' in data) {
    if (typeof data.glass !== 'string') {
      flag('glass', '"glass" must be a string');
    } else if (!refs.glassIds.includes(data.glass)) {
      flag('glass', `unknown glass "${data.glass}" (no matching $type in glass-icon.html)`);
    }
  }

  if ('color' in data) {
    if (typeof data.color !== 'string') {
      flag('color', '"color" must be a string');
    } else if (!refs.colorNames.includes(data.color)) {
      flag('color', `unknown color "${data.color}" (no body.${data.color} { --accent } rule in main.css)`);
    }
  }

  return errors;
}
