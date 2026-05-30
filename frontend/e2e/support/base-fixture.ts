// WHY THIS FILE EXISTS: Playwright base fixture that wraps every test with
// automatic axe accessibility checks on each page navigation.
// All Playwright tests MUST use this fixture instead of the base 'test' import.
// Usage: import { test, expect } from '../support/base-fixture';

import { test as base, expect, Page } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

/** Extended Playwright fixture with automatic accessibility checking. */
export const test = base.extend<{
  /** Runs axe on the current page and asserts zero violations. */
  checkA11y: () => Promise<void>;
}>({
  checkA11y: async ({ page }, use) => {
    const check = async (): Promise<void> => {
      const results = await new AxeBuilder({ page })
        .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
        .analyze();

      if (results.violations.length > 0) {
        const violationMessages = results.violations
          .map((v) => `[${v.impact}] ${v.id}: ${v.description}\n  ${v.helpUrl}`)
          .join('\n');
        throw new Error(`Accessibility violations found:\n${violationMessages}`);
      }
    };
    await use(check);
  },
});

export { expect };

/**
 * Navigates to a page and automatically runs an accessibility check.
 * Use this instead of page.goto() in all Playwright tests.
 */
export async function navigateAndCheckA11y(
  page: Page,
  url: string,
  checkA11y: () => Promise<void>
): Promise<void> {
  await page.goto(url);
  await checkA11y();
}
