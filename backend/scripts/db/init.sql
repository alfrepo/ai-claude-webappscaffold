-- WHY THIS FILE EXISTS: Runs once when the local PostgreSQL container is first created.
-- Used to set up any database-level settings that Flyway migrations cannot handle
-- (e.g., extensions, roles). Flyway manages all schema migrations after this.
-- This file is mounted into the container via docker-compose.yml.

-- Enable extensions needed by the application
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
