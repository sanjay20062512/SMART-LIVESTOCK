-- ==============================================================================
-- MIGRATION 001: Initial Schema for Smart Livestock Health Surveillance System
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── ENUMS ───────────────────────────────────────────────────────────────────

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM (
        'FARMER',
        'VETERINARIAN',
        'PARAVET',
        'LAB_STAFF',
        'GOVERNMENT_OFFICER',
        'ADMIN'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE animal_species AS ENUM (
        'COW',
        'BUFFALO',
        'GOAT',
        'SHEEP',
        'POULTRY',
        'PIG',
        'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE animal_gender AS ENUM (
        'MALE',
        'FEMALE',
        'UNKNOWN'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE health_status AS ENUM (
        'HEALTHY',
        'UNDER_MONITORING',
        'ACTIVE_CASE',
        'CRITICAL',
        'RECOVERED',
        'DECEASED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE risk_level AS ENUM (
        'LOW',
        'MEDIUM',
        'HIGH',
        'CRITICAL'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE case_status AS ENUM (
        'SUBMITTED',
        'UNDER_REVIEW',
        'VET_ASSIGNED',
        'VISIT_SCHEDULED',
        'INVESTIGATION',
        'SAMPLE_COLLECTED',
        'LAB_REFERRED',
        'TREATMENT_STARTED',
        'FOLLOW_UP_DUE',
        'ESCALATED',
        'MONITORING',
        'CONTAINED',
        'CASE_CLOSED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE sample_type AS ENUM (
        'BLOOD',
        'FAECAL',
        'NASAL_SWAB',
        'TISSUE',
        'MILK',
        'URINE',
        'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE sample_status AS ENUM (
        'RECOMMENDED',
        'COLLECTED',
        'SENT_TO_LAB',
        'RECEIVED_AT_LAB',
        'TESTING_IN_PROGRESS',
        'RESULT_AVAILABLE',
        'REJECTED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE vaccination_status AS ENUM (
        'DUE',
        'UPCOMING',
        'COMPLETED',
        'OVERDUE',
        'DEFERRED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE cluster_risk AS ENUM (
        'LOW',
        'MEDIUM',
        'HIGH'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE cluster_status AS ENUM (
        'NEW',
        'INVESTIGATION',
        'MONITORING',
        'RESOLVED',
        'ESCALATED',
        'CONTAINED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE advisory_status AS ENUM (
        'DRAFT',
        'PUBLISHED',
        'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE advisory_target AS ENUM (
        'ALL',
        'DISTRICT',
        'BLOCK',
        'VILLAGE'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE alert_severity AS ENUM (
        'INFO',
        'WARNING',
        'HIGH',
        'CRITICAL'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ─── TABLES ──────────────────────────────────────────────────────────────────

-- 1. Locations Hierarchy
CREATE TABLE IF NOT EXISTS locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    state VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    block VARCHAR(100) NOT NULL,
    village VARCHAR(100) NOT NULL,
    pincode VARCHAR(10),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_location_entry UNIQUE (state, district, block, village)
);

-- 2. User Profiles
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID UNIQUE, -- linked to auth.users if Supabase Auth is active
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(150),
    role user_role NOT NULL DEFAULT 'FARMER',
    preferred_language VARCHAR(10) DEFAULT 'en',
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    state VARCHAR(100),
    district VARCHAR(100),
    block VARCHAR(100),
    village VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Farms
CREATE TABLE IF NOT EXISTS farms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    farm_name VARCHAR(150) NOT NULL,
    farm_size DECIMAL(8, 2),
    farm_size_unit VARCHAR(20) DEFAULT 'Acres',
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    livestock_types TEXT[], -- Array of strings e.g. {'Cow', 'Goat'}
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Animals
CREATE TABLE IF NOT EXISTS animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    ear_tag VARCHAR(50) NOT NULL,
    species animal_species NOT NULL,
    breed VARCHAR(100),
    gender animal_gender NOT NULL DEFAULT 'FEMALE',
    age_category VARCHAR(50), -- e.g. '2–5 years'
    health_status health_status NOT NULL DEFAULT 'HEALTHY',
    location VARCHAR(200),
    last_health_report TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_animal_farm_tag UNIQUE (farm_id, ear_tag)
);

-- 5. Cases (Central Disease Surveillance Entity)
CREATE TABLE IF NOT EXISTS cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_code VARCHAR(30) UNIQUE NOT NULL, -- e.g. 'CASE-2026-001'
    reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(id) ON DELETE SET NULL,
    animal_id UUID REFERENCES animals(id) ON DELETE SET NULL,
    animal_tag VARCHAR(50) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(100),
    gender VARCHAR(20),
    age VARCHAR(50),
    symptoms JSONB NOT NULL DEFAULT '[]'::jsonb,
    duration VARCHAR(50),
    eating_status VARCHAR(50),
    drinking_status VARCHAR(50),
    affected_count VARCHAR(20) DEFAULT '1',
    other_animals_affected VARCHAR(20),
    nearby_farms_affected VARCHAR(20),
    risk_score INT DEFAULT 0,
    risk_level risk_level NOT NULL DEFAULT 'LOW',
    status case_status NOT NULL DEFAULT 'SUBMITTED',
    description TEXT,
    has_voice_note BOOLEAN DEFAULT FALSE,
    voice_note_url TEXT,
    has_photo BOOLEAN DEFAULT FALSE,
    photo_urls TEXT[],
    has_video BOOLEAN DEFAULT FALSE,
    video_url TEXT,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    village VARCHAR(100),
    block VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    assigned_vet_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    assigned_vet_name VARCHAR(150),
    visit_scheduled_date TIMESTAMPTZ,
    clinical_observation TEXT,
    treatment_summary TEXT,
    is_escalated_to_govt BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Case Timeline Events
CREATE TABLE IF NOT EXISTS case_timeline_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    actor VARCHAR(100),
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Mortality Reports
CREATE TABLE IF NOT EXISTS mortality_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_code VARCHAR(30) UNIQUE NOT NULL,
    reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animals(id) ON DELETE SET NULL,
    species animal_species NOT NULL,
    number_affected INT NOT NULL DEFAULT 1,
    date_of_death DATE NOT NULL DEFAULT CURRENT_DATE,
    time_of_death TIME,
    symptoms_before_death JSONB DEFAULT '[]'::jsonb,
    description TEXT,
    has_photo BOOLEAN DEFAULT FALSE,
    photo_url TEXT,
    location VARCHAR(200),
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    related_case_id UUID REFERENCES cases(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Vet Visit Requests (Farmer Initiated)
CREATE TABLE IF NOT EXISTS vet_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_code VARCHAR(30) UNIQUE NOT NULL,
    farmer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animals(id) ON DELETE SET NULL,
    animal_tag VARCHAR(50),
    reason VARCHAR(150) NOT NULL,
    description TEXT,
    preferred_date DATE NOT NULL,
    preferred_time_slot VARCHAR(50) DEFAULT 'Morning',
    assigned_vet_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'OPEN',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Laboratory Samples & Diagnostic Referrals
CREATE TABLE IF NOT EXISTS samples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sample_code VARCHAR(30) UNIQUE NOT NULL,
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animals(id) ON DELETE SET NULL,
    animal_tag VARCHAR(50),
    sample_type sample_type NOT NULL,
    collection_date DATE NOT NULL DEFAULT CURRENT_DATE,
    collection_location VARCHAR(200),
    reason TEXT NOT NULL,
    laboratory VARCHAR(200) NOT NULL,
    status sample_status NOT NULL DEFAULT 'RECOMMENDED',
    result_summary TEXT,
    result_date DATE,
    collected_by_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    collected_by VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Vet Scheduled / Completed Visits
CREATE TABLE IF NOT EXISTS vet_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    vet_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    vet_name VARCHAR(150) NOT NULL,
    scheduled_date TIMESTAMPTZ NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    findings TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Vaccinations
CREATE TABLE IF NOT EXISTS vaccinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
    animal_tag VARCHAR(50) NOT NULL,
    vaccine_name VARCHAR(150) NOT NULL,
    administered_date DATE NOT NULL,
    next_due_date DATE,
    status vaccination_status NOT NULL DEFAULT 'COMPLETED',
    veterinarian_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    veterinarian_name VARCHAR(150),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Clinical Treatments
CREATE TABLE IF NOT EXISTS treatments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id) ON DELETE SET NULL,
    animal_id UUID NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
    animal_tag VARCHAR(50) NOT NULL,
    veterinarian_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    veterinarian_name VARCHAR(150),
    disease_diagnosis VARCHAR(150),
    medication TEXT NOT NULL,
    dosage VARCHAR(100),
    instructions TEXT,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    outcome VARCHAR(50) DEFAULT 'ONGOING',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Outbreak Clusters (Surveillance)
CREATE TABLE IF NOT EXISTS outbreak_clusters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cluster_code VARCHAR(30) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    location VARCHAR(200) NOT NULL,
    village VARCHAR(100),
    block VARCHAR(100),
    district VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL DEFAULT 'Maharashtra',
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    risk_level cluster_risk NOT NULL DEFAULT 'MEDIUM',
    species VARCHAR(100) NOT NULL,
    report_count INT DEFAULT 1,
    animal_count INT DEFAULT 1,
    mortality INT DEFAULT 0,
    symptoms JSONB DEFAULT '[]'::jsonb,
    suspected_disease VARCHAR(150),
    description TEXT,
    status cluster_status NOT NULL DEFAULT 'NEW',
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. Government Advisories
CREATE TABLE IF NOT EXISTS advisories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    advisory_code VARCHAR(30) UNIQUE NOT NULL,
    title VARCHAR(250) NOT NULL,
    message TEXT NOT NULL,
    target advisory_target NOT NULL DEFAULT 'ALL',
    target_location VARCHAR(150),
    target_location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    language VARCHAR(10) DEFAULT 'en',
    created_by VARCHAR(150) NOT NULL,
    created_by_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    status advisory_status NOT NULL DEFAULT 'DRAFT',
    published_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. User Alerts & Notifications
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(100) NOT NULL, -- e.g. 'HIGH_RISK_HEALTH_ALERT', 'GOVERNMENT_ADVISORY'
    title VARCHAR(250) NOT NULL,
    message TEXT NOT NULL,
    severity alert_severity NOT NULL DEFAULT 'INFO',
    recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    target_role user_role,
    related_id VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    actor_role VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(50) NOT NULL,
    details JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── INDEXES ─────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_profiles_phone ON profiles(phone);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_animals_farm ON animals(farm_id);
CREATE INDEX IF NOT EXISTS idx_animals_ear_tag ON animals(ear_tag);
CREATE INDEX IF NOT EXISTS idx_cases_status ON cases(status);
CREATE INDEX IF NOT EXISTS idx_cases_risk_level ON cases(risk_level);
CREATE INDEX IF NOT EXISTS idx_cases_district ON cases(district);
CREATE INDEX IF NOT EXISTS idx_cases_assigned_vet ON cases(assigned_vet_id);
CREATE INDEX IF NOT EXISTS idx_samples_case ON samples(case_id);
CREATE INDEX IF NOT EXISTS idx_vaccinations_animal ON vaccinations(animal_id);
CREATE INDEX IF NOT EXISTS idx_clusters_district ON outbreak_clusters(district);
CREATE INDEX IF NOT EXISTS idx_clusters_risk ON outbreak_clusters(risk_level);
CREATE INDEX IF NOT EXISTS idx_alerts_recipient ON alerts(recipient_id, is_read);
