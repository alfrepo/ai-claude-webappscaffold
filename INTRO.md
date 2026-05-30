# Engineering Standards — WebApp Scaffold

> This document is the authoritative reference for the engineering standards embedded in this
> scaffold. Every standard listed here is **enforced automatically** — by CI gates, linting
> rules, or test-suite thresholds. A standard that is only documented but not enforced is not
> a standard; it is a wish. Nothing in this document is aspirational.
>
> Read this before writing your first line of code.

---

## Table of Contents

1. [What This Scaffold Is](#1-what-this-scaffold-is)
2. [Architecture Overview](#2-architecture-overview)
3. [Mandatory Deployment Artifacts](#3-mandatory-deployment-artifacts)
   - 3.1 [Deployment 1 — Docker Compose (local / dev)](#31-deployment-1--docker-compose-local--dev)
   - 3.2 [Deployment 2 — Helm Chart (Kubernetes / production)](#32-deployment-2--helm-chart-kubernetes--production)
4. [API Design Standard — Contract-First](#4-api-design-standard--contract-first)
5. [Test Standard — Three-Layer Pyramid](#5-test-standard--three-layer-pyramid)
6. [Coverage Gates](#6-coverage-gates)
7. [Accessibility Standard — WCAG 2.1 AA](#7-accessibility-standard--wcag-21-aa)
8. [Code Quality Gates](#8-code-quality-gates)
9. [12-Factor Application Standard](#9-12-factor-application-standard)
10. [Security Standard](#10-security-standard)
11. [Observability Standard](#11-observability-standard)
12. [AWS Well-Architected Standard](#12-aws-well-architected-standard)
13. [Documentation Standard](#13-documentation-standard)
14. [Mandatory Developer Workflow](#14-mandatory-developer-workflow)
15. [Enforcement Matrix](#15-enforcement-matrix)

---

## 1. What This Scaffold Is

This repository is a **production-grade, empty monorepo scaffold**. It contains no business
logic. It contains no domain features. What it does contain is every structural guardrail,
tooling configuration, and pipeline gate that a feature team needs to ship software that is:

- **Correct** — verified by a three-layer automated test pyramid
- **Accessible** — WCAG 2.1 AA enforced by axe-core at unit and E2E level
- **Secure** — OWASP dependency scanning, deny-all security policy, no secrets in source
- **Observable** — structured JSON logs, distributed traces, Prometheus metrics from day one
- **Deployable** — two mandatory, runnable deployment artifacts covering all environments

The rule is simple: **add a feature by filling in the scaffold, not by bending it.**

### Monorepo Structure

```
/
├── backend/                    # Java 21 · Spring Boot 3.x · Maven multi-module
│   ├── domain/                 #   Pure Java domain model — zero framework deps
│   ├── api/                    #   OpenAPI 3.1 spec + generated server stubs
│   └── app/                    #   Spring Boot wiring — implements api/ interfaces
├── frontend/                   # Angular 18+ · PrimeNG · PrimeFlex
│   ├── src/app/
│   │   ├── core/               #   Singleton services, interceptors
│   │   ├── shared/             #   Reusable components, PrimeNG re-exports
│   │   ├── layout/             #   Header, footer — the application shell
│   │   ├── features/           #   Feature components (lazy-loaded by route)
│   │   └── api/generated/      #   Generated Angular HTTP client (never hand-edit)
│   └── e2e/
│       ├── features/           #   Gherkin .feature files by bounded context
│       ├── steps/              #   Cucumber step definitions
│       └── support/            #   Playwright fixtures, World, hooks
├── infra/
│   ├── helm/                   # Helm chart — Deployment 2 (Kubernetes)
│   └── terraform/              # AWS infrastructure as code
├── docs/
│   ├── adr/                    #   Architecture Decision Records (MADR format)
│   └── ARCHITECTURE.md         #   C4 Level 1 + 2 Mermaid diagrams
├── scripts/
│   └── quality-gate.sh         # Runs the full CI gate locally
├── docker-compose.yml          # Deployment 1 — local / dev / CI
└── CLAUDE.md                   # Master AI-assistant behavioral spec
```

---

## 2. Architecture Overview

The backend follows **Hexagonal Architecture** (Ports and Adapters):

```
┌──────────────────────────────────────────┐
│  app/   Spring Boot adapter              │
│  ┌──────────────────────────────────┐    │
│  │  api/  OpenAPI port (interface)  │    │
│  │  ┌────────────────────────────┐  │    │
│  │  │  domain/  Core (pure Java) │  │    │
│  │  └────────────────────────────┘  │    │
│  └──────────────────────────────────┘    │
└──────────────────────────────────────────┘
```

- `domain/` — knows nothing about Spring, HTTP, or databases. No exceptions.
- `api/` — the OpenAPI contract expressed as generated Java interfaces. Neither domain nor app
  depends on each other directly; both depend on the `api/` contract.
- `app/` — wires domain and api together. All Spring annotations live here.

The frontend follows **feature-based vertical slicing**: each bounded context gets its own
subdirectory under `features/`, with its own component, spec, routes, and Gherkin scenarios.

---

## 3. Mandatory Deployment Artifacts

**Both deployment artifacts are mandatory.** They are not optional extras. The project is not
considered scaffolded correctly until both are runnable. CI validates Deployment 1 on every PR.
Deployment 2 is validated in the CI release stage before any image is pushed.

---

### 3.1 Deployment 1 — Docker Compose (local / dev)

**File:** `docker-compose.yml` at the repository root.

**Purpose:** Provides a single-command local development environment that mirrors the production
service topology. Every service a developer needs — backend, frontend, database, and AWS service
mocks — starts with one command and is accessible via localhost.

**Run:**
```bash
docker compose up --build -d
```

**Services:**

| Service | Port | Purpose |
|---------|------|---------|
| `backend` | `8080` | Spring Boot API (Spring profile: `local`) |
| `frontend` | `4200` | Angular SPA served by nginx |
| `postgres` | `5432` | PostgreSQL 16 — primary database |
| `localstack` | `4566` | AWS service mocks (S3, SQS, Secrets Manager, X-Ray) |

**Standards enforced by this artifact:**

| Standard | How |
|----------|-----|
| 12-Factor config | All passwords injected as env vars, clearly marked `CHANGE_FOR_PRODUCTION` |
| Health checks | Every container has a `HEALTHCHECK` instruction; depends_on uses `service_healthy` |
| Non-root execution | Backend container runs as `appuser` (UID 1000), not root |
| AWS parity | LocalStack mocks all AWS services used in production so local code paths match |
| Stateless backend | No bind-mounted source code in the backend container; config only via env vars |

**Validation check (run after `docker compose up`):**

```bash
# Backend health
curl -s http://localhost:8080/actuator/health | jq .status
# Expected: "UP"

# Frontend loads
curl -sI http://localhost:4200 | grep "HTTP/"
# Expected: HTTP/1.1 200 OK

# LocalStack is ready
curl -s http://localhost:4566/_localstack/health | jq .services.s3
# Expected: "available"
```

**Rules:**
- Every new service added to the application **must** have a corresponding service block in
  `docker-compose.yml` with a `healthcheck` and `depends_on` wiring.
- No hardcoded production credentials. All placeholder passwords are suffixed `CHANGE_FOR_PRODUCTION`.
- The `docker compose up --build` command **must** start cleanly from a cold state without
  manual intervention. If it does not, the PR is not mergeable.

---

### 3.2 Deployment 2 — Helm Chart (Kubernetes / production)

**Directory:** `infra/helm/webapp/`

**Purpose:** The Helm chart is the canonical deployment descriptor for all non-local environments
(dev cluster, staging, production). It encapsulates all Kubernetes resource definitions —
`Deployment`, `Service`, `Ingress`, `HorizontalPodAutoscaler`, `PodDisruptionBudget`,
`ConfigMap`, and `ExternalSecret` — and exposes a single `values.yaml` surface for
environment-specific overrides.

The Helm chart is not a convenience; it is **required**. Docker Compose is not used in any
environment above local development.

**Render (dry-run, no cluster needed):**
```bash
helm template webapp infra/helm/webapp/ --values infra/helm/webapp/values.yaml
```

**Lint (validates YAML structure):**
```bash
helm lint infra/helm/webapp/
```

**Deploy to a cluster:**
```bash
# Dev cluster
helm upgrade --install webapp infra/helm/webapp/ \
  --namespace webapp-dev --create-namespace \
  --values infra/helm/webapp/values.yaml \
  --values infra/helm/webapp/values-dev.yaml \
  --set backend.image.tag=$(git rev-parse --short HEAD)

# Production (run from CI only — never manually)
helm upgrade --install webapp infra/helm/webapp/ \
  --namespace webapp-prod --create-namespace \
  --values infra/helm/webapp/values.yaml \
  --values infra/helm/webapp/values-prod.yaml \
  --set backend.image.tag=${IMAGE_TAG} \
  --atomic --timeout 5m
```

**Chart structure:**

```
infra/helm/webapp/
├── Chart.yaml                  # Chart metadata and dependency declarations
├── values.yaml                 # Default values (safe for local cluster)
├── values-dev.yaml             # Dev environment overrides
├── values-staging.yaml         # Staging environment overrides
├── values-prod.yaml            # Production overrides (no secrets — those are in ExternalSecret)
└── templates/
    ├── _helpers.tpl             # Named template helpers (labels, selectors)
    ├── namespace.yaml           # Namespace resource
    ├── backend/
    │   ├── deployment.yaml      # Backend Deployment with readiness/liveness probes
    │   ├── service.yaml         # ClusterIP Service
    │   ├── hpa.yaml             # HorizontalPodAutoscaler (CPU + memory)
    │   ├── pdb.yaml             # PodDisruptionBudget (minAvailable: 1 in prod)
    │   └── serviceaccount.yaml  # ServiceAccount for IRSA/Workload Identity
    ├── frontend/
    │   ├── deployment.yaml      # Frontend nginx Deployment
    │   ├── service.yaml         # ClusterIP Service
    │   └── configmap.yaml       # env.js ConfigMap (runtime API URL injection)
    ├── ingress.yaml             # Ingress (nginx or ALB ingress controller)
    ├── externalsecret.yaml      # ExternalSecret (reads from AWS Secrets Manager)
    └── networkpolicy.yaml       # NetworkPolicy (deny-all by default, explicit egress)
```

**Standards enforced by this artifact:**

| Standard | Kubernetes mechanism |
|----------|---------------------|
| Non-root containers | `securityContext.runAsNonRoot: true`, `runAsUser: 1000` |
| Read-only root filesystem | `securityContext.readOnlyRootFilesystem: true` |
| No privilege escalation | `securityContext.allowPrivilegeEscalation: false` |
| Resource limits mandatory | Every container has `resources.requests` and `resources.limits` |
| Liveness probe | `GET /actuator/health/liveness` — restarts the pod on JVM hang |
| Readiness probe | `GET /actuator/health/readiness` — removes pod from Service endpoints on DB loss |
| Rolling update with zero downtime | `strategy.rollingUpdate.maxUnavailable: 0` |
| Pod disruption budget | `minAvailable: 1` in prod — prevents full eviction during node drain |
| Horizontal autoscaling | HPA on CPU ≥ 70% and memory ≥ 80% |
| Secrets never in chart | `ExternalSecret` pulls from AWS Secrets Manager via External Secrets Operator |
| Network isolation | `NetworkPolicy` denies all ingress/egress by default; only explicit rules pass |
| Least-privilege IAM | `ServiceAccount` annotated with IRSA role ARN |

**Rules:**
- The Helm chart **must** pass `helm lint` with zero warnings before a PR merges.
- The chart **must** render without error via `helm template` — validated in CI.
- No plaintext secrets in any chart file. All secrets flow through `ExternalSecret`.
- `values-prod.yaml` contains **only non-sensitive overrides** (replica count, resource sizes,
  ingress host). Secrets are never present in any `values-*.yaml` file.
- A new backend or frontend environment variable **must** be added to both `docker-compose.yml`
  and the Helm chart's `deployment.yaml` (via `ConfigMap` or `ExternalSecret`) in the same PR.
  Split changes across PRs are rejected.

**Validation gate in CI (runs before image push):**
```bash
helm lint infra/helm/webapp/
helm template webapp infra/helm/webapp/ --values infra/helm/webapp/values.yaml > /dev/null
```

---

## 4. API Design Standard — Contract-First

**The OpenAPI specification is the single source of truth.**

File: `backend/api/src/main/resources/openapi.yaml`

### Rules

1. **Spec before code.** The OpenAPI spec is updated — and `mvn generate-sources` is run — before
   any implementation is written. A PR that adds an endpoint without a spec change is rejected.

2. **Generated code is never hand-edited.** Files under `target/generated-sources/` and
   `src/app/api/generated/` are outputs, not inputs. Editing them is futile — the next build
   overwrites them.

3. **No hand-written HTTP calls in Angular.** The generated `ApiService` classes are the only
   permitted way to make HTTP calls. The `no-restricted-imports` ESLint rule enforces this.

4. **Every endpoint must have all of the following in the spec:**

   | Field | Requirement |
   |-------|-------------|
   | `operationId` | Unique, camelCase, describes the action |
   | `summary` | One line, human-readable |
   | `description` | Full explanation including business context |
   | `tags` | One tag per bounded context |
   | Request schema | With a realistic `example` |
   | Response schema(s) | With a realistic `example` per status code |
   | Error responses | `400`, `401`, `403`, `404`, `422`, `500` — all present |

5. **Error responses follow RFC 7807 Problem Details.** The `ProblemDetail` schema is defined
   once in `components/schemas` and referenced everywhere. The `GlobalExceptionHandler` maps
   every exception to this shape.

6. **Generate after every spec change:**
   ```bash
   # Backend stubs
   mvn generate-sources -pl backend/api

   # Frontend client
   cd frontend && npm run generate-api
   ```

---

## 5. Test Standard — Three-Layer Pyramid

Every feature is verified at three levels. Skipping a level is not permitted.

```
         ▲
        /E2E\         Gherkin + Cucumber.js + Playwright
       /─────\        — fewest tests, full business scenario coverage
      /  INT  \       @SpringBootTest + Testcontainers
     /─────────\      — moderate number, real DB, real Spring context
    /   UNIT    \     JUnit 5 + Mockito · Jest + Angular Testing Library
   /─────────────\    — most tests, fastest, pure logic in isolation
```

### Layer 1: Unit Tests

**Backend** (JUnit 5 + Mockito):
- Test domain logic with zero Spring context
- Mock all external dependencies with Mockito
- Target: every public method in `domain/` and business logic in `app/`

**Frontend** (Jest + Angular Testing Library + jest-axe):
- Test each component in isolation via `TestBed`
- Every component spec **must** include an `axe()` accessibility assertion — no exceptions
- Mock HTTP via `HttpClientTestingModule`; mock services via `TestBed.overrideProvider`

### Layer 2: Integration Tests

**Backend** (`@SpringBootTest` + Testcontainers):
- A real PostgreSQL container (Testcontainers) is started per test class
- H2 is **never** used for integration tests — see ADR-0003 for the reason (past production
  incident caused by H2/PostgreSQL dialect divergence)
- Extend `AbstractIntegrationTest` — it manages the container lifecycle

**Frontend** (Playwright component tests):
- Test component interactions in a real Chromium browser
- Distinct from E2E — no running backend required

### Layer 3: BDD End-to-End Tests

**Gherkin + Cucumber.js + Playwright + @axe-core/playwright:**
- Every user-facing feature starts with a `.feature` file before implementation begins
- Feature files use business language only — no SQL, JSON, class names, HTTP methods
- Step definitions use Playwright to drive a real browser against a running `docker compose` stack
- The `base-fixture.ts` Playwright fixture **automatically** runs an axe-core accessibility
  scan on every page navigation — no extra code required in individual tests

### Gherkin Scenario Rules

```gherkin
# Correct — business language, Scenario Outline for validation rules
Scenario Outline: Input validation for registration
  Given I am on the registration page
  When I enter "<email>" as my email address
  Then I should see the error "<error_message>"

  Examples:
    | email             | error_message                    |
    |                   | Email is required                |
    | not-valid         | Email must be a valid address    |
    | a@b.c             | Email is too short               |
    | taken@example.com | This email is already registered |
```

Every validation rule must have an Examples table covering: happy path · empty input ·
max-length boundary · invalid format · duplicate/conflict.

---

## 6. Coverage Gates

Gates are enforced by CI. A build that does not meet thresholds **fails and blocks merge**.
Thresholds are configured in `backend/pom.xml` (JaCoCo) and `frontend/jest.config.ts` (Jest).

| Layer | Tool | Metric | Threshold |
|-------|------|--------|-----------|
| Backend | JaCoCo | Line coverage | **≥ 80%** |
| Backend | JaCoCo | Branch coverage | **≥ 75%** |
| Frontend | Jest | Statement coverage | **≥ 80%** |
| Frontend | Jest | Function coverage | **≥ 80%** |
| Frontend | Jest | Line coverage | **≥ 80%** |
| E2E | Cucumber | Scenario pass rate | **100%** |

**Rules:**
- Thresholds may only be raised, never lowered, without an ADR.
- Generated code is excluded from coverage measurement (`target/generated-sources/`,
  `src/app/api/generated/`, `*Application.class`).
- A class may be excluded from JaCoCo only if it contains zero testable logic (e.g.,
  a pure POJO with Lombok). Exclusions require a comment in the Checkstyle suppression file.

---

## 7. Accessibility Standard — WCAG 2.1 AA

Accessibility is a legal requirement and a quality requirement. It is not optional.

### Automated Enforcement

| Where | Tool | What is checked |
|-------|------|----------------|
| Every component unit test | `jest-axe` | `axe()` call, zero violations at WCAG AA |
| Every E2E page navigation | `@axe-core/playwright` | Full page scan, zero violations at WCAG AA |
| Angular templates | `@angular-eslint/template/accessibility` | ESLint rules block build |

### Rules

1. **Skip-to-content link** must be the first focusable element on every page:
   ```html
   <a class="skip-link" href="#main-content">Skip to main content</a>
   ```

2. **Every interactive element** must have an `aria-label` or an associated `<label>`.

3. **PrimeNG components** must have explicit `[ariaLabel]` or `[ariaLabelledBy]` attributes.
   PrimeNG defaults are not reliable. Example:
   ```html
   <!-- Required -->
   <p-button [ariaLabel]="'SAVE_CHANGES' | translate" />
   <p-dropdown [ariaLabel]="'SELECT_COUNTRY' | translate" />

   <!-- Forbidden — no aria attribute -->
   <p-button />
   ```

4. **Color contrast** ≥ 4.5:1 for normal text, ≥ 3:1 for large text (WCAG AA). Verified
   automatically by the axe `color-contrast` rule.

5. **Keyboard navigation** must be tested in every interactive component spec:
   ```typescript
   it('should activate on Enter key', () => {
     const btn = fixture.nativeElement.querySelector('button') as HTMLElement;
     btn.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter' }));
     expect(actionSpy).toHaveBeenCalled();
   });
   ```

6. **No hardcoded UI strings in templates.** Every visible string uses `| translate`.
   Axe cannot verify that strings are meaningful if they are empty in tests — all strings
   must exist in `assets/i18n/en.json`.

7. **`focus-visible` is never hidden.** The `.skip-link` and `:focus-visible` styles in
   `styles.scss` must not be overridden by component styles.

---

## 8. Code Quality Gates

Each gate runs in CI. A single failure blocks the PR.

### Backend

| Tool | What it checks | Config |
|------|---------------|--------|
| Checkstyle | Google Java Style — formatting, Javadoc on public API, no TODOs | `google_checks.xml` |
| SpotBugs | Null dereference, resource leaks, SQL injection, security bugs | `spotbugs-exclude.xml` |
| OWASP Dependency Check | Known CVEs in all transitive dependencies | Fails on CVSS ≥ 7.0 |
| JaCoCo | Line and branch coverage thresholds | See §6 |

**Rules:**
- Every public class and method **must** have a Javadoc comment.
- `TODO` and `FIXME` comments are **forbidden** in merged code. Checkstyle enforces this.
- No wildcard imports (`import com.example.*`).
- Generated code is excluded from all static analysis tools.

### Frontend

| Tool | What it checks | Config |
|------|---------------|--------|
| ESLint | `@typescript-eslint/no-explicit-any: error`, `no-console: error`, `no-warning-comments: error` | `.eslintrc.json` |
| ESLint template | Accessibility rules, `button-has-type`, `click-events-have-key-events` | `.eslintrc.json` |
| Prettier | Consistent formatting — enforced, not advisory | `.prettierrc` |
| Jest coverage | Statement/function/line thresholds | `jest.config.ts` |

**Rules:**
- `any` is forbidden. Use `unknown` with type guards, or a proper interface.
- `console.log` is forbidden. Use an injectable `LogService` (to be added when logging is needed).
- No hardcoded strings in templates. Use `| translate`.
- Husky `pre-commit` hook runs `lint-staged` on every commit — format violations are fixed
  automatically; lint errors block the commit.

### SonarQube (optional but recommended)

When connected to a SonarQube instance, the quality gate requires:
- 0 blocker issues
- 0 critical security hotspots
- New code coverage ≥ 80%

---

## 9. 12-Factor Application Standard

This application implements all 12 factors from [12factor.net](https://12factor.net).

| Factor | Implementation |
|--------|---------------|
| **I. Codebase** | One repo, tracked in Git, multiple deployments from the same artifact |
| **II. Dependencies** | Maven (backend) and npm (frontend) declare all deps explicitly; no system-level deps |
| **III. Config** | All config via environment variables. `application-{profile}.yml` references `${ENV_VAR}`. No hardcoded URLs or credentials anywhere |
| **IV. Backing services** | PostgreSQL, SQS, S3 are attached resources, swappable via env vars |
| **V. Build/release/run** | Docker multi-stage build separates these three stages. Never modify a deployed image |
| **VI. Processes** | Backend is stateless. No in-memory session state. JWT is stored client-side |
| **VII. Port binding** | Backend exposes port 8080. Frontend nginx exposes port 80. Both self-contained |
| **VIII. Concurrency** | Scaled horizontally via ECS desired_count or Kubernetes HPA |
| **IX. Disposability** | Spring Boot starts in < 30s. Containers handle SIGTERM gracefully |
| **X. Dev/prod parity** | Docker Compose and Helm chart run the same images. LocalStack mirrors AWS |
| **XI. Logs** | All logs to stdout/stderr as structured JSON. No log files written to disk |
| **XII. Admin processes** | Database migrations run as part of application startup (Flyway) |

### Config Environment Variables

| Variable | Required in | Description |
|----------|------------|-------------|
| `SPRING_PROFILES_ACTIVE` | All | Active Spring profile: `local`, `dev`, `staging`, `prod` |
| `DB_URL` | All | JDBC connection URL |
| `DB_USERNAME` | All | Database user |
| `DB_PASSWORD` | All | Database password (from Secrets Manager in cloud) |
| `FRONTEND_ORIGIN` | All | CORS-allowed frontend origin |
| `AWS_ENDPOINT_URL` | local | LocalStack endpoint override |
| `API_BASE_URL` | Frontend | Backend API base URL (injected via `window.__env`) |

---

## 10. Security Standard

### Backend Security

- **Deny-all by default.** `SecurityConfig.java` sets `.anyRequest().authenticated()`.
  Every endpoint that needs to be public is explicitly permitted with a comment explaining
  the business reason.

- **No server-side sessions.** `SessionCreationPolicy.STATELESS`. JWT is used for auth.

- **CORS locked to `FRONTEND_ORIGIN`.** Never `allowedOrigins("*")`. The allowed origin
  is injected from an environment variable.

- **RFC 7807 error responses.** Internal exception details (stack traces, class names,
  SQL errors) are never exposed to clients. `GlobalExceptionHandler` maps all exceptions
  to a safe `ProblemDetail` shape.

- **Flyway manages schema.** Hibernate `ddl-auto: validate` — Hibernate never creates or
  modifies database schema. Migrations are version-controlled, reviewed, and irreversible.

- **OWASP Dependency Check** runs on every PR. CVEs with CVSS ≥ 7.0 fail the build.
  Suppressions require a written justification in `owasp-suppressions.xml`.

### Frontend Security

- **Content Security Policy** set in nginx.conf and Helm chart Ingress annotations.
- **No secrets in source.** API keys and tokens are never committed. `window.__env` is
  populated at runtime by `entrypoint.sh` (Docker) or the Helm `ConfigMap`.
- **`no-explicit-any` ESLint rule** prevents unsafe type coercions that could lead to
  XSS or injection vulnerabilities.

### Infrastructure Security

- **RDS in private subnet.** No public access. Security group allows port 5432 from ECS
  task security group only.
- **IAM least privilege.** ECS task role and execution role grant only the specific
  actions the application requires. No wildcard `*` actions in production.
- **Secrets Manager, not Parameter Store, for credentials.** Automatic rotation is
  supported. Secrets are injected into ECS tasks via the `secrets` block — they never
  appear in CloudTrail logs or environment variable listings.
- **Non-root containers.** Both Docker images run as UID 1000. The Helm chart enforces
  `runAsNonRoot: true` and `readOnlyRootFilesystem: true`.

---

## 11. Observability Standard

Every service emits three signals from day one.

### Logs (stdout, structured JSON)

Logback with `logstash-logback-encoder` outputs every log line as a JSON object:

```json
{
  "timestamp": "2026-05-30T14:23:01.456Z",
  "level": "INFO",
  "service": "webapp",
  "traceId": "abc123",
  "spanId": "def456",
  "message": "User registration completed",
  "userId": "u-789"
}
```

Rules:
- **Never log PII** (email, name, SSN, payment data).
- Log levels: `ERROR` for actionable failures, `WARN` for degraded state, `INFO` for
  significant business events, `DEBUG` for diagnostic detail (disabled in prod).
- `traceId` and `spanId` are populated automatically by Micrometer Tracing.

### Traces (OpenTelemetry / AWS X-Ray)

- Micrometer Tracing with the OTLP bridge exports spans to AWS X-Ray (or any OTLP-compatible
  backend) without changing application code.
- Every inbound HTTP request starts a trace. Downstream DB calls and external service calls
  are child spans.
- Propagation headers (`traceparent`, `X-Amzn-Trace-Id`) are forwarded between services.

### Metrics (Prometheus / CloudWatch)

Spring Boot Actuator exposes `/actuator/metrics` in Prometheus format:
- JVM heap, GC, thread metrics
- HTTP request duration histograms (by path, method, status)
- HikariCP connection pool metrics
- Custom business metrics (add via `MeterRegistry` as features are added)

**Endpoints:**

| Path | Auth | Purpose |
|------|------|---------|
| `/actuator/health` | Public | Liveness + readiness (ECS health check, ALB target group) |
| `/actuator/health/liveness` | Public | Kubernetes liveness probe |
| `/actuator/health/readiness` | Public | Kubernetes readiness probe |
| `/actuator/info` | Public | Build version, git commit SHA |
| `/actuator/metrics` | `ACTUATOR` role | Prometheus scrape target |

---

## 12. AWS Well-Architected Standard

The infrastructure is designed against the AWS Well-Architected Framework five pillars.

| Pillar | Implementation |
|--------|---------------|
| **Operational Excellence** | All infra in Terraform. All deployments via CI. No click-ops. CloudWatch dashboards from Actuator metrics |
| **Security** | Private subnets for RDS. IAM least privilege. Secrets Manager. No public database access. Non-root containers |
| **Reliability** | Multi-AZ RDS in prod. ECS desired_count ≥ 2 in prod. ALB health checks remove unhealthy targets. PodDisruptionBudget in Kubernetes |
| **Performance Efficiency** | CloudFront CDN for frontend. Fargate (no idle EC2). HikariCP connection pool. HPA on Kubernetes |
| **Cost Optimization** | Fargate (pay-per-task-second). CloudFront reduces backend load. RDS autoscaling storage. FARGATE_SPOT capacity provider available |

**Additional rules:**
- Every new AWS service must be added to the relevant Terraform module — not provisioned manually.
- CloudFront is always in front of the frontend S3 bucket. S3 direct access is blocked via bucket
  policy (OAC enforced).
- AWS X-Ray tracing is enabled on all ECS tasks.

---

## 13. Documentation Standard

### What must always be current

| Document | Location | Updated when |
|----------|----------|-------------|
| `CLAUDE.md` | `/` | Any rule, workflow, or standard changes |
| `INTRO.md` | `/` | Any standard is added, changed, or removed |
| `ARC42.md` | `/docs/` | Any architectural change — see trigger table below |
| `ARCHITECTURE.md` | `/docs/` | Any C4 Level 1 or Level 2 change |
| ADRs | `/docs/adr/` | Any non-trivial architectural decision |
| `openapi.yaml` | `/backend/api/src/main/resources/` | Any API change (before implementation) |
| `en.json` | `/frontend/src/assets/i18n/` | Any new UI string |

### ARC42 — When to Update Which Section

`docs/ARC42.md` is structured according to the [ARC42 template](https://arc42.org) and must be
updated in the **same PR** as the code change that invalidates it. The full trigger table is in
`CLAUDE.md` under "ARC42 MAINTENANCE CONTRACT". The summary:

| Change type | ARC42 section(s) |
|-------------|-----------------|
| New external system integrated | §3 Scope and Context, §6 Runtime View |
| New bounded context / feature | §5 Building Block View, §6 Runtime View |
| New infrastructure component | §7 Deployment View, §10 Quality Requirements |
| New crosscutting concern | §8 Crosscutting Concepts |
| New ADR created | §9 Architecture Decisions |
| New risk or accepted debt | §11 Risks and Technical Debt |
| New domain or technical term | §12 Glossary |

To flag a section as stale without time to fix it immediately, add:
```
<!-- ARCHITECTURE-STALE: reason why this section needs updating -->
```
CI (`arc42-check` job) will detect the marker and fail the build, preventing merge.

### ADR Rules

- Format: MADR (see existing ADRs as templates)
- Statuses: `proposed` → `accepted` → `deprecated` → `superseded by [NNNN]`
- Never delete an ADR. Mark it `deprecated` or `superseded`.
- ADR number is sequential (`0001`, `0002`, ...). Never reuse a number.
- An ADR is required for: technology choices, security boundary changes, test strategy changes,
  deployment topology changes, and any deviation from the standards in this document.

### Code Documentation Rules

**Backend Java:**
- Every public class and public method must have a Javadoc comment.
- The comment explains **why** — not what. "Returns the user" is not a Javadoc comment.
- Checkstyle enforces Javadoc presence. CI fails without it.

**Frontend TypeScript:**
- Every public component must have a JSDoc block.
- Every `@Input()` and `@Output()` must be documented inline.

---

## 14. Mandatory Developer Workflow

This order is enforced by convention and by code review. Skipping steps causes downstream
failures (tests written after implementation tend to test the implementation, not the requirement).

```
Step 1 — GHERKIN SCENARIO
  Write the .feature file in /frontend/e2e/features/<bounded-context>/
  Get it reviewed for business accuracy before writing any code.
  ↓
Step 2 — FAILING BDD STEP DEFINITIONS
  Wire the Gherkin steps to Playwright actions.
  Run: the scenario must FAIL (nothing is implemented yet).
  ↓
Step 3 — FAILING UNIT TESTS
  Backend: JUnit 5 in src/test/java/
  Frontend: Jest + jest-axe in *.spec.ts
  Run: tests must FAIL.
  ↓
Step 4 — FAILING INTEGRATION TESTS
  Backend: extend AbstractIntegrationTest, use Testcontainers
  Run: tests must FAIL.
  ↓
Step 5 — IMPLEMENT
  Write the minimum code to make ALL tests pass.
  No more than what the tests require.
  ↓
Step 6 — UPDATE OPENAPI SPEC
  Edit openapi.yaml FIRST.
  Run: mvn generate-sources -pl backend/api && npm run generate-api
  ↓
Step 7 — ADR (if applicable)
  If a non-trivial architectural decision was made, write the ADR.
  ↓
Step 8 — FULL QUALITY GATE
  ./scripts/quality-gate.sh
  All checks must be green before opening a PR.
  ↓
Step 9 — PR + CI
  CI reruns every check. ci-pass job must be green before merge.
```

---

## 15. Enforcement Matrix

A cross-reference of every standard and where it is enforced. "Developer discipline" means the
check relies on code review; everything else is automated.

| Standard | Enforced by | Fails build? |
|----------|------------|--------------|
| Gherkin before implementation | Code review (CLAUDE.md) | No (process) |
| Unit test with axe() per component | jest-axe in spec | Yes (Jest fails) |
| E2E axe scan per page | base-fixture.ts | Yes (Playwright fails) |
| Backend line coverage ≥ 80% | JaCoCo | Yes |
| Backend branch coverage ≥ 75% | JaCoCo | Yes |
| Frontend statement coverage ≥ 80% | Jest coverageThreshold | Yes |
| OpenAPI spec updated before impl | Code review (CLAUDE.md) | No (process) |
| All OpenAPI endpoint fields present | Code review | No (process) |
| `no-explicit-any` TypeScript | ESLint | Yes |
| `no-console` in Angular | ESLint | Yes |
| `no-warning-comments` (TODO/FIXME) | ESLint + Checkstyle | Yes |
| Prettier formatting | ESLint + Husky pre-commit | Yes |
| Javadoc on public API | Checkstyle | Yes |
| Google Java Style | Checkstyle | Yes |
| SpotBugs HIGH/CRITICAL bugs | SpotBugs | Yes |
| OWASP CVEs ≥ 7.0 | OWASP Dependency Check | Yes |
| Config via env vars only | Code review | No (process) |
| Secrets never in source | `git-secrets` (recommended) | Partial |
| Deny-all Spring Security | SecurityConfig.java + integration test | Yes |
| RFC 7807 error shape | GlobalExceptionHandler + API test | Yes |
| Structured JSON logs | logback-spring.xml | No (runtime) |
| Non-root Docker container | Dockerfile + Helm securityContext | Partial (Helm lint) |
| Helm lint passes | CI lint step | Yes |
| `helm template` renders | CI template step | Yes |
| `docker compose up` succeeds | CI E2E setup step | Yes |
| Health endpoint returns 200 | CI E2E wait step | Yes |
| ADR for architectural decisions | Code review | No (process) |
| ARC42 updated in same PR as architectural change | `arc42-check` CI job (ARCHITECTURE-STALE marker) | Yes |
| ARC42 contains no ARCHITECTURE-STALE markers | `arc42-check` CI job | Yes |
| PrimeNG explicit aria attributes | ESLint template/accessibility | Yes |
| ARIA-label on interactive elements | ESLint template/accessibility | Yes |
| Skip-to-content link present | E2E step definition | Yes |
| PDB and HPA in Helm chart | Helm lint + template | Yes |
| No public RDS access | Terraform plan | No (Terraform) |
| IAM least privilege | Terraform plan review | No (process) |
