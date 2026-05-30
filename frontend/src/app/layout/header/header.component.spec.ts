// WHY THIS FILE EXISTS: Unit tests for the header component.
// Accessibility check is mandatory (CLAUDE.md rule).

import { TestBed } from '@angular/core/testing';
import { TranslateModule } from '@ngx-translate/core';
import { axe } from 'jest-axe';
import { HeaderComponent } from './header.component';

describe('HeaderComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HeaderComponent, TranslateModule.forRoot()],
    }).compileComponents();
  });

  it('should create', () => {
    const fixture = TestBed.createComponent(HeaderComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('should have no accessibility violations', async () => {
    const fixture = TestBed.createComponent(HeaderComponent);
    fixture.detectChanges();
    const results = await axe(fixture.nativeElement as Element);
    expect(results).toHaveNoViolations();
  });

  it('should render a header element with role banner', () => {
    const fixture = TestBed.createComponent(HeaderComponent);
    fixture.detectChanges();
    const header = fixture.nativeElement.querySelector('header') as HTMLElement;
    expect(header).toBeTruthy();
    expect(header.getAttribute('role')).toBe('banner');
  });
});
