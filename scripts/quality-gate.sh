#!/usr/bin/env bash
# WHY THIS FILE EXISTS: Runs the full quality gate locally before pushing.
# Mirrors exactly what the GitLab CI pipeline runs — if this passes, CI will pass.
# Run before opening a merge request: ./scripts/quality-gate.sh
# Exit code 0 = all checks passed; non-zero = something failed (output will tell you what).
#
# Options:
#   RUN_E2E=true    Include Playwright E2E tests (requires Docker)
#   OPEN_ALLURE=true  Open the Allure dashboard in a browser after generation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
info() { echo -e "${YELLOW}→ $1${NC}"; }
section() { echo -e "\n${BLUE}══ $1 ══${NC}"; }

echo "════════════════════════════════════════════"
echo "  WebApp Full Quality Gate (mirrors GitLab CI)"
echo "════════════════════════════════════════════"

# ── ARC42 check ───────────────────────────────────────────────────────────────
section "ARC42 Staleness"
if grep -q "ARCHITECTURE-STALE" "$ROOT_DIR/docs/ARC42.md" 2>/dev/null; then
  fail "docs/ARC42.md contains ARCHITECTURE-STALE markers — update before pushing"
fi
pass "ARC42 has no stale markers"

# ── Helm validation ───────────────────────────────────────────────────────────
section "Helm Lint + Template Render"
if command -v helm &>/dev/null; then
  helm lint "$ROOT_DIR/infra/helm/webapp/" \
    --values "$ROOT_DIR/infra/helm/webapp/values.yaml" -q \
    && pass "Helm lint" || fail "Helm lint failed"
  helm template webapp "$ROOT_DIR/infra/helm/webapp/" \
    --values "$ROOT_DIR/infra/helm/webapp/values.yaml" \
    --set backend.image.tag=local-test > /dev/null \
    && pass "Helm template render" || fail "Helm template render failed"
else
  echo -e "${YELLOW}  helm not found — skipping Helm validation${NC}"
fi

# ── Backend Checks ────────────────────────────────────────────────────────────
section "Backend: Lint (Checkstyle + SpotBugs)"
(cd "$ROOT_DIR/backend" && ./mvnw checkstyle:check spotbugs:check -B --no-transfer-progress -q) \
  && pass "Backend lint" || fail "Backend lint failed"

section "Backend: Tests + JaCoCo + Allure results"
(cd "$ROOT_DIR/backend" && ./mvnw verify -B --no-transfer-progress -q) \
  && pass "Backend tests + coverage" || fail "Backend tests or coverage gate failed"

# ── Frontend Checks ───────────────────────────────────────────────────────────
section "Frontend: Lint (ESLint + Prettier)"
(cd "$ROOT_DIR/frontend" && npm run lint) \
  && pass "Frontend ESLint" || fail "Frontend ESLint failed"
(cd "$ROOT_DIR/frontend" && npm run format:check) \
  && pass "Frontend Prettier" || fail "Frontend formatting failed — run: cd frontend && npm run format"

section "Frontend: Tests + Jest Coverage + Allure results"
(cd "$ROOT_DIR/frontend" && npm run test:ci) \
  && pass "Frontend tests + coverage" || fail "Frontend tests or coverage gate failed"

# ── E2E (optional — requires running stack) ───────────────────────────────────
if [[ "${RUN_E2E:-false}" == "true" ]]; then
  section "E2E: Playwright + Cucumber BDD"
  info "Starting docker-compose stack..."
  docker compose -f "$ROOT_DIR/docker-compose.yml" up -d --build

  info "Waiting for backend health..."
  timeout 120 bash -c 'until curl -sf http://localhost:8080/actuator/health > /dev/null; do sleep 3; done'

  (cd "$ROOT_DIR/frontend" && npm run e2e) \
    && pass "E2E tests" || fail "E2E tests failed"

  docker compose -f "$ROOT_DIR/docker-compose.yml" down
else
  echo -e "${YELLOW}  E2E tests skipped (set RUN_E2E=true to include)${NC}"
fi

# ── Allure Dashboard (MANDATORY) ──────────────────────────────────────────────
section "Allure Dashboard Generation (mandatory)"
ALLURE_RESULTS="$ROOT_DIR/allure-results-local"
mkdir -p "$ALLURE_RESULTS"

# Collect backend results
BACKEND_RESULTS=$(find "$ROOT_DIR/backend" -path "*/target/allure-results/*" -type f 2>/dev/null | wc -l)
if [[ $BACKEND_RESULTS -gt 0 ]]; then
  find "$ROOT_DIR/backend" -path "*/target/allure-results/*" -exec cp {} "$ALLURE_RESULTS/" \; 2>/dev/null
  info "Collected $BACKEND_RESULTS backend Allure result files"
fi

# Collect frontend results
FRONTEND_RESULTS=$(find "$ROOT_DIR/frontend/allure-results" -type f 2>/dev/null | wc -l)
if [[ $FRONTEND_RESULTS -gt 0 ]]; then
  cp -r "$ROOT_DIR/frontend/allure-results/"* "$ALLURE_RESULTS/" 2>/dev/null
  info "Collected $FRONTEND_RESULTS frontend Allure result files"
fi

TOTAL_RESULTS=$(find "$ALLURE_RESULTS" -name "*.json" 2>/dev/null | wc -l)
if [[ $TOTAL_RESULTS -eq 0 ]]; then
  fail "No Allure results found — run tests first before generating the dashboard"
fi

# Generate the Allure report
if command -v allure &>/dev/null; then
  allure generate "$ALLURE_RESULTS" --clean -o "$ROOT_DIR/allure-report-local"
  pass "Allure dashboard generated → allure-report-local/"
  if [[ "${OPEN_ALLURE:-false}" == "true" ]]; then
    allure open "$ROOT_DIR/allure-report-local"
  fi
else
  # Fallback: use npx allure-commandline
  (cd "$ROOT_DIR/frontend" && npx allure generate "$ALLURE_RESULTS" --clean -o "$ROOT_DIR/allure-report-local") \
    && pass "Allure dashboard generated → allure-report-local/" \
    || fail "Allure generation failed — install allure CLI or run: npm install -g allure-commandline"
fi

# Clean up temp results dir
rm -rf "$ALLURE_RESULTS"

echo ""
echo "════════════════════════════════════════════"
echo -e "${GREEN}  All quality gate checks passed!${NC}"
echo "════════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "  1. git add -p && git commit"
echo "  2. git push origin <branch>"
echo "  3. Open a GitLab Merge Request"
echo "  4. Pipeline must pass before merge (mandatory)"
echo ""
if [[ "${OPEN_ALLURE:-false}" != "true" ]]; then
  echo "  Tip: OPEN_ALLURE=true ./scripts/quality-gate.sh to open the dashboard"
fi
