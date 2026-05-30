# ADR-0001: Technology Stack

**Status:** Accepted  
**Date:** 2026-05-30  
**Deciders:** Platform Team

---

## Context

We need to build a production-grade web application. We must choose a technology stack that:
- Is widely adopted with a large talent pool
- Has strong enterprise support and long-term maintenance guarantees
- Supports our AWS cloud target
- Enables high code quality and testability
- Meets WCAG 2.1 AA accessibility requirements

## Decision

We adopt the following stack:

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Backend language | Java 21 (LTS) | Virtual threads (Project Loom), strong enterprise ecosystem, long LTS support |
| Backend framework | Spring Boot 3.x | Industry standard, native AWS SDK support, excellent testing tools |
| Build | Maven multi-module | Enforces module boundaries (domain/api/app), well-understood in enterprise |
| Frontend framework | Angular 18+ | Strong TypeScript integration, built-in accessibility support, large ecosystem |
| UI components | PrimeNG + PrimeFlex | Comprehensive WCAG-aware component library with Angular-first support |
| API | REST + OpenAPI 3.1 | Contract-first development, strong tooling ecosystem for code generation |
| Database | PostgreSQL 16 | ACID compliant, rich JSON support, excellent AWS RDS support |
| Cloud | AWS (ECS Fargate, RDS, S3, CloudFront) | Organization's existing AWS expertise and contracts |
| IaC | Terraform | Multi-cloud capable, large module ecosystem, state management |
| CI/CD | GitHub Actions | Already using GitHub; tight PR integration |

## Consequences

**Positive:**
- Java 21 virtual threads enable high concurrency without reactive programming complexity
- Angular's strict TypeScript mode catches errors at compile time
- PrimeNG provides accessible components, reducing a11y implementation burden
- Maven multi-module enforces clean architecture boundaries

**Negative:**
- Java has a higher cold-start time than Node.js or Go (mitigated by keeping containers warm)
- Angular's bundle size requires careful lazy-loading strategy
- Terraform state management adds operational overhead (mitigated by S3 backend + DynamoDB locking)

**Risks:**
- PrimeNG accessibility defaults can be incomplete — all components require explicit aria attributes (enforced by CLAUDE.md)
