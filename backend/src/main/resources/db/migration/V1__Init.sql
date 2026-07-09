-- Flyway Migration V1: Initial Setup
-- Note: Requires PostGIS extension to be enabled on the database

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Note: Remaining schema implementation deferred per implementation blueprint.
