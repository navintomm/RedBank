-- Flyway Migration V4: Emergency Request Module Schema

-- ==========================================
-- 1. Create Enums
-- ==========================================

-- Tracks the strict state machine of the emergency workflow
CREATE TYPE emergency_status_enum AS ENUM (
    'DRAFT', 
    'CREATED', 
    'SEARCHING', 
    'NOTIFICATIONS_SENT', 
    'AWAITING_RESPONSES', 
    'ACCEPTED', 
    'DONOR_TRAVELLING', 
    'DONATION_IN_PROGRESS', 
    'COMPLETED', 
    'CANCELLED', 
    'EXPIRED', 
    'FAILED', 
    'NO_SHOW'
);

-- Priority levels dictating urgency and system limits overrides
CREATE TYPE emergency_priority_enum AS ENUM (
    'PLANNED',
    'SCHEDULED',
    'EMERGENCY',
    'CRITICAL',
    'MASS_CASUALTY'
);

-- Origin of the request for tracking and future scaling
CREATE TYPE request_source_enum AS ENUM (
    'INDIVIDUAL',
    'HOSPITAL',
    'BLOOD_BANK',
    'NGO_DRIVE'
);

-- Type of blood requirement
CREATE TYPE emergency_type_enum AS ENUM (
    'WHOLE_BLOOD',
    'PLASMA',
    'PLATELETS',
    'RED_BLOOD_CELLS'
);

-- Represents the state of a specific notification dispatched to a donor
CREATE TYPE notification_status_enum AS ENUM (
    'QUEUED',
    'SENT',
    'DELIVERED',
    'READ',
    'FAILED',
    'EXPIRED'
);

-- ==========================================
-- 2. Create Tables
-- ==========================================

-- Core table representing a blood request. Contains patient details, hospital location, and state.
CREATE TABLE IF NOT EXISTS emergency_request (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    hospital_id UUID, -- Nullable for future Hospital B2B integration
    
    patient_name VARCHAR(128) NOT NULL,
    blood_group blood_group_enum NOT NULL,
    emergency_type emergency_type_enum NOT NULL DEFAULT 'WHOLE_BLOOD',
    units_required INTEGER NOT NULL CHECK (units_required > 0),
    
    hospital_name VARCHAR(256) NOT NULL,
    hospital_address TEXT,
    city VARCHAR(100) NOT NULL,
    pincode VARCHAR(20),
    
    -- Hospital Location (Geometry for ST_DWithin spatial queries)
    latitude DECIMAL(10, 8) CHECK (latitude BETWEEN -90 AND 90),
    longitude DECIMAL(11, 8) CHECK (longitude BETWEEN -180 AND 180),
    hospital_location GEOMETRY(Point, 4326),
    
    -- Workflow Data
    status emergency_status_enum NOT NULL DEFAULT 'DRAFT',
    priority emergency_priority_enum NOT NULL DEFAULT 'EMERGENCY',
    source request_source_enum NOT NULL DEFAULT 'INDIVIDUAL',
    
    -- Cancellation & Failure Tracking
    failure_reason VARCHAR(512),
    cancel_reason VARCHAR(512),
    
    -- Search Strategy
    current_search_tier INTEGER DEFAULT 1, -- 1 (<15m), 2 (<30m), 3 (<60m)
    
    -- Optimistic Locking for Concurrency
    -- Crucial for handling the "Race Condition" when multiple donors accept simultaneously
    version INTEGER NOT NULL DEFAULT 0,
    
    -- Audit & Lifecycle Timestamps
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Workflow Timeline Timestamps
    accepted_at TIMESTAMP WITH TIME ZONE,
    travelling_at TIMESTAMP WITH TIME ZONE,
    arrived_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE -- Populated when COMPLETED, CANCELLED, FAILED, or EXPIRED
);

-- Append-only audit log tracking every state transition of an emergency request
CREATE TABLE IF NOT EXISTS emergency_request_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES emergency_request(id) ON DELETE CASCADE,
    
    previous_status emergency_status_enum,
    new_status emergency_status_enum NOT NULL,
    
    event VARCHAR(64), -- The event that triggered the transition
    actor_type VARCHAR(50), -- e.g., SYSTEM, REQUESTER, DONOR, ADMIN
    actor_id UUID, -- Nullable for SYSTEM
    
    transition_reason VARCHAR(256), -- e.g., "Max radius reached", "Timeout waiting for donor", "No Show"
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tracks every FCM push notification dispatched to candidate donors. 
-- Used for analytical conversion rates and ensuring no duplicate pings.
CREATE TABLE IF NOT EXISTS emergency_request_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES emergency_request(id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    status notification_status_enum NOT NULL DEFAULT 'QUEUED',
    search_tier INTEGER NOT NULL, -- Which radius/time tier triggered this ping
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    
    -- Ensure we don't notify the same donor twice for the exact same request
    UNIQUE(request_id, donor_id)
);

-- The binding contract when a Donor ACCEPTs a request.
CREATE TABLE IF NOT EXISTS emergency_request_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES emergency_request(id) ON DELETE CASCADE,
    donor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Captures travel estimates to trigger NO_SHOW timeouts
    estimated_travel_time_mins INTEGER,
    estimated_arrival TIMESTAMP WITH TIME ZONE,
    actual_arrival TIMESTAMP WITH TIME ZONE,
    
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- False if cancelled by donor or marked as no-show
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Time of acceptance
    completed_at TIMESTAMP WITH TIME ZONE, -- Time transitioned to COMPLETED
    
    CONSTRAINT chk_travel_time CHECK (estimated_travel_time_mins > 0)
);

-- ==========================================
-- 3. Indexes
-- ==========================================

-- Geospatial index on hospital location. Future-proofs the DB for clustering and visualization.
CREATE INDEX IF NOT EXISTS idx_emergency_hospital_loc ON emergency_request USING GIST (hospital_location);

-- Partial Index: Lightning-fast lookups for active requests only (ignores millions of past completed requests)
CREATE INDEX IF NOT EXISTS idx_emergency_active ON emergency_request (status) 
WHERE status NOT IN ('COMPLETED', 'CANCELLED', 'EXPIRED', 'FAILED');

-- Standard Foreign Key index
CREATE INDEX IF NOT EXISTS idx_emergency_requester ON emergency_request (requester_id);

-- Composite Index: Speeds up queries like "Show me all UNREAD notifications for User X"
CREATE INDEX IF NOT EXISTS idx_notifications_donor_status ON emergency_request_notifications (donor_id, status);

-- Partial Unique Index: Strictly enforces that a request can ONLY have 1 active assignment at any given time.
CREATE UNIQUE INDEX IF NOT EXISTS uidx_active_assignment ON emergency_request_assignments (request_id) 
WHERE is_active = TRUE;

-- ==========================================
-- 4. Triggers
-- ==========================================

-- Trigger to auto-update PostGIS geometry column whenever lat/lng changes
CREATE OR REPLACE FUNCTION update_hospital_location()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.hospital_location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_hospital_location
BEFORE INSERT OR UPDATE OF latitude, longitude
ON emergency_request
FOR EACH ROW
EXECUTE FUNCTION update_hospital_location();

-- Trigger for auto-updating updated_at (Reusing the `update_timestamp` function defined in V3)
CREATE TRIGGER trg_emergency_request_updated_at
BEFORE UPDATE ON emergency_request
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
