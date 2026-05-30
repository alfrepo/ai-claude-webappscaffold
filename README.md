# [Application Name]

> Replace this line with a one-sentence description of what this application does.

## Quickstart (5 commands)

```bash
# 1. Clone and enter the repo
git clone <repo-url> && cd <repo-name>

# 2. Start all services locally (backend, frontend, postgres, localstack)
docker compose up --build -d

# 3. Verify backend health
curl http://localhost:8080/actuator/health

# 4. Open frontend
open http://localhost:4200

# 5. Run the full quality gate
./scripts/quality-gate.sh
```

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Docker | 24+ | Local dev environment |
| Java | 21+ | Backend development |
| Maven | 3.9+ | Backend build |
| Node.js | 20+ | Frontend development |
| npm | 10+ | Frontend package management |
| Terraform | 1.7+ | Infrastructure (optional for local dev) |

## Project Structure

```
/
├── backend/          # Spring Boot Maven multi-module
│   ├── app/          # Main application module (port 8080)
│   ├── api/          # OpenAPI spec + generated stubs
│   └── domain/       # Domain model (no framework deps)
├── frontend/         # Angular 18+ workspace (port 4200)
├── infra/            # Terraform (AWS)
├── docs/             # Architecture docs + ADRs
│   └── adr/
├── .github/
│   └── workflows/    # CI/CD pipelines
├── CLAUDE.md         # Master instructions for Claude Code
└── docker-compose.yml
```

## Development Workflow

See [CLAUDE.md](CLAUDE.md) for the mandatory workflow every developer and Claude Code must follow.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for C4 diagrams.

## API Documentation

The OpenAPI spec lives at `backend/api/src/main/resources/openapi.yaml`.
Interactive docs (Redoc) are published to GitHub Pages on every merge to `main`.

## Contributing

1. Read [CLAUDE.md](CLAUDE.md) — all rules are enforced in CI
2. Create a feature branch: `git checkout -b feature/<ticket-id>-short-description`
3. Follow the mandatory workflow (Gherkin → tests → implementation)
4. Open a PR — CI must be green before merge
