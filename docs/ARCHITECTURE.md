# Architecture Documentation

## C4 Level 1 — System Context

```mermaid
C4Context
  title System Context Diagram

  Person(user, "End User", "Uses the web application via a browser")
  Person(admin, "Administrator", "Manages the system via the admin interface")

  System(webapp, "WebApp", "Angular SPA + Spring Boot API serving business functionality")

  System_Ext(email, "Email Service", "AWS SES — sends transactional emails")
  System_Ext(monitoring, "Monitoring", "CloudWatch + X-Ray — logs, traces, metrics")
  System_Ext(auth, "Identity Provider", "Future: Cognito or external IdP for authentication")

  Rel(user, webapp, "Uses", "HTTPS")
  Rel(admin, webapp, "Manages", "HTTPS")
  Rel(webapp, email, "Sends emails via", "HTTPS/SMTP")
  Rel(webapp, monitoring, "Sends logs and traces to", "HTTPS/OTLP")
  Rel(webapp, auth, "Authenticates via", "OAuth2/OIDC")
```

## C4 Level 2 — Container Diagram

```mermaid
C4Container
  title Container Diagram

  Person(user, "End User", "Browser")

  System_Boundary(aws, "AWS Account") {
    Container(cdn, "CloudFront", "CDN", "Serves the Angular SPA from S3. Adds security headers and HTTPS.")
    Container(s3, "S3 Bucket", "Object Storage", "Hosts compiled Angular static files (HTML, JS, CSS)")
    Container(alb, "Application Load Balancer", "AWS ALB", "Routes HTTPS traffic to the backend ECS service")
    Container(backend, "Backend API", "Java 21 / Spring Boot 3 / ECS Fargate", "Implements REST API. Stateless. Runs as non-root in Fargate.")
    ContainerDb(rds, "PostgreSQL", "AWS RDS PostgreSQL 16", "Primary data store. Private subnet. Encrypted at rest.")
    Container(secrets, "Secrets Manager", "AWS Secrets Manager", "Stores database passwords, JWT secrets. Never in source code.")
    Container(localstack, "LocalStack", "Docker (local dev only)", "Mocks AWS services for local development")
  }

  Rel(user, cdn, "Requests SPA", "HTTPS/443")
  Rel(cdn, s3, "Serves static files", "S3 protocol")
  Rel(user, alb, "API calls from browser", "HTTPS/443")
  Rel(alb, backend, "Forwards to ECS task", "HTTP/8080")
  Rel(backend, rds, "Reads/writes data", "JDBC/5432")
  Rel(backend, secrets, "Reads secrets at startup", "HTTPS")
```

## Data Flow

### Request Lifecycle (Happy Path)

```
Browser → CloudFront → S3 (static files)
Browser → CloudFront/ALB → ECS Backend
ECS Backend → Secrets Manager (startup only, cached)
ECS Backend → RDS PostgreSQL
ECS Backend → CloudWatch Logs (structured JSON)
ECS Backend → X-Ray (distributed traces)
```

### Authentication Flow (to be implemented)

```
Browser → Backend /api/v1/auth/login
Backend validates credentials
Backend returns JWT
Browser stores JWT in memory (not localStorage)
Browser sends JWT in Authorization: Bearer header on all API calls
Backend validates JWT on each request (stateless)
```

## Security Boundaries

| Boundary | What crosses it | How secured |
|----------|----------------|-------------|
| Internet → CloudFront | SPA assets, API calls | HTTPS only, CloudFront WAF (optional) |
| Internet → ALB | API calls | HTTPS only, Security Group restricts to 443 |
| ALB → ECS | API forwarding | HTTP (private VPC), Security Group restricts to ALB SG |
| ECS → RDS | Database queries | JDBC/TLS, Security Group restricts to ECS SG, Private subnet |
| ECS → Secrets Manager | Secret retrieval | HTTPS, IAM least-privilege task role |

## Module Structure (Backend)

```
backend/
├── domain/     ← Pure Java. No framework deps. Business rules live here.
│               ← Inward-facing: knows nothing about the outside world.
├── api/        ← OpenAPI spec + generated interfaces.
│               ← The contract. Neither domain nor app directly.
└── app/        ← Spring Boot wiring. Implements api/ interfaces.
                ← Knows about domain/ and api/. Never the other way.
```

This follows **Hexagonal Architecture (Ports and Adapters)**:
- Domain = core (no dependencies)
- API = port (interface definition)
- App = adapter (Spring Boot implementation)

## Key Technical Decisions

See `/docs/adr/` for all Architecture Decision Records:

| ADR | Topic |
|-----|-------|
| [0001](adr/0001-technology-stack.md) | Technology stack selection |
| [0002](adr/0002-contract-first-api-design.md) | Contract-first API with OpenAPI |
| [0003](adr/0003-test-strategy.md) | Three-layer test pyramid |
| [0004](adr/0004-accessibility-strategy.md) | WCAG 2.1 AA accessibility enforcement |
