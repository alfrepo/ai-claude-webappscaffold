-- WHY THIS FILE EXISTS: Initial Flyway migration — creates the baseline schema.
-- Flyway runs migrations in version order on startup.
-- Naming convention: V{version}__{description}.sql
-- NEVER modify an existing migration file after it has been applied to any environment.
-- Always create a new Vn+1 migration file for changes.

-- Enable UUID extension (used for all primary keys)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Schema version tracking (Flyway manages this table automatically)
-- This comment documents the intent; the table is created by Flyway, not here.

-- Example: audit timestamp columns (add to all entity tables as a convention)
-- Every table should include created_at, updated_at, created_by, updated_by
-- Add domain tables in subsequent migrations (V2, V3, etc.)

-- Placeholder: add your domain tables in V2__<description>.sql
SELECT 1; -- no-op placeholder so this migration is valid SQL
