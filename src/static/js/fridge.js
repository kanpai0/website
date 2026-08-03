// — Pure logic — no DOM access, fully unit-testable

function parseDataList(str) {
  return (str || '').split(' ').filter(Boolean);
}

function hasRequiredIngredients(fridgeNeeded, availableIngredients) {
  return fridgeNeeded.every(ingredient => availableIngredients.includes(ingredient));
}

function matchesActiveFlavors(cardFlavors, activeFlavors) {
  return activeFlavors.length === 0 || activeFlavors.every(f => cardFlavors.includes(f));
}

function isCardVisible(fridgeNeeded, cardFlavors, availableIngredients, activeFlavors) {
  return hasRequiredIngredients(fridgeNeeded, availableIngredients)
    && matchesActiveFlavors(cardFlavors, activeFlavors);
}

// Parse the raw localStorage.fridge value ONCE, at the frontier (called
// from init(), below). NEVER throws: anything that isn't "a JSON array of
// strings" — absent, invalid JSON, not an array, non-string entries — is
// the 'default' case (all ingredients checked), same as a first visit.
// Stale slugs (no longer in validIds) are dropped from a valid selection.
function parseStoredFridge(raw, validIds) {
  if (typeof raw !== 'string') return { kind: 'default' };
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return { kind: 'default' };
  }
  if (!Array.isArray(parsed) || !parsed.every(id => typeof id === 'string')) {
    return { kind: 'default' };
  }
  return { kind: 'selection', ids: parsed.filter(id => validIds.includes(id)) };
}

// Parse the raw localStorage.flavors value ONCE, at the frontier. NEVER
// throws: anything that isn't "a JSON array of strings" defaults to no
// active flavors (same as a first visit). Stale flavors are dropped.
function parseStoredFlavors(raw, validIds) {
  if (typeof raw !== 'string') return [];
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return [];
  }
  if (!Array.isArray(parsed) || !parsed.every(f => typeof f === 'string')) {
    return [];
  }
  return parsed.filter(f => validIds.includes(f));
}


// — DOM queries — read only

function getActiveIngredients() {
  return FRIDGE.filter(id => document.getElementById('fr-' + id)?.checked);
}

function getActiveFlavors() {
  return FLAVORS.filter(f => document.getElementById('fl-' + f)?.checked);
}


// — DOM updates — write only

function updateCardVisibility(card, availableIngredients, activeFlavors) {
  const fridgeNeeded = parseDataList(card.dataset.fridge);
  const cardFlavors  = parseDataList(card.dataset.flavors);
  const visible = isCardVisible(fridgeNeeded, cardFlavors, availableIngredients, activeFlavors);
  card.classList.toggle('fridge-hidden', !visible);
  card.setAttribute('aria-hidden', String(!visible));
}

function updateFilterSummary() {
  const hiddenCount = document.querySelectorAll('.recipe-card.fridge-hidden').length;
  const summary = document.getElementById('filter-summary');
  summary.hidden = hiddenCount === 0;
  document.getElementById('filter-summary-count').textContent = hiddenCount;
}

function applyFilters() {
  const availableIngredients = getActiveIngredients();
  const activeFlavors = getActiveFlavors();
  document.querySelectorAll('.recipe-card')
    .forEach(card => updateCardVisibility(card, availableIngredients, activeFlavors));
  updateFilterSummary();
}


// — Persistence
//
// loadFridge/loadFlavors are pure IO: they hand back whatever raw string
// (or null) is in localStorage, unparsed. Parsing happens once, at the
// frontier, in init() below — see parseStoredFridge/parseStoredFlavors.

function loadFridge() {
  return localStorage.getItem('fridge');
}

function saveFridge() {
  localStorage.setItem('fridge', JSON.stringify(getActiveIngredients()));
  applyFilters();
}

function loadFlavors() {
  return localStorage.getItem('flavors');
}

function saveFlavors() {
  localStorage.setItem('flavors', JSON.stringify(getActiveFlavors()));
  applyFilters();
}


// — Init

function init() {
  const fridgeResult = parseStoredFridge(loadFridge(), FRIDGE);
  FRIDGE.forEach(id => {
    const el = document.getElementById('fr-' + id);
    if (!el) return;
    el.checked = fridgeResult.kind === 'default' ? true : fridgeResult.ids.includes(id);
    el.addEventListener('change', saveFridge);
  });

  parseStoredFlavors(loadFlavors(), FLAVORS).forEach(f => {
    const el = document.getElementById('fl-' + f);
    if (el) el.checked = true;
  });
  document.querySelectorAll('.flavor-cb').forEach(cb => {
    cb.addEventListener('change', saveFlavors);
  });

  const fridgeCb    = document.getElementById('fridge-open');
  const fridgePanel = document.getElementById('fridge-panel');
  const fridgeBtn   = document.getElementById('fridge-btn');
  fridgeCb.addEventListener('change', function syncFridgeAria() {
    const open = fridgeCb.checked;
    fridgePanel.setAttribute('aria-hidden', String(!open));
    fridgeBtn.setAttribute('aria-expanded', String(open));
    if (open) {
      const first = fridgePanel.querySelector('input:not([tabindex="-1"]), button, [href]');
      if (first) first.focus();
    } else {
      fridgeBtn.focus();
    }
  });

  applyFilters();
}
