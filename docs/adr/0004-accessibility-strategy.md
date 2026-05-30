# ADR-0004: Accessibility Strategy (WCAG 2.1 AA)

**Status:** Accepted  
**Date:** 2026-05-30  
**Deciders:** Platform Team

---

## Context

Accessibility is a legal requirement in many jurisdictions (ADA, Section 508, EN 301 549) and is the right thing to do. PrimeNG, our chosen UI library, provides accessible components but has known gaps in default aria attributes. We need a strategy that makes accessibility failures visible automatically, not something left to manual review.

## Decision

We adopt **automated accessibility enforcement at every test layer**:

### Rule 1: Unit Test Level (jest-axe)

Every Angular component spec MUST include:
```typescript
it('should have no accessibility violations', async () => {
  const fixture = TestBed.createComponent(MyComponent);
  fixture.detectChanges();
  const results = await axe(fixture.nativeElement as Element);
  expect(results).toHaveNoViolations();
});
```
- `jest-axe` runs axe-core against the rendered DOM
- Tests fail if any WCAG AA violations are found
- This catches missing labels, incorrect ARIA roles, and contrast issues

### Rule 2: E2E Test Level (@axe-core/playwright)

The base Playwright fixture (e2e/support/base-fixture.ts) automatically runs axe-core on every page navigation:
```typescript
const results = await new AxeBuilder({ page })
  .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
  .analyze();
expect(results.violations).toEqual([]);
```

### Rule 3: PrimeNG Explicit ARIA Attributes

PrimeNG components MUST have explicit `[ariaLabel]` and `[ariaLabelledBy]` attributes:
```html
<!-- Correct -->
<p-button [ariaLabel]="'SAVE' | translate"></p-button>

<!-- Wrong — PrimeNG default may be empty or generic -->
<p-button></p-button>
```
Enforced by `@angular-eslint/template/accessibility` ESLint rules.

### Rule 4: Skip-to-Content Link

The application shell MUST have a visible-on-focus skip link as the FIRST focusable element:
```html
<a class="skip-link" href="#main-content">Skip to main content</a>
```

### Rule 5: Keyboard Navigation Tests

Every interactive component spec must test keyboard navigation explicitly.

### Rule 6: Color Contrast

- Minimum contrast ratio: 4.5:1 for normal text (WCAG AA)
- Minimum contrast ratio: 3:1 for large text (WCAG AA)
- Verified automatically by axe-core (color-contrast rule)

## Consequences

**Positive:**
- Accessibility regressions are caught in CI before they reach users
- Developers get immediate feedback on accessibility issues during TDD
- Legal compliance is demonstrable through test reports
- The application is usable by people using screen readers, keyboards, and other assistive technologies

**Negative:**
- axe-core cannot catch all accessibility issues (manual testing still needed for complex interactions)
- jest-axe adds ~50ms to each component spec (acceptable)
- Developers must learn ARIA patterns — we mitigate this with examples in CLAUDE.md

**Alternatives Considered:**
- **Manual a11y reviews only:** Rejected — not scalable, regressions are invisible until reported
- **Lighthouse CI only:** Considered as an addition, but axe-core at unit test level gives faster feedback
