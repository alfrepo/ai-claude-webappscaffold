# CLAUDE.md — Master Instructions for Claude Code

> This file is the single source of truth for how Claude Code must behave in this repository.
> Every rule here is enforced in CI. Violating any rule causes a build failure.
> When in doubt, ask: "Does this change have a test, an ADR, and pass the quality gate?"

---

## PROJECT OVERVIEW

**Purpose:** [REPLACE WITH YOUR APPLICATION PURPOSE]

**Tech Stack:**
| Layer | Technology |
|-------|-----------|
| Backend | Java 21, Spring Boot 3.x, Maven multi-module |
| Frontend | Angular 18+, PrimeNG, PrimeFlex |
| API | REST, OpenAPI 3.1 (contract-first) |
| Database | PostgreSQL 16 (RDS in prod, Testcontainers in tests) |
| Cloud | AWS (ECS Fargate + ALB, CloudFront + S3, RDS, Secrets Manager) |
| CI/CD | GitLab CI/CD (`.gitlab-ci.yml`) |
| IaC | Terraform |

**Port Conventions:**
- Backend: `8080` (HTTP), `8443` (HTTPS)
- Frontend dev server: `4200`
- PostgreSQL: `5432`
- LocalStack: `4566`

---

## MANDATORY DEPLOYMENT ARTIFACTS

Both artifacts are mandatory. Neither is optional. A feature is not complete until it works
in **both** deployment targets.

| # | Artifact | File / Directory | Environment |
|---|----------|-----------------|-------------|
| 1 | Docker Compose | `docker-compose.yml` | Local development, CI E2E |
| 2 | Helm Chart | `infra/helm/webapp/` | Kubernetes (dev cluster, staging, prod) |

**Rules:**
- A new environment variable added to the backend or frontend **must** be added to both
  `docker-compose.yml` (as an `environment:` entry) AND `infra/helm/webapp/templates/`
  (as a `ConfigMap` key or `ExternalSecret` field) **in the same PR**.
- The Helm chart must pass `helm lint infra/helm/webapp/` with zero warnings before merge.
- The Helm chart must render without error: `helm template webapp infra/helm/webapp/ > /dev/null`
- `docker compose up --build -d` must start cleanly from a cold state — no manual steps.
- No plaintext secrets in any `values*.yaml` file. Use `ExternalSecret` for all credentials.
- See `INTRO.md §3` for the full deployment artifact specification.

---

## MANDATORY CI/CD PIPELINE

The GitLab CI/CD pipeline defined in `.gitlab-ci.yml` is **mandatory**. No merge request
may be merged without a green pipeline. This is enforced at the GitLab project level via:

- **Project › Settings › Merge requests › "Pipelines must succeed"** — must be enabled
- **Protected branches** — `main` requires passing pipeline + Code Owner approval
- **`CODEOWNERS`** — defines who must approve changes to critical files

### Pipeline stages and their mandatory status

| Stage | Jobs | Mandatory? |
|-------|------|-----------|
| `validate` | Checkstyle, SpotBugs, ESLint, Prettier, Helm lint, ARC42 check | Yes — all |
| `test` | Backend tests + JaCoCo, Frontend tests + Jest coverage | Yes — all |
| `e2e` | Playwright + Cucumber BDD | Yes |
| `security` | OWASP dependency check (CVSS ≥ 7.0 fails) | Yes |
| `report` | **Allure dashboard generation** | Yes — `when: always` |
| `build` | Docker image push to GitLab Registry | Yes (main branch only) |
| `deploy` | Helm upgrade to dev/staging/prod | Yes for dev (auto), manual for staging/prod |
| `pages` | GitLab Pages: Allure + API docs + coverage | Yes (main branch only) |

**The `report` stage is the only stage that uses `when: always`** — the Allure dashboard
must be generated on every pipeline run, including failures, so developers can diagnose
problems from the report. Adding `allow_failure: true` to any other job requires an ADR.

### GitLab CI/CD Variables required (Project › Settings › CI/CD › Variables)

| Variable | Description | Protected | Masked |
|----------|-------------|-----------|--------|
| `NVD_API_KEY` | NVD API key for OWASP checks | Yes | Yes |
| `KUBECONFIG_DEV_B64` | Base64-encoded kubeconfig for dev cluster | Yes | Yes |
| `KUBECONFIG_STAGING_B64` | Base64-encoded kubeconfig for staging | Yes | Yes |
| `KUBECONFIG_PROD_B64` | Base64-encoded kubeconfig for prod | Yes | Yes |
| `CI_REGISTRY_USER` | GitLab Container Registry user (auto-set) | No | No |
| `CI_REGISTRY_PASSWORD` | GitLab Container Registry token (auto-set) | No | Yes |

---

## MANDATORY ALLURE DASHBOARD

Every pipeline run **must** produce an Allure test dashboard. This is non-negotiable.

### What feeds Allure

| Layer | Tool | Results directory |
|-------|------|------------------|
| Backend unit + integration | `allure-junit5` (auto via Surefire agent) | `backend/app/target/allure-results/` |
| Frontend unit | `allure-jest` reporter in `jest.config.ts` | `frontend/allure-results/` |
| E2E Playwright | `allure-playwright` reporter in `playwright.config.ts` | `frontend/allure-results/` |
| E2E Cucumber | `allure-cucumberjs` formatter in `cucumber.js` | `frontend/allure-results/` |

All results are merged in the CI `allure:generate` job and the unified report is:
1. Available as a **downloadable artifact** on every pipeline (for failed pipelines)
2. Published to **GitLab Pages** at `$CI_PAGES_URL/allure/` (main branch only)

### Rules

- **Never disable any Allure reporter.** All four integration points must remain wired.
- **Write meaningful Allure annotations** on backend tests:
  ```java
  @Feature("User Registration")
  @Story("Happy path registration")
  @Severity(SeverityLevel.CRITICAL)
  @Test
  void shouldRegisterUserSuccessfully() { … }
  ```
- **Write meaningful Allure labels** on E2E steps:
  ```typescript
  allure.label('feature', 'User Registration');
  allure.label('story', 'Happy path');
  ```
- **Use `@Step` annotations** on backend helper methods to produce readable step logs.
- The Allure dashboard is the **primary diagnostic tool** for test failures. Before asking
  "why did CI fail?", open the Allure report.

### Local Allure workflow

```bash
# After running tests locally:
cd backend && ./mvnw allure:report  # → backend/app/target/allure-report/
cd frontend && npm run allure:generate && npm run allure:open
```

---

## MANDATORY WORKFLOW

**Enforce this exact order for EVERY feature, no exceptions:**

1. **Gherkin first** — Capture the business requirement as a Gherkin scenario:
   ```
   /frontend/e2e/features/<bounded-context>/<feature>.feature
   ```
2. **BDD step definitions** — Write failing Cucumber + Playwright step definitions in:
   ```
   /frontend/e2e/steps/<bounded-context>/
   ```
3. **Unit tests** — Write failing unit tests:
   - Backend: JUnit 5 + Mockito in `src/test/java/`
   - Frontend: Jest + Angular Testing Library in `*.spec.ts`
4. **Integration tests** — Write failing integration tests:
   - Backend: `@SpringBootTest` + Testcontainers
   - Frontend: Playwright component tests
5. **Implement** — Write the minimum code to make ALL tests pass (no more)
6. **OpenAPI spec** — Update `/backend/api/src/main/resources/openapi.yaml` FIRST,
   then run `mvn generate-sources` to regenerate stubs
7. **ADR** — If an architectural decision was made, create/update an ADR in `/docs/adr/`
8. **Quality gate** — Run `mvn verify` + `ng test --watch=false --code-coverage` before committing

---

## GHERKIN RULES

- Every user-facing feature MUST have at least one `.feature` file before implementation starts
- Feature files live in `/frontend/e2e/features/<bounded-context>/`
- Use `Given`/`When`/`Then` strictly — no `And` as the first keyword, no conjunctive steps
- Business language ONLY — no technical terms (no SQL, HTTP, class names, JSON) in scenarios
- All input validation rules MUST be expressed as `Scenario Outline` with an `Examples` table covering:
  - Happy path
  - Empty/blank input
  - Maximum length boundary (exactly at limit, exactly one over)
  - Invalid format
  - Duplicate/conflict cases
- Tags: use `@smoke` for critical path, `@regression` for full suite, `@wip` for in-progress

**Example structure:**
```gherkin
Feature: User Registration
  As a visitor
  I want to create an account
  So that I can access the application

  @smoke
  Scenario: Successful registration
    Given I am on the registration page
    When I fill in valid registration details
    Then I should be logged in and see the dashboard

  Scenario Outline: Registration input validation
    Given I am on the registration page
    When I enter "<email>" as my email address
    Then I should see the error "<error_message>"

    Examples:
      | email              | error_message                    |
      |                    | Email is required                |
      | not-an-email       | Email must be a valid address    |
      | a@b.c              | Email must be at least 6 chars   |
      | existing@user.com  | This email is already registered |
```

---

## TEST COVERAGE GATES

**CI blocks merge if any threshold is not met.**

| Layer | Metric | Threshold |
|-------|--------|-----------|
| Backend | Line coverage (JaCoCo) | ≥ 80% |
| Backend | Branch coverage (JaCoCo) | ≥ 75% |
| Frontend | Statement coverage (Jest) | ≥ 80% |
| E2E | Gherkin scenario pass rate | 100% |

- JaCoCo config: `backend/pom.xml` — `<haltOnFailure>true</haltOnFailure>`
- Jest config: `frontend/jest.config.ts` — `coverageThreshold`
- Never exclude packages from coverage without an ADR explaining why

---

## ACCESSIBILITY RULES

**Every Angular component must be accessible. Violations block CI.**

- All components must pass `axe-core` checks at WCAG 2.1 AA level (zero violations)
- Enforced via `jest-axe` in every `*.spec.ts` file:
  ```typescript
  it('should have no accessibility violations', async () => {
    const { container } = await render(MyComponent);
    expect(await axe(container)).toHaveNoViolations();
  });
  ```
- All interactive elements must have `aria-label` or an associated `<label>` element
- Color contrast ratio ≥ 4.5:1 (WCAG AA) — verified with Axe
- Keyboard navigation must be tested in every component spec:
  ```typescript
  it('should be keyboard navigable', () => {
    const button = fixture.debugElement.query(By.css('button'));
    button.nativeElement.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter' }));
    expect(/* action triggered */).toBe(true);
  });
  ```
- PrimeNG components MUST have explicit `[ariaLabel]` and `[ariaLabelledBy]` attributes set
  — never rely on defaults (they are often empty or generic)
- Every page in Playwright e2e tests MUST include an axe snapshot assertion:
  ```typescript
  import AxeBuilder from '@axe-core/playwright';
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
  ```
- App shell MUST include a "Skip to main content" link as the first focusable element

---

## API / CONTRACT-FIRST RULES

- **OpenAPI spec is the single source of truth:** `/backend/api/src/main/resources/openapi.yaml`
- Backend stubs are GENERATED — never hand-edit files under `target/generated-sources/`
- Frontend API client is GENERATED — never hand-edit files under `src/app/api/generated/`
- **Never hand-write HTTP calls in Angular** — always use the generated `ApiService` classes
- Every endpoint MUST have ALL of the following in the spec:
  - `summary` (one line)
  - `description` (full explanation with business context)
  - `operationId` (camelCase, unique)
  - Request schema with `example`
  - Response schema(s) with `example`
  - Error responses: `400`, `401`, `403`, `404`, `422`, `500`
  - `tags` (one per bounded context)
- When adding an endpoint:
  1. Edit `openapi.yaml`
  2. Run `mvn generate-sources -pl api`
  3. Implement the generated interface in `app/`
  4. Write tests against the implementation, not the generated code

---

## 12-FACTOR APP RULES

1. **Config via environment variables only** — no hardcoded URLs, ports, credentials, or feature flags
2. **Spring profiles:** `local` (H2/Docker), `dev`, `staging`, `prod` — never use `default` profile in prod
3. **All secrets via AWS Secrets Manager** — never commit secrets, never use `.env` files in prod
4. **Stateless backend** — no in-process session state; use JWT or session tokens stored client-side
5. **Logs to stdout/stderr** in structured JSON (Logback + logstash-logback-encoder)
   - Log format: `timestamp`, `level`, `traceId`, `spanId`, `service`, `message`, `exception`
   - Never log PII (names, emails, SSNs, payment data)
6. **Health endpoints exposed:**
   - `GET /actuator/health` — liveness + readiness probes
   - `GET /actuator/info` — build version, git commit
   - `GET /actuator/metrics` — Prometheus-compatible (secured)

---

## AWS WELL-ARCHITECTED RULES

- Each service in its own ECS task / container (backend, frontend served from CloudFront)
- ALB in front of backend; CloudFront distribution in front of frontend (S3 static hosting)
- RDS in private subnet, accessible only from ECS security group — no public access
- IAM least-privilege roles per service — no wildcard `*` actions in prod
- AWS X-Ray tracing enabled (Micrometer Tracing + OTLP exporter)
- All infrastructure defined in Terraform under `/infra/` — no click-ops
- Backend uses IRSA (IAM Roles for Service Accounts) or ECS Task Roles — no long-lived keys

---

## ARCHITECTURE DECISION RECORDS

- Every non-trivial decision (technology choice, pattern selection, trade-off accepted) needs an ADR
- Location: `/docs/adr/NNNN-kebab-case-title.md`
- Use the MADR template: title, status, context, decision, consequences
- Statuses: `proposed` → `accepted` → `deprecated` → `superseded by [NNNN]`
- **Never reverse an accepted ADR without creating a superseding ADR**

**Existing ADRs:**
- [0001 Technology Stack](docs/adr/0001-technology-stack.md)
- [0002 Contract-First API Design](docs/adr/0002-contract-first-api-design.md)
- [0003 Test Strategy](docs/adr/0003-test-strategy.md)
- [0004 Accessibility Strategy](docs/adr/0004-accessibility-strategy.md)
- [0005 GitLab as VCS and CI Platform](docs/adr/0005-gitlab-migration.md)
- [0006 Allure as Mandatory Test Reporting](docs/adr/0006-allure-reporting.md)

---

## DOCUMENTATION RULES

- `README.md` at root: quickstart in under 5 commands
- `/docs/ARCHITECTURE.md`: C4 model level 1+2 in Mermaid (keep it current)
- `/docs/ARC42.md`: ARC42 solution architecture — see maintenance rules below
- Every public Java class/method MUST have Javadoc (enforced by Checkstyle)
- Every Angular public component MUST have JSDoc + `@Input`/`@Output` documented
- OpenAPI spec is auto-published to GitLab Pages at `$CI_PAGES_URL/api/` via the `pages` CI job
- Never delete an ADR — mark it `deprecated` or `superseded`

---

## ARC42 MAINTENANCE CONTRACT

`/docs/ARC42.md` is a living document. Claude Code MUST update it in the **same PR** as the
code change that invalidates any section. A PR that changes architecture without updating
ARC42 is incomplete and must not be merged.

### Trigger table — what change requires which ARC42 section update

| Code / config change | ARC42 section(s) to update |
|----------------------|---------------------------|
| New bounded context, feature module, or `features/<name>/` directory | §5.2 (frontend whitebox), §6 (if new runtime flow), §8 (if new crosscutting concern) |
| New external system integrated (email, payment, IdP, …) | §3.1 Business Context diagram, §3.2 Technical Context table, §6 sequence diagram |
| New AWS service added to Terraform or Helm | §7.2 Deployment diagram, §7.4 Network topology, §10 (if new quality scenario) |
| New Kubernetes resource type added to Helm chart | §7.2 Helm chart section, §8.1 Security table (if security-relevant) |
| New Spring profile or port number changed | §3.3 Ports table, §7.3 Environment matrix |
| New environment variable added (backend or frontend) | §8.4 Configuration Management table |
| New architectural pattern adopted | §4.1 Core Architectural Patterns table |
| Technology swap or new dependency (framework, library) | §4.2 Key Technology Decisions table, §12 Glossary |
| New ADR created | §9 Architecture Decisions index table |
| New quality requirement or SLA agreed | §10.1 Quality Tree, §10.2 Quality Scenarios table |
| Risk identified or resolved | §11.1 Risks table |
| Risk accepted as technical debt | §11.2 Technical Debt table |
| New term introduced in the domain or codebase | §12 Glossary |
| Deployment artifact changed (new Helm template, docker-compose service) | §7.1 or §7.2 |
| Database schema management rule changed | §8.8 Database Schema Management |
| Error handling pattern changed | §8.3 Error Handling |
| Observability backend changed | §8.2 Observability table |

### How to update ARC42

1. Find the section(s) from the trigger table above.
2. Update the text, table row, or Mermaid diagram to reflect the new state.
3. If a Mermaid diagram needs a new node: add it and re-verify the diagram renders in GitHub.
4. Update the `**Last updated:**` date at the top of `docs/ARC42.md`.
5. If a section becomes stale before you have time to fix it, add an HTML comment:
   `<!-- ARCHITECTURE-STALE: <reason> -->` directly above the stale content.
   Claude Code will detect this marker during the next PR review and update the section.

### Staleness detection (CI advisory check)

The CI pipeline runs this check and prints a warning (non-blocking) if stale markers exist:
```bash
grep -n "ARCHITECTURE-STALE" docs/ARC42.md && echo "⚠ ARC42 has stale sections — update before merge"
```
A PR containing `ARCHITECTURE-STALE` markers **must not be merged** unless the stale section
is genuinely unresolvable at merge time and a follow-up ticket exists.

### What ARC42 must NOT contain

- Implementation details that belong in code comments or Javadoc
- Step-by-step how-to instructions (those belong in README or CLAUDE.md)
- Decision rationale (that belongs in ADRs — §9 links to them)
- Temporary state (in-progress work, sprint plans, ticket numbers)

---

## CODE QUALITY GATES

**CI blocks merge if any gate fails.**

| Tool | Scope | Rule |
|------|-------|------|
| Checkstyle | Backend Java | Google Java Style |
| SpotBugs | Backend Java | No HIGH or CRITICAL bugs |
| OWASP Dependency Check | Backend + Frontend | Fail on CVSS ≥ 7.0 |
| ESLint | Frontend TypeScript | Zero errors (`@typescript-eslint/no-explicit-any: error`) |
| Prettier | Frontend | Zero formatting violations |
| SonarQube | All | 0 blocker issues, 0 critical security hotspots |

- **No `TODO` or `FIXME` comments in merged code** (Checkstyle + ESLint enforce this)
- **No `any` in TypeScript** — use proper types or `unknown` with type guards
- **No hardcoded strings in Angular templates** — all UI text via `ngx-translate`
- **No `console.log` in Angular** — use the injected `LogService`

---

## CLAUDE CODE BEHAVIORAL RULES

When working in this repo, Claude Code MUST:

1. **Always read the relevant ADRs** before proposing an architecture change
2. **Always update the OpenAPI spec** before writing any backend endpoint code
3. **Always write the Gherkin scenario** before writing any feature code
4. **Never skip test writing** — even for "obvious" utility functions
5. **Never add business logic to the `domain/` module** that has framework dependencies
6. **Always run `mvn verify` locally** before declaring backend work done
7. **Always check axe violations** before declaring frontend work done
8. **Ask before adding a new dependency** — explain why it's needed and what it replaces
9. **Never commit directly to `main`** — always use a feature branch + PR
10. **Always reference the ADR number** when implementing a decision described in one
