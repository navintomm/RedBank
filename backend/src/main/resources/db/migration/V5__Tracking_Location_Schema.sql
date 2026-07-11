-- V5__Tracking_Location_Schema.sql
CREATE TABLE tracking_location (
    id UUID PRIMARY KEY,
    emergency_request_id UUID NOT NULL REFERENCES emergency_requests(id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION,
    speed DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tracking_emergency_id ON tracking_location(emergency_request_id);
CREATE INDEX idx_tracking_timestamp ON tracking_location(timestamp);
