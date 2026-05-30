// WHY THIS FILE EXISTS: Application header component.
// Contains the site title/logo and primary navigation.
// All text must use TranslatePipe — no hardcoded strings (CLAUDE.md rule).
// The aria-label is set explicitly because PrimeNG defaults are not reliable.

import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslateModule } from '@ngx-translate/core';

/**
 * Application header component.
 * Renders the site title and primary navigation.
 * Extend this component to add navigation items as features are added.
 */
@Component({
  selector: 'app-header',
  standalone: true,
  imports: [TranslateModule],
  templateUrl: './header.component.html',
  styleUrl: './header.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderComponent {}
