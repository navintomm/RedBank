-- Flyway Migration V6: Prevent Duplicate Assignments
-- Adds a strictly unique constraint ensuring a single donor cannot be assigned multiple times to the exact same request

ALTER TABLE emergency_request_assignments 
ADD CONSTRAINT uq_request_donor UNIQUE (request_id, donor_id);
