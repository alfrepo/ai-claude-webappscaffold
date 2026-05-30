// WHY THIS FILE EXISTS: Root Angular component — the application shell.
// Contains the skip-to-content link (accessibility), header, main content area, and footer.
// Business features are rendered inside <main> via the router outlet.
// Do not add business logic here — keep this component as a pure layout shell.

import { ChangeDetectionStrategy, Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { HeaderComponent } from './layout/header/header.component';
import { FooterComponent } from './layout/footer/footer.component';

/**
 * Root application shell component.
 * Provides the page structure: skip link, header, main content, footer.
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, TranslateModule, HeaderComponent, FooterComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AppComponent implements OnInit {
  constructor(private readonly translate: TranslateService) {}

  ngOnInit(): void {
    this.translate.setDefaultLang('en');
    this.translate.use('en');
  }
}
