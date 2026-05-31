---
name: CSS Design Tokens & Styling Conventions
description: Color palette, CSS variable definitions, and mandatory CSS usage rules for Angular/PrimeNG projects
---

# CSS Design Tokens & Styling Conventions

## Color Palette

All colors **must** be referenced through CSS variables — never hard-coded in component SCSS or inline styles.

| Token | Hex | Contrast on white | Contrast on `#F4F4F6` | Usage |
|-------|-----|:-----------------:|:---------------------:|-------|
| `--color-sidebar-bg` | `#1A1A2E` | 17.06:1 ✓ | — | Sidebar and top bar background |
| `--color-sidebar-text` | `#FFFFFF` | — | — | Sidebar nav text (on dark bg) |
| `--color-sidebar-active` | `#2A2A42` | — | — | Active/hovered nav item |
| `--color-content-bg` | `#F4F4F6` | 1.10:1 (bg only) | — | Page background |
| `--color-surface` | `#FFFFFF` | — | — | Cards, tables, dialogs |
| `--color-primary` | `#1A1A2E` | 17.06:1 ✓ | 15.49:1 ✓ | Primary buttons, key actions, body text |
| `--accent-color` | `#E87722` | 3.12:1 ✓ (3:1 non-text) | — | Brand accent — logo/icon only, never body text |
| `--color-text-main` | `#1A1A2E` | 17.06:1 ✓ | — | Body text |
| `--color-text-muted` | `#636D77` | 5.17:1 ✓ | 4.80:1 ✓ | Secondary labels — passes 4.5:1 on both surfaces |
| `--color-border` | `#E5E7EB` | 1.24:1 (decorative only) | — | Decorative dividers, card/table borders |
| `--color-border-interactive` | `#767B84` | 3.92:1 ✓ | 3.57:1 ✓ | **Input/select/textarea borders** (meets 3:1 SC 1.4.11) |
| `--color-status-active` | `#22C55E` | 2.28:1 against white text ✗ | — | Status badge background; **use dark text** |
| `--color-status-inactive` | `#EF4444` | 3.76:1 against white text ✗ | — | Status badge background; **use dark text** |

### Critical color contrast failures — applied fixes

| Combination | Contrast | Requirement | Fix applied |
|---|---|---|---|
| White text on `#22C55E` badge | 2.28:1 | 4.5:1 | `p-tag-success` text overridden to `--color-primary` (7.49:1) |
| White text on `#EF4444` badge | 3.76:1 | 4.5:1 | `p-tag-danger` text overridden to `--color-primary` (4.53:1) |
| `#6B7280` on `#F4F4F6` | 4.40:1 | 4.5:1 | Replaced with `#636D77` (4.80:1) |
| `#E5E7EB` border on white inputs | 1.24:1 | 3:1 (SC 1.4.11) | Added `--color-border-interactive: #767B84` (3.92:1) for all form controls |

> `--color-accent` (`#E87722`) is 3.12:1 on white — passes 3:1 for non-text (icons, focus rings, decorative marks) but **fails 4.5:1 for body text**. Never use it as text color.

---

## PrimeNG Theme & Configuration

Use the **Lara Light** theme as the base. Apply CSS variable overrides in `styles.scss`:

```scss
:root {
  --primary-color: #1A1A2E;
  --primary-color-text: #FFFFFF;
  --surface-ground: #F4F4F6;
  --surface-card: #FFFFFF;
  --surface-border: #E5E7EB;
  --text-color: #1A1A2E;
  --text-color-secondary: #636D77;   /* was #6B7280 — fails 4.5:1 on #F4F4F6 */
  --font-family: 'Inter', sans-serif;
  --font-size: 13px;
  --border-radius: 4px;
  --color-focus: #E87722;

  /* Layout tokens */
  --color-sidebar-bg: #1A1A2E;
  --color-sidebar-text: #FFFFFF;
  --color-sidebar-active: #2A2A42;
  --color-content-bg: #F4F4F6;
  --color-surface: #FFFFFF;
  --color-primary: #1A1A2E;
  --color-text-main: #1A1A2E;
  --color-text-muted: #636D77;
  --color-border: #E5E7EB;
  --color-border-interactive: #767B84;  /* 3.92:1 on white — meets SC 1.4.11 */
  --color-status-active: #22C55E;
  --color-status-inactive: #EF4444;
}
```

---

## Accessibility-Critical Styling Requirements

These are mandatory. Claude must apply them whenever generating or modifying Angular/SCSS code.

### CSS variables only
All colors must use `var(--token)`. Never write hard-coded hex values in component `.scss` or inline `<style>` blocks.

### Status badge text — dark override required
`p-tag severity="success"` and `severity="danger"` use white text by default. Both fail WCAG AA:
```scss
/* global styles.scss — must be present */
.p-tag-success,
.p-tag-danger {
  color: var(--color-primary) !important;
}
```

### Interactive element borders
Form inputs, dropdowns, and textareas must use `--color-border-interactive` (3.92:1), not `--color-border` (1.24:1):
```scss
.p-inputtext,
.p-dropdown,
.p-calendar .p-inputtext,
textarea.p-inputtextarea {
  border-color: var(--color-border-interactive) !important;
}
```

### Focus indicators
Never suppress focus with `outline: none` unless a visible alternative is applied. The global `:focus-visible` rule provides a 2px `--color-focus` outline. Do not override it to `none` in component styles.

### High contrast / forced colors
The `@media (forced-colors: active)` block in `styles.scss` must not be removed. Inline SVGs and icon fonts must use `currentColor` for stroke/fill.

### Reduced motion
The `@media (prefers-reduced-motion: reduce)` block in `styles.scss` must not be removed. Do not add animations without testing this media query.

### Skip link
Every shell component must include `<a class="skip-link" href="#main-content">Skip to main content</a>` as the very first element in the template, and `<main id="main-content" tabindex="-1">` as the main content target.
