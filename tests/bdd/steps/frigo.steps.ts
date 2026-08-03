import { createBdd } from 'playwright-bdd';
import { expect } from '@playwright/test';

const { Given, When, Then } = createBdd();

// Corrupted-localStorage fixtures — parse-at-the-frontier hardening of
// src/static/js/fridge.js (see tests/unit/fridge-logic.test.mjs for the
// unit-level coverage of parseStoredFridge). Seeded via page.evaluate then
// a reload, same idiom as "all filters are reset" in shared.steps.ts, so
// the corrupted value is already in place when init() runs on load.
Given('the fridge localStorage contains invalid JSON', async ({ page }) => {
  await page.evaluate(() => localStorage.setItem('fridge', '{not valid json'));
  await page.reload();
  await page.waitForLoadState('networkidle');
});

Given('the fridge localStorage contains stale slugs', async ({ page }) => {
  await page.evaluate(() =>
    localStorage.setItem('fridge', JSON.stringify(['rhum', 'citron-vert', 'agave', 'licorne'])),
  );
  await page.reload();
  await page.waitForLoadState('networkidle');
});

When('I open the fridge panel', async ({ page }) => {
  await page.locator('.fridge-btn').click();
});

When('I close the fridge panel', async ({ page }) => {
  await page.locator('.fridge-panel__close').click();
});

When('I uncheck the ingredient {string}', async ({ page }, ingredient: string) => {
  // Native checkbox is display:none — users toggle via the visible <label>.
  const checkbox = page.locator(`#fr-${ingredient}`);
  if (await checkbox.isChecked()) {
    await page.locator(`label[for="fr-${ingredient}"]`).click();
  }
});

Then('the fridge panel is visible', async ({ page }) => {
  await expect(page.locator('#fridge-panel')).toHaveAttribute('aria-hidden', 'false');
});

Then('the fridge panel is hidden', async ({ page }) => {
  await expect(page.locator('#fridge-panel')).toHaveAttribute('aria-hidden', 'true');
});

Then('recipes requiring {string} are hidden', async ({ page }, ingredient: string) => {
  await expect(
    page.locator(`.recipe-card:not(.fridge-hidden)[data-fridge~="${ingredient}"]`),
  ).toHaveCount(0);
});

Then('no visible recipe requires {string}', async ({ page }, ingredient: string) => {
  await expect(
    page.locator(`.recipe-card:not(.fridge-hidden)[data-fridge~="${ingredient}"]`),
  ).toHaveCount(0);
});

Then('the filter summary is hidden', async ({ page }) => {
  await expect(page.locator('#filter-summary')).toBeHidden();
});

Then('the filter summary shows the count of hidden recipes', async ({ page }) => {
  const hiddenCount = await page.locator('.recipe-card.fridge-hidden').count();
  await expect(page.locator('#filter-summary')).toBeVisible();
  await expect(page.locator('#filter-summary-count')).toHaveText(String(hiddenCount));
});

Then('no visible recipe lacks the flavor {string}', async ({ page }, flavor: string) => {
  await expect(
    page.locator(`.recipe-card:not(.fridge-hidden):not([data-flavors~="${flavor}"])`),
  ).toHaveCount(0);
});

Then('the recipe {string} is visible', async ({ page }, slug: string) => {
  await expect(page.locator(`.recipe-card[href="/recettes/${slug}/"]`)).not.toHaveClass(
    /fridge-hidden/,
  );
});

Then('the recipe {string} is hidden', async ({ page }, slug: string) => {
  await expect(page.locator(`.recipe-card[href="/recettes/${slug}/"]`)).toHaveClass(/fridge-hidden/);
});