// WHY THIS FILE EXISTS: Step definitions for the application shell feature.
// Each step maps a Gherkin phrase to Playwright actions/assertions.
// Steps use business language — no technical implementation details in step text.

import { Given, Then } from '@cucumber/cucumber';
import AxeBuilder from '@axe-core/playwright';
import { AppWorld } from '../../support/world';
import { expect } from '@playwright/test';

const BASE_URL = process.env['PLAYWRIGHT_BASE_URL'] ?? 'http://localhost:4200';

Given('I open the application home page', async function (this: AppWorld) {
  await this.page.goto(BASE_URL);
  await this.page.waitForLoadState('networkidle');
});

Then('the page should have a skip to main content link', async function (this: AppWorld) {
  const skipLink = this.page.locator('.skip-link');
  await expect(skipLink).toBeAttached();
  const href = await skipLink.getAttribute('href');
  expect(href).toBe('#main-content');
});

Then('the page should have a header', async function (this: AppWorld) {
  await expect(this.page.locator('header[role="banner"]')).toBeVisible();
});

Then('the page should have a main content area', async function (this: AppWorld) {
  await expect(this.page.locator('main#main-content')).toBeVisible();
});

Then('the page should have a footer', async function (this: AppWorld) {
  await expect(this.page.locator('footer[role="contentinfo"]')).toBeVisible();
});

Then('the page should have no accessibility violations', async function (this: AppWorld) {
  const results = await new AxeBuilder({ page: this.page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
    .analyze();

  expect(results.violations).toHaveLength(0);
});
