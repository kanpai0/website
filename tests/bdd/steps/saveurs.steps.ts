import { createBdd } from 'playwright-bdd';
import { expect } from '@playwright/test';

const { When, Then } = createBdd();

When('I select the flavor {string}', async ({ page }, flavor: string) => {
  // Native checkbox is display:none — users toggle via the visible flavor pill <label>.
  const checkbox = page.locator(`#fl-${flavor}`);
  if (!(await checkbox.isChecked())) {
    await page.locator(`label[for="fl-${flavor}"]`).click();
  }
});

When('I deselect the flavor {string}', async ({ page }, flavor: string) => {
  const checkbox = page.locator(`#fl-${flavor}`);
  if (await checkbox.isChecked()) {
    await page.locator(`label[for="fl-${flavor}"]`).click();
  }
});

Then('all recipe cards are visible', async ({ page }) => {
  await expect(page.locator('.recipe-card.fridge-hidden')).toHaveCount(0);
});

Then('only recipes tagged {string} are visible', async ({ page }, flavor: string) => {
  // Visible == has-flavor: no visible card may lack the flavor.
  await expect(
    page.locator(`.recipe-card:not(.fridge-hidden):not([data-flavors~="${flavor}"])`),
  ).toHaveCount(0);
  // And the filter must actually leave at least one card visible.
  expect(await page.locator('.recipe-card:not(.fridge-hidden)').count()).toBeGreaterThan(0);
});

Then(
  'only recipes tagged with both {string} and {string} are visible',
  async ({ page }, flavor1: string, flavor2: string) => {
    await expect(
      page.locator(`.recipe-card:not(.fridge-hidden):not([data-flavors~="${flavor1}"])`),
    ).toHaveCount(0);
    await expect(
      page.locator(`.recipe-card:not(.fridge-hidden):not([data-flavors~="${flavor2}"])`),
    ).toHaveCount(0);
  },
);