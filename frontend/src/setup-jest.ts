// WHY THIS FILE EXISTS: Global test setup for Jest + Angular.
// Imports Angular testing infrastructure and jest-axe matchers.
// jest-axe adds the toHaveNoViolations() matcher to every spec file.
// To add a global mock: add it here. Be careful — mocks here affect ALL tests.

import 'jest-preset-angular/setup-jest';
import { toHaveNoViolations } from 'jest-axe';
import '@testing-library/jest-dom';

// Extend Jest matchers with jest-axe accessibility assertions
expect.extend(toHaveNoViolations);
