# ADR-0005: GitLab as VCS and CI/CD Platform

**Status:** Accepted  
**Date:** 2026-05-31  
**Supersedes:** Part of ADR-0001 (TC-07 — previously GitHub)  
**Deciders:** Platform Team

---

## Context

The project was initially scaffolded with GitHub Actions as the CI/CD platform (ADR-0001, TC-07).
The organisation has standardised on GitLab for all new projects, citing:
- Integrated container registry (GitLab Container Registry) eliminates a separate ECR login step
- GitLab Pages for test dashboards and API docs without GitHub Pages setup
- Merge request pipelines with built-in "Pipelines must succeed" gate at the platform level
- CODEOWNERS enforcement built into GitLab's merge request approval rules
- Single platform for VCS, CI/CD, container registry, and pages — reduces operational surface
- GitLab Environments provide a deployment history view per environment (dev/staging/prod)

## Decision

Migrate from GitHub + GitHub Actions to GitLab + GitLab CI/CD.

**Changed artefacts:**
- `.github/workflows/ci.yml` and `.github/workflows/deploy.yml` → **replaced** by `.gitlab-ci.yml`
- Container registry: GitHub Packages → **GitLab Container Registry** (`$CI_REGISTRY_IMAGE`)
- Branch protection via GitHub Settings → **GitLab protected branches + CODEOWNERS**
- GitHub Pages → **GitLab Pages** (`pages` job, `public/` artifact)
- GitHub Secrets → **GitLab CI/CD Variables** (Project › Settings › CI/CD › Variables)

**Pipeline structure in `.gitlab-ci.yml`:**

| Stage | Mirrors previous GitHub Actions job |
|-------|-------------------------------------|
| `validate` | `backend-lint`, `frontend-lint`, `helm-validate`, `arc42-check` |
| `test` | `backend-test`, `frontend-test` |
| `e2e` | `e2e` |
| `security` | `security-scan` |
| `report` | New — `allure:generate` (mandatory, see ADR-0006) |
| `build` | Docker image build + push |
| `deploy` | Helm deploy per environment |
| `pages` | GitLab Pages: Allure + API docs + coverage |

**Mandatory pipeline enforcement:**
- Enable "Pipelines must succeed" under Project › Settings › Merge requests
- Protect `main` branch: no push, merge requires passing pipeline + Code Owner approval
- CODEOWNERS file defines approval requirements per file path

## Consequences

**Positive:**
- One platform — VCS, CI, registry, pages, environments, CODEOWNERS — reduces context switching
- GitLab Container Registry is automatically authenticated in CI via `$CI_REGISTRY_*` variables
- GitLab Pages URL (`$CI_PAGES_URL`) is available to all jobs — enables Allure report links in executor.json
- `when: always` on the `allure:generate` job means the dashboard is always produced, even on failure
- Deployment history per environment is visible in GitLab's Environments UI

**Negative:**
- `.github/` directory remains in the repository but is inert — mark as deprecated in README
- Teams accustomed to GitHub Actions syntax must learn GitLab CI YAML syntax
- GitLab Container Registry images are tied to the GitLab namespace — migration to another registry requires a `CI_REGISTRY_IMAGE` variable change

**Migration note for the `.github/` directory:**
The `.github/` directory is kept for historical reference but its workflows are no longer
executed. It should be removed in a subsequent cleanup PR once the team has fully transitioned.
Do not update `.github/workflows/` — maintain `.gitlab-ci.yml` only.
