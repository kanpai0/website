import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { assertRecipeShape, validateRecipe } from '../../tools/lib/frontmatter.mjs';

// Pure functions only — this file has no external front-matter-extraction
// tool dependency. That extraction step is exercised only through
// tools/check-content.mjs, against the real src/content/recettes/*.md files,
// as part of `make validate`.

const REFS = {
  iconSlugs: ['rhum', 'citron-vert', 'agave', 'menthe', 'petillante', 'ghost-icon'],
  panelSlugs: ['rhum', 'citron-vert', 'agave', 'menthe', 'petillante'],
  flavorSlugs: ['sparkling', 'herbaceous', 'tart', 'still', 'sweet'],
  glassIds: ['rocks', 'coupette', 'highball'],
  colorNames: ['green', 'gold', 'orange', 'pink'],
};

describe('assertRecipeShape', () => {
  it('accepts a plain object', () => {
    const result = assertRecipeShape({ title: 'Mojito' });
    assert.equal(result.ok, true);
    assert.deepEqual(result.data, { title: 'Mojito' });
  });

  it('rejects null (empty or missing frontmatter block)', () => {
    const result = assertRecipeShape(null);
    assert.equal(result.ok, false);
    assert.match(result.message, /no frontmatter found/);
  });

  it('rejects an array', () => {
    const result = assertRecipeShape(['a', 'b']);
    assert.equal(result.ok, false);
    assert.match(result.message, /no frontmatter found/);
    assert.match(result.message, /array/);
  });

  it('rejects a scalar (e.g. a file with no "---" block at all)', () => {
    const result = assertRecipeShape('just some text');
    assert.equal(result.ok, false);
    assert.match(result.message, /no frontmatter found/);
    assert.match(result.message, /string/);
  });
});

describe('validateRecipe — happy path', () => {
  const validData = {
    title: 'Mojito',
    slug: 'mojito',
    fridge: ['rhum', 'menthe'],
    flavors: ['sparkling', 'tart'],
    glass: 'rocks',
    color: 'green',
    source_image: 'https://example.com/x.webp',
    source_url: 'https://example.com/x',
  };

  it('returns no errors for a fully valid recipe', () => {
    assert.deepEqual(validateRecipe(validData, REFS, 'mojito.md'), []);
  });
});

describe('validateRecipe — one violation per rule', () => {
  const base = {
    title: 'Mojito',
    slug: 'mojito',
    fridge: ['rhum', 'menthe'],
    flavors: ['sparkling', 'tart'],
    glass: 'rocks',
    color: 'green',
    source_image: 'https://example.com/x.webp',
    source_url: 'https://example.com/x',
  };

  it('flags an unknown fridge slug', () => {
    const errors = validateRecipe({ ...base, fridge: ['rhum', 'licorne'] }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('unknown fridge slug "licorne"')));
  });

  it('flags a fridge slug that has an icon but no panel input', () => {
    // 'ghost-icon' is in REFS.iconSlugs but deliberately absent from
    // REFS.panelSlugs — this is the "icon exists, panel input doesn't"
    // case that a plain icon-only check would miss.
    const errors = validateRecipe({ ...base, fridge: ['ghost-icon'] }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('has an icon but no id="fr-ghost-icon"')));
  });

  it('flags an unknown flavor', () => {
    const errors = validateRecipe({ ...base, flavors: ['umami'] }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('unknown flavor "umami"')));
  });

  it('flags an unknown glass', () => {
    const errors = validateRecipe({ ...base, glass: 'goblet' }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('unknown glass "goblet"')));
  });

  it('flags an unknown color', () => {
    const errors = validateRecipe({ ...base, color: 'ultraviolet' }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('unknown color "ultraviolet"')));
  });

  it('flags a missing required field', () => {
    const { source_url, ...rest } = base;
    const errors = validateRecipe(rest, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('missing required field "source_url"')));
  });

  it('flags slug not matching the filename', () => {
    const errors = validateRecipe({ ...base, slug: 'not-mojito' }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('does not match filename "mojito"')));
  });

  it('flags a non-boolean draft', () => {
    const errors = validateRecipe({ ...base, draft: 'yes' }, REFS, 'mojito.md');
    assert.ok(errors.some((e) => e.message.includes('"draft" must be a boolean')));
  });
});
