# ADR-0002: Contract-First API Design

**Status:** Accepted  
**Date:** 2026-05-30  
**Deciders:** Platform Team

---

## Context

When building REST APIs consumed by a frontend client, there are two common approaches:
1. **Code-first:** Write the implementation, then generate/document the API spec from code annotations
2. **Contract-first:** Write the OpenAPI spec first, then generate server stubs and client code from it

Frontend and backend teams need a stable contract to develop in parallel without blocking each other.

## Decision

We adopt **contract-first API design**:

- `/backend/api/src/main/resources/openapi.yaml` is the single source of truth
- Backend server stubs are generated from the spec using `openapi-generator-maven-plugin`
- Angular HTTP client is generated from the spec using `openapi-generator` CLI
- Hand-written HTTP calls in Angular are forbidden (enforced by ESLint + code review)
- The spec must be updated **before** any implementation starts
- Every endpoint must have: `operationId`, `summary`, `description`, request/response schemas with `example`, and error responses (`400`, `401`, `403`, `404`, `422`, `500`)

## Consequences

**Positive:**
- Frontend and backend can be developed in parallel (frontend mocks generated from spec)
- Breaking API changes are visible in spec diffs before they reach the client
- API documentation is always accurate (generated from actual contract, not from code)
- Consistent error response format (RFC 7807) enforced at contract level

**Negative:**
- Requires discipline to update spec before implementation (enforced via mandatory workflow in CLAUDE.md)
- Generated code in `target/` must be excluded from `.gitignore` and quality gates
- Some OpenAPI generator limitations require workarounds for complex schemas

**Alternatives Considered:**
- **SpringDoc annotation-based (code-first):** Rejected — spec accuracy depends on developer discipline, and the spec lags behind implementation
- **GraphQL:** Rejected — REST is sufficient for this application's API surface; GraphQL adds complexity without benefit at this scale
