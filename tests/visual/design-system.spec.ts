import { test, expect } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/design-system/');
  await page.waitForLoadState('networkidle');
});

const sections = ['colors', 'typography', 'flavor-pills', 'fridge-items', 'buttons', 'recipe-card'];

for (const section of sections) {
  test(section, async ({ page }) => {
    const el = page.locator(`[data-ds="${section}"]`);
    await expect(el).toHaveScreenshot(`${section}.png`);
  });
}
