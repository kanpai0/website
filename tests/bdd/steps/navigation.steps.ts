import { createBdd } from 'playwright-bdd';
import { expect } from '@playwright/test';

const { When, Then } = createBdd();

Then('at least one recipe card is visible', async ({ page }) => {
  const visible = page.locator('.recipe-card:not(.fridge-hidden)');
  const count = await visible.count();
  expect(count).toBeGreaterThan(0);
});

When('I click on the first visible recipe', async ({ page }) => {
  await page.locator('.recipe-card').first().click();
  await page.waitForLoadState('networkidle');
});

Then('I should be on a recipe detail page', async ({ page }) => {
  await expect(page).toHaveURL(/\/recettes\//);
});

When('I click the logo {string}', async ({ page }, _text: string) => {
  await page.locator('.site-logo').click();
  await page.waitForLoadState('networkidle');
});

Then('I should be on the homepage', async ({ page }) => {
  await expect(page).toHaveURL(/^http:\/\/localhost:1313\/?$/);
});
