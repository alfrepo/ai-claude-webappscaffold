// WHY THIS FILE EXISTS: Placeholder home page component.
// Replace this with the first real feature component when development begins.
// Follow the mandatory workflow in CLAUDE.md: Gherkin → tests → implementation.

import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Placeholder home page.
 * Replace with the first real feature per the mandatory workflow in CLAUDE.md.
 */
@Component({
  selector: 'app-home',
  standalone: true,
  imports: [TranslateModule],
  template: `
    <div class="flex align-items-center justify-content-center" style="min-height: 60vh">
      <div class="text-center">
        <h1>{{ 'APP.TITLE' | translate }}</h1>
        <p>{{ 'APP.DESCRIPTION' | translate }}</p>
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HomeComponent {}
