# [Application Name]

> Replace this line with a one-sentence description of what this application does.

## Quickstart (5 commands)

```bash
# 1. Clone and enter the repo
git clone <gitlab-repo-url> && cd <repo-name>

# 2. Start all services locally (backend, frontend, postgres, localstack)
docker compose up --build -d

# 3. Verify backend health
curl http://localhost:8080/actuator/health

# 4. Open frontend
open http://localhost:4200

# 5. Run the full quality gate (mirrors the mandatory GitLab CI pipeline)
./scripts/quality-gate.sh
```

## CI/CD Pipeline

The GitLab CI/CD pipeline (`.gitlab-ci.yml`) is **mandatory** — merge requests cannot be merged
without a green pipeline. The pipeline runs automatically on every push.

| Stage | What runs |
|-------|-----------|
| `validate` | Checkstyle, SpotBugs, ESLint, Prettier, Helm lint, ARC42 staleness |
| `test` | Backend JUnit + JaCoCo · Frontend Jest + coverage |
| `e2e` | Playwright + Cucumber BDD |
| `security` | OWASP dependency check (fails on CVSS ≥ 7.0) |
| `report` | **Allure dashboard** — always runs, even on test failure |
| `build` | Docker images → GitLab Container Registry |
| `deploy` | Helm upgrade (dev: auto · staging/prod: manual) |
| `pages` | GitLab Pages: Allure · API docs · coverage reports |

## Allure Test Dashboard

Every pipeline run produces an Allure dashboard aggregating all test layers:

- **Live URL:** `$CI_PAGES_URL/allure/` (main branch, requires GitLab Pages to be enabled)
- **Local:** after running tests, `cd frontend && npm run allure:generate && npm run allure:open`
- **Failed pipelines:** download the `allure-report` artifact from the GitLab pipeline UI

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Docker | 24+ | Local dev environment |
| Java | 21+ | Backend development |
| Maven | 3.9+ | Backend build |
| Node.js | 20+ | Frontend development |
| npm | 10+ | Frontend package management |
| Helm | 3.15+ | Kubernetes deployment (optional for local dev) |
| Terraform | 1.7+ | Infrastructure provisioning (optional for local dev) |

## Project Structure

```
/
├── .gitlab-ci.yml    # Mandatory GitLab CI/CD pipeline
├── CODEOWNERS        # GitLab merge request approval rules
├── backend/          # Spring Boot Maven multi-module
│   ├── app/          # Main application module (port 8080)
│   ├── api/          # OpenAPI spec + generated stubs
│   └── domain/       # Domain model (no framework deps)
├── frontend/         # Angular 18+ workspace (port 4200)
├── infra/
│   ├── helm/webapp/  # Kubernetes Helm chart (Deployment 2)
│   └── terraform/    # AWS infrastructure
├── docs/
│   ├── ARC42.md      # Living solution architecture (ARC42 template)
│   ├── ARCHITECTURE.md
│   └── adr/          # Architecture Decision Records
├── scripts/
│   └── quality-gate.sh  # Local full quality gate
├── CLAUDE.md         # Master instructions for Claude Code
└── docker-compose.yml   # Local dev stack (Deployment 1)
```

## Development Workflow

See [CLAUDE.md](CLAUDE.md) for the mandatory workflow every developer and Claude Code must follow.

## Architecture

See [docs/ARC42.md](docs/ARC42.md) for the full solution architecture (ARC42 template).
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for C4 diagrams.

## API Documentation

The OpenAPI spec lives at `backend/api/src/main/resources/openapi.yaml`.
Interactive docs (Redoc) are published to `$CI_PAGES_URL/api/` via the GitLab `pages` CI job
on every merge to `main`.

## Contributing

1. Read [CLAUDE.md](CLAUDE.md) — all rules are enforced in CI
2. Create a feature branch: `git checkout -b feature/<ticket-id>-short-description`
3. Follow the mandatory workflow: Gherkin → failing tests → implementation → quality gate
4. Open a Merge Request — the GitLab CI pipeline **must be green** before merge
5. Code Owner approval is required for changes to critical files (see `CODEOWNERS`)

> **Note:** `.github/` is retained for historical reference but is no longer active.
> All CI/CD is managed exclusively via `.gitlab-ci.yml`.
