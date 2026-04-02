import { createBdd } from 'playwright-bdd';
import { expect } from '@playwright/test';

const { When, Then } = createBdd();

When('I select the flavor {string}', async ({ page }, flavor: string) => {
  await page.evaluate((id) => {
    const el = document.getElementById(id) as HTMLInputElement;
    el.checked = true;
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }, `fl-${flavor}`);
});

When('I deselect the flavor {string}', async ({ page }, flavor: string) => {
  await page.evaluate((id) => {
    const el = document.getElementById(id) as HTMLInputElement;
    el.checked = false;
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }, `fl-${flavor}`);
});

Then('all recipe cards are visible', async ({ page }) => {
  const hidden = page.locator('.recipe-card.fridge-hidden');
  await expect(hidden).toHaveCount(0);
});

Then('only recipes tagged {string} are visible', async ({ page }, flavor: string) => {
  const visibleCards = page.locator('.recipe-card:not(.fridge-hidden)');
  const count = await visibleCards.count();
  expect(count).toBeGreaterThan(0);
  for (let i = 0; i < count; i++) {
    const card = visibleCards.nth(i);
    const flavors = await card.getAttribute('data-flavors') ?? '';
    expect(flavors.split(' ')).toContain(flavor);
  }
  // Cards without the flavor must be hidden
  const allCards = page.locator('.recipe-card');
  const total = await allCards.count();
  for (let i = 0; i < total; i++) {
    const card = allCards.nth(i);
    const flavors = (await card.getAttribute('data-flavors') ?? '').split(' ');
    const isHidden = await card.evaluate(el => el.classList.contains('fridge-hidden'));
    if (!flavors.includes(flavor)) {
      expect(isHidden).toBe(true);
    }
  }
});

Then('only recipes tagged with both {string} and {string} are visible', async ({ page }, flavor1: string, flavor2: string) => {
  const visibleCards = page.locator('.recipe-card:not(.fridge-hidden)');
  const count = await visibleCards.count();
  for (let i = 0; i < count; i++) {
    const card = visibleCards.nth(i);
    const flavors = (await card.getAttribute('data-flavors') ?? '').split(' ');
    expect(flavors).toContain(flavor1);
    expect(flavors).toContain(flavor2);
  }
  const allCards = page.locator('.recipe-card');
  const total = await allCards.count();
  for (let i = 0; i < total; i++) {
    const card = allCards.nth(i);
    const flavors = (await card.getAttribute('data-flavors') ?? '').split(' ');
    const isHidden = await card.evaluate(el => el.classList.contains('fridge-hidden'));
    if (!flavors.includes(flavor1) || !flavors.includes(flavor2)) {
      expect(isHidden).toBe(true);
    }
  }
});
