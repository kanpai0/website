import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';

const BDD_OUTPUT_DIR = 'tests/.generated';

defineBddConfig({
  features: 'tests/bdd/features/**/*.feature',
  steps: 'tests/bdd/steps/**/*.ts',
  outputDir: BDD_OUTPUT_DIR,
});

export default defineConfig({
  fullyParallel: true,
  reporter: 'dot',
  snapshotDir: './tests/visual/snapshots',
  use: {
    baseURL: 'http://localhost:1313',
  },
  webServer: {
    command: 'python3 -m http.server 1313 --directory public 2>/dev/null',
    port: 1313,
    reuseExistingServer: !process.env.CI,
  },
  expect: {
    toHaveScreenshot: { maxDiffPixelRatio: 0.01 },
  },
  projects: [
    {
      name: 'visual',
      testDir: './tests/visual',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } },
    },
    {
      name: 'bdd-mobile',
      testDir: BDD_OUTPUT_DIR,
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'bdd-desktop',
      testDir: BDD_OUTPUT_DIR,
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
