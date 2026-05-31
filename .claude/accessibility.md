# Accessibility Requirements (BITV 2.0 / WCAG 2.1 Level AA)

All Angular GUI code generated or modified in this project must satisfy the following
functional requirements. These are audit-ready obligations, not optional guidelines.

---

## 1. Perceivability — Visual Presentation

- All text shall have minimum contrast ratio **4.5:1**; large text (18 pt / 14 pt bold) **3:1**.
- Non-text elements (icons, controls, focus indicators) shall have minimum contrast **3:1**.
- The application shall support and respect OS/browser high-contrast mode automatically.
- Information shall never rely solely on colour (use text, icons, or patterns in addition).
- Text shall be resizable to **200%** without loss of functionality.
- Content shall remain fully usable at **400% zoom** (responsive reflow) without horizontal scrolling.
- Layout shall not break when font size, line height, letter spacing, or zoom changes.
- Images of text shall not be used unless technically essential.
- Backgrounds shall not reduce readability (no interfering patterns or gradients behind text).
- UI states (error, success, selected, disabled) shall be perceivable independently of colour.

---

## 2. High Contrast & Theming

- The UI shall respect `prefers-contrast: more` and Windows High Contrast / Forced Colours.
- All visual states (hover, focus, active, disabled) shall remain distinguishable in high-contrast mode.
- CSS shall use theme variables or `currentColor`, not hard-coded colour values.
- Focus indicators shall always be visible and have sufficient contrast against their background.
- Icons and inline SVGs shall adapt to forced-colour modes (use `currentColor` for strokes/fills).

---

## 3. Keyboard Accessibility

- All functionality shall be fully operable by keyboard alone.
- No feature shall require mouse or touch interaction.
- Every interactive element shall be reachable via `Tab` / `Shift+Tab`.
- Tab order shall follow a logical, visually consistent sequence.
- No keyboard traps shall exist; users shall always be able to move focus freely.
- Users shall be able to exit any component using standard keys (`Escape`, `Tab`).
- Custom components shall implement standard keyboard patterns:
  - Lists / menus: arrow keys for navigation
  - Toggles / checkboxes: `Space`
  - Activation: `Enter` or `Space`
  - Dismissal: `Escape`
- Keyboard shortcuts shall not conflict with assistive technology shortcuts and shall be avoidable or remappable.

---

## 4. Focus Management

- Focus shall always be visible and clearly distinguishable (never suppressed with `outline: none` without a replacement).
- Focus shall not be lost during Angular route transitions or dynamic content updates.
- When a dialog or overlay opens, focus shall move into it.
- When a dialog closes, focus shall return to the triggering element.
- Modal dialogs shall trap focus within themselves until closed.
- Hidden, disabled, or visually absent elements shall not receive focus (`display: none`, `visibility: hidden`, or `inert` as appropriate).
- Focus shall not be obscured by sticky headers, overlays, or floating elements.

---

## 5. Screen Reader Compatibility — Structure & Semantics

- Semantic HTML elements shall be used wherever possible (`<button>`, `<nav>`, `<main>`, `<header>`, `<footer>`, `<section>`, `<article>`, `<ul>`, `<table>`).
- Page landmarks shall always be present: `<header>`, `<nav>`, `<main>`, `<footer>`.
- Landmark regions shall be labelled when more than one of the same type exists (`aria-label` / `aria-labelledby`).
- Lists, tables, and groups shall use correct structural elements with appropriate roles.
- Headings shall follow a logical, non-skipping hierarchy (`h1 → h2 → h3`).
- Decorative elements shall be hidden from assistive technologies (`aria-hidden="true"`).

---

## 6. Labels & Accessible Names

- Every interactive element shall have a programmatically determinable accessible name.
- Every form field shall have a visible `<label>` associated via `for`/`id`, or `aria-label` / `aria-labelledby`.
- Labels shall clearly and uniquely describe the purpose of the field.
- Placeholder text shall never substitute for a label.
- Non-decorative images shall have meaningful `alt` text; decorative images shall have `alt=""`.
- Icon-only buttons shall carry an accessible name (`aria-label`, visually hidden text, or `title`).
- Groups of related controls (radio groups, checkbox groups) shall be wrapped in `<fieldset>` / `<legend>` or equivalent ARIA grouping.

---

## 7. Screen Reader Interaction & Announcements

- Dynamic content updates (toast messages, loading states, search results) shall be announced via `aria-live` regions (`aria-live="polite"` or `role="status"` for non-urgent; `role="alert"` for critical).
- Expanding/collapsing elements shall expose `aria-expanded` and `aria-controls`.
- Angular route changes shall update the document `<title>` and/or announce the new page via a live region.
- Context changes shall not occur without user awareness or initiation.
- Progress indicators and async operations shall be announced when complete.

---

## 8. Forms & Input Assistance

- All form fields shall have labels and, where necessary, visible instructions.
- Required fields shall be programmatically indicated (`required`, `aria-required="true"`) and marked visually.
- Error messages shall be:
  - Described in clear text (not only colour or icon)
  - Programmatically associated with the input (`aria-describedby`)
  - Announced automatically when they appear (via `aria-live` or focus transfer)
- Users shall be able to review their input and correct errors before final submission.
- `autocomplete` attributes shall be applied to standard fields (name, email, address, password).
- Validation shall never rely on colour alone.

---

## 9. Error Prevention (Critical Actions)

- Destructive or irreversible operations (delete, revoke, submit) shall require explicit confirmation before execution.
- Where technically feasible, submitted data shall be reversible (undo) or correctable.
- Users shall be able to review data before final, irreversible submission.

---

## 10. Navigation & Consistency

- Navigation patterns shall be consistent across all pages and views.
- Repeated UI elements (headers, sidebars, toolbars) shall appear in the same location on every page.
- Identical actions shall use identical labels throughout the application.
- A visible skip link to the main content shall be provided as the first focusable element.
- Navigation mechanisms shall be predictable and not cause unexpected context changes.

---

## 11. Timing & Control

- Where time limits exist, users shall be able to pause, stop, or extend them.
- Auto-refresh, auto-redirect, or auto-advancing content shall be controllable by the user.
- Time-dependent interactions shall not disadvantage users who require more time.

---

## 12. Motion & Animation

- The UI shall respect `prefers-reduced-motion: reduce` and disable or minimise animations accordingly.
- Animations shall not flash more than three times per second.
- Moving, blinking, or scrolling content lasting more than five seconds shall be pausable or stoppable.

---

## 13. Pointer & Touch Accessibility

- Interactive target size shall be sufficient (minimum **24×24 CSS px**; recommended **44×44 CSS px** for primary actions).
- Functionality shall not rely on complex gestures (multi-touch, path-based swipe).
- All drag-and-drop interactions shall have a keyboard or single-pointer alternative.
- Pointer actions shall not require precision beyond reasonable limits.

---

## 14. Language & Text

- The primary language shall be declared on the `<html>` element (`lang="en"` or appropriate locale).
- Language switches within content shall be identified with `lang` attributes on the relevant element.
- Abbreviations and unusual terms shall be either expanded inline or made available programmatically.
- Text content shall be understandable; avoid unnecessarily complex language.

---

## 15. Layout & Reflow

- Content shall reflow and remain usable on viewports equivalent to **320 CSS px** width.
- No loss of functionality or content shall occur at high zoom levels.
- Horizontal scrolling shall not be required except for content where two-dimensional layout is essential (e.g., data tables, maps, charts).

---

## 16. Accessible Authentication

- Authentication shall not rely solely on cognitive puzzles, memorisation, or tests that disadvantage users with cognitive disabilities.
- Password fields shall support paste and a show/hide toggle.
- Multi-factor authentication shall provide accessible, alternative delivery mechanisms.

---

## 17. Angular-Specific Component Behaviour

- Custom Angular components wrapping native elements shall preserve full accessibility semantics.
- Native interactive elements (`<button>`, `<input>`, `<select>`) shall not be replaced with `<div>` or `<span>` without full ARIA role, state, and keyboard equivalence.
- Custom widgets shall implement correct ARIA roles, properties, and keyboard interaction patterns per the [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/).
- Lazy-loaded and dynamically injected content shall be announced correctly and not disrupt focus or screen reader position.
- Angular change detection and re-renders shall not silently move, destroy, or reset focus.
- Route changes shall update `document.title` to reflect the current view and set a `routeAnnouncement` property bound to a `role="status" aria-live="polite"` region in the shell template.

### PrimeNG-Specific Implementation Rules

**`<p-button>` — icon-only accessible name:**
Use the `ariaLabel` component input, not the `aria-label` HTML attribute. The `aria-label` attribute applied to `<p-button>` lands on the Angular host element, not on the inner `<button>`, and is therefore ignored by assistive technologies.

```html
<!-- Correct: ariaLabel input sets aria-label on the inner <button> -->
<p-button icon="pi pi-refresh" ariaLabel="Refresh list"></p-button>
<p-button icon="pi pi-trash" [ariaLabel]="'Delete ' + item.name"></p-button>

<!-- Wrong: aria-label is on the host <p-button> element, not the <button> -->
<p-button icon="pi pi-refresh" aria-label="Refresh list"></p-button>
```

**PrimeNG form controls — label association:**
PrimeNG wrapper components (`p-dropdown`, `p-calendar`, `p-password`, `p-inputnumber`) render an inner `<input>` with a generated id. Use the `inputId` attribute to set a known id, then associate the `<label>` with `for`:

```html
<label for="customer-select">Customer *</label>
<p-dropdown inputId="customer-select" formControlName="customerId" ...></p-dropdown>

<label for="valid-from">Valid From *</label>
<p-calendar inputId="valid-from" formControlName="validFrom" ...></p-calendar>

<label for="login-password">Password *</label>
<p-password inputId="login-password" formControlName="password" ...></p-password>
```

**`p-tag` — status badge text contrast:**
PrimeNG's Lara Light theme renders `severity="success"` and `severity="danger"` with white text on green/red backgrounds. Measured contrast ratios: 2.28:1 (green) and 3.76:1 (red) — both FAIL WCAG AA 4.5:1 for normal text. Apply a global override in `styles.scss`:

```scss
.p-tag-success,
.p-tag-danger {
  color: var(--color-primary) !important;  /* 7.49:1 on green, 4.53:1 on red */
}
```

**`p-dialog` — dynamic header:**
When a dialog title is dynamic (e.g. includes a slot name), use `[header]` binding instead of the `header` string attribute to ensure the dialog's accessible name updates correctly:

```html
<p-dialog [header]="'Upload Key — ' + selectedSlot" ...>
```

**Shell structure — required pattern:**
Every shell component must implement the following structure for skip navigation, landmarks, and route announcements:

```html
<a class="skip-link" href="#main-content">Skip to main content</a>
<div role="status" aria-live="polite" aria-atomic="true" class="visually-hidden">{{ routeAnnouncement }}</div>
<aside aria-label="Application sidebar">
  <nav aria-label="Main navigation"> ... </nav>
</aside>
<main id="main-content" tabindex="-1"> ... </main>
```

And in the shell TypeScript, on each `NavigationEnd`:
```typescript
document.title = `${pageTitle} — App Name`;
this.routeAnnouncement = pageTitle;
```

---

## 18. Compatibility with Assistive Technologies

- The application shall be fully operable with:
  - Screen readers: NVDA + Firefox, JAWS + Chrome, VoiceOver + Safari
  - Keyboard-only navigation
  - Switch access and voice control
- The DOM shall expose all accessibility information required by assistive technologies at all times.
- No feature shall rely on device-specific interaction models (e.g., hover-only, touch-only).

---

## 19. Testing & Verification

- Every component and critical user workflow shall be verifiable via:
  - Automated tools (axe-core, Lighthouse accessibility audit)
  - Manual keyboard-only navigation test
  - Screen reader walkthrough (NVDA or VoiceOver)
- Accessibility defects blocking a critical workflow (create license, validate, key management) are blocking issues and shall be resolved before merge.

---

## 20. Verified Color Contrast (computed values)

The following contrasts have been verified against WCAG 2.1 SC 1.4.3 (text) and SC 1.4.11 (non-text):

| Foreground | Background | Ratio | SC | Status |
|---|---|---|---|---|
| `#1A1A2E` (primary) | `#FFFFFF` | 17.06:1 | 1.4.3 | ✓ Pass |
| `#1A1A2E` (primary) | `#F4F4F6` | 15.49:1 | 1.4.3 | ✓ Pass |
| `#636D77` (muted) | `#FFFFFF` | 5.17:1 | 1.4.3 | ✓ Pass |
| `#636D77` (muted) | `#F4F4F6` | 4.80:1 | 1.4.3 | ✓ Pass |
| `#1A1A2E` on `#22C55E` badge | — | 7.49:1 | 1.4.3 | ✓ Pass |
| `#1A1A2E` on `#EF4444` badge | — | 4.53:1 | 1.4.3 | ✓ Pass |
| `#767B84` border | `#FFFFFF` | 3.92:1 | 1.4.11 | ✓ Pass |
| `#767B84` border | `#F4F4F6` | 3.57:1 | 1.4.11 | ✓ Pass |
| `#E87722` (accent/focus) | `#FFFFFF` | 3.12:1 | 1.4.11 | ✓ Pass (non-text only) |
| `#FFFFFF` on `#1A1A2E` (sidebar) | — | 17.06:1 | 1.4.3 | ✓ Pass |
| **`#FFFFFF` on `#22C55E`** | — | **2.28:1** | 1.4.3 | **✗ Fail — fixed by dark text override** |
| **`#FFFFFF` on `#EF4444`** | — | **3.76:1** | 1.4.3 | **✗ Fail — fixed by dark text override** |
| **`#6B7280` on `#F4F4F6`** | — | **4.40:1** | 1.4.3 | **✗ Fail — replaced by `#636D77`** |
| **`#E5E7EB` border** | `#FFFFFF` | **1.24:1** | 1.4.11 | **✗ Fail — use `--color-border-interactive` for form controls** |
