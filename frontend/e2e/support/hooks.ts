// WHY THIS FILE EXISTS: Cucumber global hooks — run before/after every scenario.
// Opens and closes the browser around each scenario for test isolation.
// To add a global setup (e.g., login): add a Before hook here.

import { Before, After, AfterStep, Status } from '@cucumber/cucumber';
import { AppWorld } from './world';

Before(async function (this: AppWorld) {
  await this.openBrowser();
});

After(async function (this: AppWorld, scenario) {
  // Take screenshot on failure for debugging
  if (scenario.result?.status === Status.FAILED) {
    const screenshot = await this.page?.screenshot({ fullPage: true });
    if (screenshot) {
      this.attach(screenshot, 'image/png');
    }
  }
  await this.closeBrowser();
});
