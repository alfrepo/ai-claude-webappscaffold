// WHY THIS FILE EXISTS: Angular environment configuration.
// Values are read from window.__env at runtime (injected by entrypoint.sh).
// This pattern allows one Docker image to run in dev/staging/prod with different config.
// NEVER hardcode environment-specific URLs or feature flags here.
// To add a new variable: add to AppEnvironment, read it from window.__env, and update env.js.

declare global {
  interface Window {
    __env: AppEnvironment;
  }
}

/** Runtime environment shape — all fields must be provided by env.js or entrypoint.sh. */
export interface AppEnvironment {
  API_BASE_URL: string;
  PRODUCTION: boolean;
}

/** Reads runtime environment from window.__env with safe fallbacks for local dev. */
function getEnvironment(): AppEnvironment {
  const env = window.__env ?? {};
  return {
    API_BASE_URL: (env as Partial<AppEnvironment>).API_BASE_URL ?? 'http://localhost:8080',
    PRODUCTION: (env as Partial<AppEnvironment>).PRODUCTION ?? false,
  };
}

export const environment: AppEnvironment = getEnvironment();
