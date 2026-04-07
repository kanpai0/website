import { test, expect } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/design-system/');
  await page.waitForLoadState('networkidle');
});

const sections = [
  'colors',
  'typography',
  'flavor-pills',
  'fridge-items',
  'buttons',
  'site-back',
  'recipe-glass',
  'recipe-card',
  'footer',
  'glass-icons',
  'recipe-ingredients',
  'recipe-steps',
  'recipe-tips',
];

for (const section of sections) {
  test(section, async ({ page }) => {
    const el = page.locator(`[data-ds="${section}"]`);
    await expect(el).toHaveScreenshot(`${section}.png`);
  });
}
