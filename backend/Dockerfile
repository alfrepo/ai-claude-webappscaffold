# WHY THIS FILE EXISTS: Multi-stage Docker build for the Spring Boot backend.
# Stage 1 (builder): Maven build with full JDK — produces the fat JAR.
# Stage 2 (runtime): Eclipse Temurin 21 JRE — minimal runtime surface.
# The final image runs as a non-root user (appuser) for security.
# HEALTHCHECK is defined here so ECS can detect if the JVM crashes silently.
# To build locally: docker build -t webapp-backend ./backend
# To run locally: use docker-compose.yml at the repo root.

# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /build

# Copy Maven wrapper and POMs first (layer cache: only invalidated on pom.xml changes)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY domain/pom.xml domain/
COPY api/pom.xml api/
COPY app/pom.xml app/

# Download dependencies (cached unless POM changes)
RUN ./mvnw dependency:go-offline -B --no-transfer-progress

# Copy source code
COPY domain/src domain/src
COPY api/src api/src
COPY app/src app/src

# Build, skip tests (tests run separately in CI before Docker build)
RUN ./mvnw package -B --no-transfer-progress -DskipTests

# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime

# Security: create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only the fat JAR from builder
COPY --from=builder /build/app/target/*.jar app.jar

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# JVM flags: container-aware heap sizing, G1GC, structured logging from JVM
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC \
               -Djava.security.egd=file:/dev/./urandom"

EXPOSE 8080

# Health check: ECS uses this to determine task health
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
