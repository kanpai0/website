import { test, expect, Page } from '@playwright/test';

async function waitForFonts(page: Page) {
  await page.waitForFunction(() => document.fonts.ready);
  await page.waitForFunction(() => document.fonts.check('1em Inter'), { timeout: 5000 });
  await page.waitForFunction(() => document.fonts.check('1em "Playfair Display"'), { timeout: 5000 });
}

test.beforeEach(async ({ page }) => {
  await page.goto('/design-system/');
  await page.waitForLoadState('networkidle');
  await waitForFonts(page);
});

const sections = ['colors', 'typography', 'flavor-pills', 'fridge-items', 'buttons', 'recipe-card'];

for (const section of sections) {
  test(section, async ({ page }) => {
    const el = page.locator(`[data-ds="${section}"]`);
    await expect(el).toHaveScreenshot(`${section}.png`);
  });
}
