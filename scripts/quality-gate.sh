#!/usr/bin/env bash
# WHY THIS FILE EXISTS: Runs the full quality gate locally before committing.
# Mirrors exactly what CI runs — if this passes locally, CI will pass.
# Run this script before opening a PR: ./scripts/quality-gate.sh
# Exit code 0 = all checks passed; non-zero = something failed (output will tell you what).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
info() { echo -e "${YELLOW}→ $1${NC}"; }

echo "================================================"
echo "  Running Full Quality Gate"
echo "================================================"

# ── Backend Checks ────────────────────────────────────────────────────────────
info "Backend: Checkstyle + SpotBugs"
(cd "$ROOT_DIR/backend" && ./mvnw checkstyle:check spotbugs:check -B --no-transfer-progress -q) \
  && pass "Backend lint" || fail "Backend lint failed"

info "Backend: Tests + JaCoCo coverage gate"
(cd "$ROOT_DIR/backend" && ./mvnw verify -B --no-transfer-progress -q) \
  && pass "Backend tests + coverage" || fail "Backend tests or coverage gate failed"

# ── Frontend Checks ───────────────────────────────────────────────────────────
info "Frontend: ESLint"
(cd "$ROOT_DIR/frontend" && npm run lint) \
  && pass "Frontend ESLint" || fail "Frontend ESLint failed"

info "Frontend: Prettier format check"
(cd "$ROOT_DIR/frontend" && npm run format:check) \
  && pass "Frontend Prettier" || fail "Frontend formatting failed — run: npm run format"

info "Frontend: Jest tests + coverage gate"
(cd "$ROOT_DIR/frontend" && npm run test:ci) \
  && pass "Frontend tests + coverage" || fail "Frontend tests or coverage gate failed"

# ── E2E (optional — requires running stack) ───────────────────────────────────
if [[ "${RUN_E2E:-false}" == "true" ]]; then
  info "E2E: Starting docker-compose stack"
  docker compose -f "$ROOT_DIR/docker-compose.yml" up -d --build

  info "Waiting for backend health..."
  timeout 120 bash -c 'until curl -sf http://localhost:8080/actuator/health > /dev/null; do sleep 3; done'

  info "E2E: Playwright + Cucumber tests"
  (cd "$ROOT_DIR/frontend" && npm run e2e) \
    && pass "E2E tests" || fail "E2E tests failed"

  docker compose -f "$ROOT_DIR/docker-compose.yml" down
else
  echo -e "${YELLOW}  E2E tests skipped (set RUN_E2E=true to include)${NC}"
fi

echo ""
echo "================================================"
echo -e "${GREEN}  All quality gate checks passed!${NC}"
echo "================================================"
