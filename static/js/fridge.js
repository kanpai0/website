function getActiveIngredients() {
  return FRIDGE.filter(id => document.getElementById('fr-' + id)?.checked);
}

function getActiveFlavors() {
  return FLAVORS.filter(f => document.getElementById('fl-' + f)?.checked);
}

function updateCardVisibility(card, available, active) {
  const needed = (card.dataset.fridge || '').split(' ').filter(Boolean);
  const fridgeOk = needed.every(ing => available.includes(ing));
  const cardFlavors = (card.dataset.flavors || '').split(' ').filter(Boolean);
  const flavorOk = active.length === 0 || active.every(f => cardFlavors.includes(f));
  const visible = fridgeOk && flavorOk;
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
  const available = getActiveIngredients();
  const active = getActiveFlavors();
  document.querySelectorAll('.recipe-card').forEach(card => updateCardVisibility(card, available, active));
  updateFilterSummary();
}

function saveFridge() {
  localStorage.setItem('fridge', JSON.stringify(getActiveIngredients()));
  applyFilters();
}

function saveFlavors() {
  localStorage.setItem('flavors', JSON.stringify(getActiveFlavors()));
  applyFilters();
}

const savedFridge = JSON.parse(localStorage.getItem('fridge') || 'null');

FRIDGE.forEach(id => {
  const el = document.getElementById('fr-' + id);
  if (!el) return;
  el.checked = savedFridge === null ? true : savedFridge.includes(id);
  el.addEventListener('change', saveFridge);
});

JSON.parse(localStorage.getItem('flavors') || '[]').forEach(f => {
  const el = document.getElementById('fl-' + f);
  if (el) el.checked = true;
});

document.querySelectorAll('.flavor-cb').forEach(cb => {
  cb.addEventListener('change', saveFlavors);
});

applyFilters();

const fridgeCb = document.getElementById('fridge-open');
const fridgePanel = document.getElementById('fridge-panel');
const fridgeBtn = document.getElementById('fridge-btn');

function syncFridgeAria() {
  const open = fridgeCb.checked;
  fridgePanel.setAttribute('aria-hidden', String(!open));
  fridgeBtn.setAttribute('aria-expanded', String(open));
  if (open) {
    const first = fridgePanel.querySelector('input:not([tabindex="-1"]), button, [href]');
    if (first) first.focus();
  } else {
    fridgeBtn.focus();
  }
}

fridgeCb.addEventListener('change', syncFridgeAria);
