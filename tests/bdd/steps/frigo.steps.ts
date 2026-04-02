import { createBdd } from 'playwright-bdd';
import { expect } from '@playwright/test';

const { When, Then } = createBdd();

When('I open the fridge panel', async ({ page }) => {
  await page.locator('.fridge-btn').click();
  // Wait for ARIA state to reflect open
  await expect(page.locator('#fridge-panel')).toHaveAttribute('aria-hidden', 'false');
});

When('I close the fridge panel', async ({ page }) => {
  await page.locator('.fridge-panel__close').click();
  await expect(page.locator('#fridge-panel')).toHaveAttribute('aria-hidden', 'true');
});

When('I uncheck the ingredient {string}', async ({ page }, ingredient: string) => {
  await page.evaluate((id) => {
    const el = document.getElementById(id) as HTMLInputElement;
    el.checked = false;
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }, `fr-${ingredient}`);
});

Then('the fridge panel is visible', async ({ page }) => {
  await expect(page.locator('#fridge-panel')).toHaveAttribute('aria-hidden', 'false');
});

Then('the fridge panel is hidden', async ({ page }) => {
  await expect(page.locator('#fridge-panel')).toHaveAttribute('aria-hidden', 'true');
});

Then('recipes requiring {string} are hidden', async ({ page }, ingredient: string) => {
  const allCards = page.locator('.recipe-card');
  const total = await allCards.count();
  for (let i = 0; i < total; i++) {
    const card = allCards.nth(i);
    const fridge = (await card.getAttribute('data-fridge') ?? '').split(' ');
    if (fridge.includes(ingredient)) {
      await expect(card).toHaveClass(/fridge-hidden/);
    }
  }
});

Then('no visible recipe requires {string}', async ({ page }, ingredient: string) => {
  const visibleCards = page.locator('.recipe-card:not(.fridge-hidden)');
  const count = await visibleCards.count();
  for (let i = 0; i < count; i++) {
    const card = visibleCards.nth(i);
    const fridge = (await card.getAttribute('data-fridge') ?? '').split(' ');
    expect(fridge).not.toContain(ingredient);
  }
});

Then('no visible recipe lacks the flavor {string}', async ({ page }, flavor: string) => {
  const visibleCards = page.locator('.recipe-card:not(.fridge-hidden)');
  const count = await visibleCards.count();
  for (let i = 0; i < count; i++) {
    const card = visibleCards.nth(i);
    const flavors = (await card.getAttribute('data-flavors') ?? '').split(' ');
    expect(flavors).toContain(flavor);
  }
});

