import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

new vm.Script(readFileSync('static/js/fridge.js', 'utf8')).runInThisContext();
const { parseDataList, hasRequiredIngredients, matchesActiveFlavors, isCardVisible } = globalThis;

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
