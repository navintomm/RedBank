-- Flyway Migration V7: Add missing columns to Emergency Request
-- Adds patient_age and patient_gender which were introduced in the Entity but missing from schema

ALTER TABLE emergency_request
ADD COLUMN patient_age INTEGER,
ADD COLUMN patient_gender gender_enum;
