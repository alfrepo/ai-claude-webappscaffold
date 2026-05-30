# ADR-0003: Test Strategy (Unit → Integration → BDD E2E Pyramid)

**Status:** Accepted  
**Date:** 2026-05-30  
**Deciders:** Platform Team

---

## Context

We need a test strategy that:
- Catches bugs early and close to the source
- Provides confidence in deployments
- Does not create brittle tests that slow development
- Enforces business requirements through executable specifications

## Decision

We adopt a **three-layer test pyramid** with strict rules for each layer:

### Layer 1: Unit Tests (bottom — largest, fastest)

**Backend (JUnit 5 + Mockito):**
- Test domain logic in isolation (no Spring context, no database)
- Mock all external dependencies
- Must run in < 100ms per test
- Coverage threshold: ≥ 80% line, ≥ 75% branch (enforced by JaCoCo, build fails)

**Frontend (Jest + Angular Testing Library + jest-axe):**
- Test components in isolation with `TestBed`
- Every component spec MUST include an `axe()` accessibility check
- Mock HTTP calls using `HttpClientTestingModule`
- Coverage threshold: ≥ 80% statement (enforced by Jest, build fails)

### Layer 2: Integration Tests (middle — fewer, slower)

**Backend (`@SpringBootTest` + Testcontainers):**
- Start a real Spring context with a real PostgreSQL container (Testcontainers)
- NEVER use H2 or mock databases for integration tests
  - Rationale: H2 has different SQL dialect, missing PostgreSQL features, and has caused production incidents where mock tests passed but real DB migrations failed
- Test repository layers, service layers with real DB, and controller endpoint wiring
- Slow (30–120s) — run in parallel where possible

**Frontend (Playwright Component Tests):**
- Test components in a real browser with real DOM
- Run against a compiled Angular build

### Layer 3: BDD E2E Tests (top — fewest, slowest)

**Gherkin + Cucumber.js + Playwright:**
- Every user-facing feature starts with a `.feature` file (before implementation)
- Step definitions use Playwright to drive a real browser against a running stack
- Every page navigation runs `@axe-core/playwright` accessibility check automatically
- Run against `docker compose up` stack in CI

### Coverage Gates (enforced in CI)

| Layer | Tool | Gate |
|-------|------|------|
| Backend unit | JaCoCo | Line ≥ 80%, Branch ≥ 75% |
| Frontend unit | Jest | Statements ≥ 80% |
| E2E | Cucumber | 100% of scenarios passing |

## Consequences

**Positive:**
- Fast feedback loop (unit tests run in seconds)
- High confidence in deployments (E2E tests verify business scenarios)
- Accessibility requirements are automatically tested at all layers
- Business requirements are documented as executable Gherkin scenarios

**Negative:**
- Integration tests with Testcontainers are slow (~45s per test class)
- Requires Docker in CI environment for Testcontainers
- Gherkin scenarios require collaboration between dev and business to write correctly

**Alternatives Considered:**
- **H2 for integration tests:** Rejected — past incident where H2 tests passed but PostgreSQL migration failed in production
- **No E2E tests:** Rejected — unit/integration tests cannot catch browser-level regressions or cross-component integration issues
