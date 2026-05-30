// WHY THIS FILE EXISTS: Unit tests for the home placeholder component.

import { TestBed } from '@angular/core/testing';
import { TranslateModule } from '@ngx-translate/core';
import { axe } from 'jest-axe';
import { HomeComponent } from './home.component';

describe('HomeComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HomeComponent, TranslateModule.forRoot()],
    }).compileComponents();
  });

  it('should create', () => {
    const fixture = TestBed.createComponent(HomeComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('should have no accessibility violations', async () => {
    const fixture = TestBed.createComponent(HomeComponent);
    fixture.detectChanges();
    const results = await axe(fixture.nativeElement as Element);
    expect(results).toHaveNoViolations();
  });
});
