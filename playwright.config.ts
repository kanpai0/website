import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/visual',
  snapshotDir: './tests/visual/snapshots',
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  use: {
    viewport: { width: 1280, height: 800 },
    baseURL: 'http://localhost:1313',
  },
  webServer: {
    command: 'python3 -m http.server 1313 --directory public',
    port: 1313,
    reuseExistingServer: !process.env.CI,
  },
  expect: {
    toHaveScreenshot: { maxDiffPixelRatio: 0.01 },
  },
});
