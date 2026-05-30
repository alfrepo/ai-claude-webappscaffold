// WHY THIS FILE EXISTS: Playwright configuration for E2E and Cucumber BDD tests.
// All E2E tests run against a locally started frontend+backend stack (docker-compose).
// @axe-core/playwright is wired into the base fixture (see e2e/support/base-fixture.ts)
// so every page navigation automatically runs an accessibility check.
// allure-playwright writes results to allure-results/ for the CI 'allure:generate' job.
// To add a new browser: add it to the 'projects' array below.

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  testMatch: ['**/*.spec.ts', '**/*.steps.ts'],
  fullyParallel: false,
  forbidOnly: !!process.env['CI'],
  retries: process.env['CI'] ? 2 : 0,
  workers: process.env['CI'] ? 1 : undefined,
  // Reporters: Allure (mandatory dashboard) + JUnit (GitLab MR widget) + list (console)
  reporter: [
    ['list'],
    [
      'allure-playwright',
      {
        // Results consumed by 'allure:generate' script and CI allure:generate job
        resultsDir: 'allure-results',
        detail: true,
        suiteTitle: false,
      },
    ],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['junit', { outputFile: 'playwright-report/results.xml' }],
  ],
  use: {
    baseURL: process.env['PLAYWRIGHT_BASE_URL'] ?? 'http://localhost:4200',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  // Local dev: start the docker-compose stack before tests
  // In CI: docker-compose is started by the .gitlab-ci.yml e2e job
  webServer: process.env['CI']
    ? undefined
    : {
        command: 'docker compose up --build -d',
        url: 'http://localhost:4200',
        reuseExistingServer: true,
        timeout: 120_000,
      },
});
