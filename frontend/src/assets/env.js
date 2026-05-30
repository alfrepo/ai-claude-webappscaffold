// WHY THIS FILE EXISTS: Runtime environment variable injection for local development.
// In Docker (production/staging), entrypoint.sh overwrites this file with actual values
// from Docker environment variables, so the Angular app gets runtime config without rebuild.
// For local dev (ng serve), this file provides the default values.
// To add a new runtime variable: add it here AND to entrypoint.sh AND to AppEnvironment.
(function (window) {
  window.__env = window.__env || {};
  window.__env.API_BASE_URL = 'http://localhost:8080';
  window.__env.PRODUCTION = false;
})(window);
