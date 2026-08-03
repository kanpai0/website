import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

new vm.Script(readFileSync('src/static/js/fridge.js', 'utf8')).runInThisContext();
const {
  parseDataList,
  hasRequiredIngredients,
  matchesActiveFlavors,
  isCardVisible,
  parseStoredFridge,
  parseStoredFlavors,
} = globalThis;

describe('parseDataList', () => {
  it('splits a space-separated string into an array', () => {
    assert.deepEqual(parseDataList('rhum citron-vert menthe'), ['rhum', 'citron-vert', 'menthe']);
  });
  it('returns empty array for empty string', () => {
    assert.deepEqual(parseDataList(''), []);
  });
  it('returns empty array for undefined', () => {
    assert.deepEqual(parseDataList(undefined), []);
  });
  it('filters out extra spaces', () => {
    assert.deepEqual(parseDataList('rhum  menthe'), ['rhum', 'menthe']);
  });
});

describe('hasRequiredIngredients', () => {
  it('returns true when fridgeNeeded is empty', () => {
    assert.equal(hasRequiredIngredients([], ['rhum']), true);
  });
  it('returns true when all required ingredients are available', () => {
    assert.equal(hasRequiredIngredients(['rhum', 'menthe'], ['rhum', 'menthe', 'citron-vert']), true);
  });
  it('returns false when one ingredient is missing', () => {
    assert.equal(hasRequiredIngredients(['rhum', 'menthe'], ['rhum']), false);
  });
  it('returns false when available is empty and fridgeNeeded is not', () => {
    assert.equal(hasRequiredIngredients(['rhum'], []), false);
  });
});

describe('matchesActiveFlavors', () => {
  it('returns true when no flavors are active', () => {
    assert.equal(matchesActiveFlavors(['fruity', 'tart'], []), true);
  });
  it('returns true when card has all active flavors', () => {
    assert.equal(matchesActiveFlavors(['fruity', 'tart', 'sparkling'], ['fruity', 'tart']), true);
  });
  it('returns false when card is missing one active flavor', () => {
    assert.equal(matchesActiveFlavors(['fruity'], ['fruity', 'tart']), false);
  });
  it('returns false when card has no flavors and a filter is active', () => {
    assert.equal(matchesActiveFlavors([], ['fruity']), false);
  });
});

describe('isCardVisible', () => {
  it('returns true when both fridge and flavor conditions are met', () => {
    assert.equal(isCardVisible(['rhum'], ['fruity'], ['rhum'], ['fruity']), true);
  });
  it('returns false when fridge condition fails', () => {
    assert.equal(isCardVisible(['rhum', 'menthe'], ['fruity'], ['rhum'], ['fruity']), false);
  });
  it('returns false when flavor condition fails', () => {
    assert.equal(isCardVisible(['rhum'], ['fruity'], ['rhum'], ['tart']), false);
  });
  it('returns true with no filters active and all ingredients available', () => {
    assert.equal(isCardVisible(['rhum'], [], ['rhum'], []), true);
  });
  it('returns true when fridgeNeeded is empty and no flavor filter', () => {
    assert.equal(isCardVisible([], [], [], []), true);
  });
});

// Parse-at-the-frontier hardening: localStorage is user-writable and can be
// corrupted (manual edit, old app version, extension interference). Neither
// function may ever throw — a `JSON.parse` on invalid data used to crash
// init() outright (uncaught exception on page load = no filtering at all,
// not even the default state).
describe('parseStoredFridge', () => {
  const validIds = ['rhum', 'menthe', 'citron-vert'];

  it('defaults when raw is null (first visit / absent key)', () => {
    assert.deepEqual(parseStoredFridge(null, validIds), { kind: 'default' });
  });

  it('defaults on invalid JSON instead of throwing', () => {
    assert.deepEqual(parseStoredFridge('{not valid json', validIds), { kind: 'default' });
  });

  it('defaults when the parsed value is valid JSON but not an array ("{}")', () => {
    assert.deepEqual(parseStoredFridge('{}', validIds), { kind: 'default' });
  });

  it('defaults when the array contains non-string entries ("[1,2]")', () => {
    assert.deepEqual(parseStoredFridge('[1,2]', validIds), { kind: 'default' });
  });

  it('drops stale slugs no longer in validIds', () => {
    assert.deepEqual(parseStoredFridge('["rhum", "licorne", "menthe"]', validIds), {
      kind: 'selection',
      ids: ['rhum', 'menthe'],
    });
  });

  it('returns a selection unchanged when every slug is valid', () => {
    assert.deepEqual(parseStoredFridge('["rhum", "menthe"]', validIds), {
      kind: 'selection',
      ids: ['rhum', 'menthe'],
    });
  });

  it('returns an empty selection (not default) when every slug was stale', () => {
    assert.deepEqual(parseStoredFridge('["licorne"]', validIds), { kind: 'selection', ids: [] });
  });
});

describe('parseStoredFlavors', () => {
  const validIds = ['sparkling', 'tart', 'sweet'];

  it('returns [] when raw is null (first visit / absent key)', () => {
    assert.deepEqual(parseStoredFlavors(null, validIds), []);
  });

  it('returns [] on invalid JSON instead of throwing', () => {
    assert.deepEqual(parseStoredFlavors('{not valid json', validIds), []);
  });

  it('returns [] when the parsed value is valid JSON but not an array ("{}")', () => {
    assert.deepEqual(parseStoredFlavors('{}', validIds), []);
  });

  it('returns [] when the array contains non-string entries ("[1,2]")', () => {
    assert.deepEqual(parseStoredFlavors('[1,2]', validIds), []);
  });

  it('drops stale flavors no longer in validIds', () => {
    assert.deepEqual(parseStoredFlavors('["tart", "umami"]', validIds), ['tart']);
  });

  it('returns the selection unchanged when every flavor is valid', () => {
    assert.deepEqual(parseStoredFlavors('["sparkling", "tart"]', validIds), ['sparkling', 'tart']);
  });
});
