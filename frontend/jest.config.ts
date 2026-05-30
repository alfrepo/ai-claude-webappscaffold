// WHY THIS FILE EXISTS: Jest configuration for Angular unit tests.
// Uses jest-preset-angular to handle Angular-specific transforms.
// Coverage thresholds are enforced here — CI fails if they are not met.
// jest-axe is configured globally so every spec can run accessibility checks.
// To add a global test setup: add the file path to setupFilesAfterFramework.

import type { Config } from 'jest';

const config: Config = {
  preset: 'jest-preset-angular',
  setupFilesAfterFramework: ['<rootDir>/src/setup-jest.ts'],
  setupFiles: ['jest-axe/extend-expect'],
  globalSetup: 'jest-preset-angular/global-setup',
  testEnvironment: 'jsdom',
  testMatch: ['<rootDir>/src/**/*.spec.ts'],
  moduleNameMapper: {
    '^@core/(.*)$': '<rootDir>/src/app/core/$1',
    '^@shared/(.*)$': '<rootDir>/src/app/shared/$1',
    '^@env/(.*)$': '<rootDir>/src/environments/$1',
  },
  transform: {
    '^.+\\.(ts|mjs|js|html)$': [
      'jest-preset-angular',
      {
        tsconfig: '<rootDir>/tsconfig.spec.json',
        stringifyContentPathRegex: '\\.(html|svg)$',
      },
    ],
  },
  transformIgnorePatterns: ['node_modules/(?!.*\\.mjs$|@angular|primeng|primeicons|primeflex)'],
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/app/**/*.ts',
    '!src/app/**/*.module.ts',
    '!src/app/api/generated/**',
    '!src/main.ts',
    '!src/**/*.d.ts',
  ],
  coverageReporters: ['html', 'lcov', 'text-summary'],
  // Enforced thresholds — matches CLAUDE.md TEST COVERAGE GATES section.
  // Raise these as coverage improves; never lower them.
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80,
    },
  },
};

export default config;
