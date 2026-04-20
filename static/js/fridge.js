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

function loadFridge() {
  return JSON.parse(localStorage.getItem('fridge') || 'null');
}

function saveFridge() {
  localStorage.setItem('fridge', JSON.stringify(getActiveIngredients()));
  applyFilters();
}

function loadFlavors() {
  return JSON.parse(localStorage.getItem('flavors') || '[]');
}

function saveFlavors() {
  localStorage.setItem('flavors', JSON.stringify(getActiveFlavors()));
  applyFilters();
}


// — Init

function init() {
  const savedFridge = loadFridge();
  FRIDGE.forEach(id => {
    const el = document.getElementById('fr-' + id);
    if (!el) return;
    el.checked = savedFridge === null ? true : savedFridge.includes(id);
    el.addEventListener('change', saveFridge);
  });

  loadFlavors().forEach(f => {
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
