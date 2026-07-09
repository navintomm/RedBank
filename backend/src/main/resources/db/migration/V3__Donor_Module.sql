-- Flyway Migration V3: Donor Module Schema

-- 1. Create Enums
CREATE TYPE blood_group_enum AS ENUM (
    'A_POSITIVE', 'A_NEGATIVE',
    'B_POSITIVE', 'B_NEGATIVE',
    'O_POSITIVE', 'O_NEGATIVE',
    'AB_POSITIVE', 'AB_NEGATIVE'
);

CREATE TYPE gender_enum AS ENUM (
    'MALE', 'FEMALE', 'OTHER'
);

CREATE TYPE availability_status_enum AS ENUM (
    'AVAILABLE', 'UNAVAILABLE', 'ON_COOLDOWN'
);

CREATE TYPE verification_level_enum AS ENUM (
    'UNVERIFIED', 'PHONE_VERIFIED', 'DOCUMENT_VERIFIED', 'HOSPITAL_VERIFIED'
);

-- 2. Create Donor Profile Table
CREATE TABLE IF NOT EXISTS donor_profile (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    blood_group blood_group_enum NOT NULL,
    date_of_birth DATE CHECK (date_of_birth < CURRENT_DATE),
    gender gender_enum,
    weight DECIMAL(5,2) CHECK (weight > 0),
    
    district VARCHAR(100),
    city VARCHAR(100),
    latitude DECIMAL(10, 8) CHECK (latitude BETWEEN -90 AND 90),
    longitude DECIMAL(11, 8) CHECK (longitude BETWEEN -180 AND 180),
    
    -- PostGIS Geometry column for spatial queries (SRID 4326 is standard GPS coordinates)
    location GEOMETRY(Point, 4326),
    
    last_donation_date DATE CHECK (last_donation_date <= CURRENT_DATE),
    availability_status availability_status_enum NOT NULL DEFAULT 'UNAVAILABLE',
    verification_level verification_level_enum NOT NULL DEFAULT 'PHONE_VERIFIED',
    
    medical_notes TEXT,
    profile_image_url VARCHAR(512),
    
    -- Audit and Soft Delete
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(128)
);

-- 3. Create Indexes

-- Geospatial Index for fast radius matching (ST_DWithin)
CREATE INDEX IF NOT EXISTS idx_donor_location ON donor_profile USING GIST (location);

-- Index for filtering by blood group during matching
CREATE INDEX IF NOT EXISTS idx_donor_blood_group ON donor_profile (blood_group);

-- Index for fast availability filtering
CREATE INDEX IF NOT EXISTS idx_donor_availability ON donor_profile (availability_status);

-- Composite index for the most common emergency matching query
CREATE INDEX IF NOT EXISTS idx_donor_match_composite ON donor_profile (blood_group, availability_status, is_deleted);

-- 4. Triggers

-- Trigger for automatic location update (optional, but good practice to keep geometry in sync with lat/lng)
CREATE OR REPLACE FUNCTION update_donor_location()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_donor_location
BEFORE INSERT OR UPDATE OF latitude, longitude
ON donor_profile
FOR EACH ROW
EXECUTE FUNCTION update_donor_location();

-- Trigger for automatic updated_at timestamp update
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_donor_profile_updated_at
BEFORE UPDATE ON donor_profile
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
