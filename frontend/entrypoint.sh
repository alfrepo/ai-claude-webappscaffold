#!/bin/sh
# WHY THIS FILE EXISTS: Docker entrypoint that injects runtime environment variables
# into the Angular app before nginx starts. This allows one Docker image to run
# in dev/staging/prod with different API URLs without rebuilding.
# How it works: overwrites /usr/share/nginx/html/assets/env.js with current env vars.
# To add a new runtime variable: add it to the window.__env block below AND to env.js.

set -e

# Write runtime environment to env.js (overwrites the build-time placeholder)
cat > /usr/share/nginx/html/assets/env.js << EOF
(function (window) {
  window.__env = window.__env || {};
  window.__env.API_BASE_URL = '${API_BASE_URL:-http://localhost:8080}';
  window.__env.PRODUCTION = ${PRODUCTION:-false};
})(window);
EOF

echo "env.js written with API_BASE_URL=${API_BASE_URL:-http://localhost:8080}"

# Start nginx in foreground (required for Docker)
exec nginx -g 'daemon off;'
