// WHY THIS FILE EXISTS: Cucumber World class that provides shared state
// between step definitions within a scenario. Holds the Playwright page reference.
// To add shared state (e.g., an authenticated session): add a field to AppWorld.

import { IWorldOptions, World, setWorldConstructor } from '@cucumber/cucumber';
import { Browser, BrowserContext, Page, chromium } from '@playwright/test';

/** Shared world state available to all step definitions in a scenario. */
export class AppWorld extends World {
  browser!: Browser;
  context!: BrowserContext;
  page!: Page;

  constructor(options: IWorldOptions) {
    super(options);
  }

  async openBrowser(): Promise<void> {
    this.browser = await chromium.launch({ headless: true });
    this.context = await this.browser.newContext();
    this.page = await this.context.newPage();
  }

  async closeBrowser(): Promise<void> {
    await this.browser?.close();
  }
}

setWorldConstructor(AppWorld);
