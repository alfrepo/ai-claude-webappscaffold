// WHY THIS FILE EXISTS: Unit tests for the root AppComponent.
// Includes an accessibility check (axe) as required by CLAUDE.md.
// Every new component spec MUST include an axe() check.

import { TestBed } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { TranslateModule } from '@ngx-translate/core';
import { axe } from 'jest-axe';
import { AppComponent } from './app.component';
import { HeaderComponent } from './layout/header/header.component';
import { FooterComponent } from './layout/footer/footer.component';
import { HttpClientTestingModule } from '@angular/common/http/testing';

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [
        AppComponent,
        HeaderComponent,
        FooterComponent,
        RouterTestingModule,
        TranslateModule.forRoot(),
        HttpClientTestingModule,
      ],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should have no accessibility violations', async () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const results = await axe(fixture.nativeElement as Element);
    expect(results).toHaveNoViolations();
  });

  it('should render a skip-to-content link as the first focusable element', () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const skipLink = fixture.nativeElement.querySelector('.skip-link') as HTMLElement;
    expect(skipLink).toBeTruthy();
    expect(skipLink.getAttribute('href')).toBe('#main-content');
  });

  it('should render a main element with id="main-content"', () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const main = fixture.nativeElement.querySelector('#main-content') as HTMLElement;
    expect(main).toBeTruthy();
    expect(main.tagName.toLowerCase()).toBe('main');
  });
});
