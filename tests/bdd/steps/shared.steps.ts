import { createBdd } from 'playwright-bdd';

const { Given } = createBdd();

Given('I am on the homepage', async ({ page }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
});

Given('all filters are reset', async ({ page }) => {
  await page.evaluate(() => {
    localStorage.removeItem('fridge');
    localStorage.removeItem('flavors');
  });
  await page.reload();
  await page.waitForLoadState('networkidle');
});

Given('I am on a recipe detail page', async ({ page }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  const firstCard = page.locator('.recipe-card').first();
  await firstCard.click();
  await page.waitForLoadState('networkidle');
});
