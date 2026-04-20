import { test, expect, Page } from '@playwright/test';

const sections = [
  'colors',
  'typography',
  'flavor-pills',
  'fridge-items',
  'buttons',
  'recipe-glass',
  'recipe-card',
  'filter-summary',
  'footer',
  'social-links',
  'glass-icons',
  'recipe-ingredients',
  'recipe-steps',
  'recipe-tips',
  'app-icon',
  'content-card',
  'bordered-list',
];

test.describe('design system', () => {
  test.describe.configure({ mode: 'serial' });

  let page: Page;

  test.beforeAll(async ({ browser }) => {
    page = await browser.newPage();
    await page.goto('/design-system/');
    await page.waitForLoadState('networkidle');
  });

  test.afterAll(async () => {
    await page.close();
  });

  for (const section of sections) {
    test(section, async () => {
      const el = page.locator(`[data-ds="${section}"]`);
      await expect(el).toHaveScreenshot(`${section}.png`);
    });
  }
});
