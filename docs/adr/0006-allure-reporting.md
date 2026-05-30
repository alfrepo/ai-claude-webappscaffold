# ADR-0006: Allure as Mandatory Test Reporting Dashboard

**Status:** Accepted  
**Date:** 2026-05-31  
**Deciders:** Platform Team

---

## Context

The project has a three-layer test pyramid (ADR-0003) producing results from:
- JUnit 5 (backend unit + integration)
- Jest (frontend unit)
- Playwright (E2E browser tests)
- Cucumber.js (BDD scenarios)

Until now, test results were available only as JUnit XML artifacts in CI. There was no
unified dashboard showing trend data, test history, failure analysis, or environment
attribution. Diagnosing test failures required navigating multiple CI job logs.

Requirements:
- A single dashboard aggregating results from all four test layers
- Available on every pipeline run, including failed pipelines (to diagnose failures)
- Accessible via a URL without downloading artifacts
- Shows: pass/fail breakdown, test duration, flaky test detection, attachments (screenshots, logs)
- Integrates with the existing test tools without changing test logic

## Decision

Adopt **Allure Framework** as the mandatory test reporting dashboard for all layers.

**Integration points:**

| Layer | Library | Results location |
|-------|---------|-----------------|
| Backend JUnit 5 | `allure-junit5` (auto via Surefire AspectJ agent) | `target/allure-results/` |
| Backend @Step annotations | `allure-spring-web` | Embedded in JUnit results |
| Frontend Jest | `allure-jest` reporter in `jest.config.ts` | `allure-results/` |
| Playwright E2E | `allure-playwright` reporter in `playwright.config.ts` | `allure-results/` |
| Cucumber BDD | `allure-cucumberjs` formatter in `cucumber.js` | `allure-results/` |

**CI pipeline job `allure:generate` (stage: `report`):**
- Runs `when: always` — the ONLY pipeline job with this setting
- Merges all four result directories into one
- Writes `environment.properties` (pipeline ID, branch, commit SHA) into the report
- Writes `executor.json` (GitLab pipeline URL, pages URL) into the report
- Fails if there are zero result files (misconfiguration guard)
- Publishes as a downloadable artifact (for failed pipeline runs)

**GitLab Pages job publishes** the report to `$CI_PAGES_URL/allure/` on main branch.

**Local generation:**
```bash
# Backend
cd backend && ./mvnw verify allure:report

# Frontend (all layers combined)
cd frontend && npm run test:ci && npm run e2e && npm run allure:generate && npm run allure:open

# Full gate + dashboard
OPEN_ALLURE=true ./scripts/quality-gate.sh
```

## Consequences

**Positive:**
- Unified dashboard shows all four test layers in one view — no jumping between CI jobs
- `when: always` ensures the dashboard is produced on failed pipelines — developers see exactly which test failed and why, with screenshots and logs attached
- Allure trend charts (across pipeline runs) detect flaky tests automatically
- `environment.properties` links the report to the exact pipeline and commit
- No change to test logic — only reporters/formatters are added

**Negative:**
- Allure results add ~5–10 MB per pipeline run to artifacts (managed by `expire_in: 4 weeks`)
- The `frankescobar/allure-docker-service` Docker image must be available to the CI runner
- Developers must remember to use `@Feature`/`@Story`/`@Severity` annotations to produce meaningful reports (documented in CLAUDE.md)
- Allure CLI must be installed locally for `npm run allure:open` (or use `npx allure-commandline`)

**Alternatives considered:**
- **JUnit XML + GitLab MR widget only:** Provides pass/fail count in MRs but no history, no screenshots, no categorisation, no trend data. Rejected.
- **Playwright HTML report only:** Covers E2E but not backend or frontend unit tests. Rejected.
- **ReportPortal:** Full test analytics platform but requires significant infrastructure (separate server). Overkill for this project size. Could replace Allure if scale demands it.
