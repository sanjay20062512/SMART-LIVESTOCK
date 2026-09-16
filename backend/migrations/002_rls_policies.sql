-- ==============================================================================
-- MIGRATION 002: Supabase Row Level Security (RLS) Policies
-- ==============================================================================

-- Enable Row Level Security on all core tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE case_timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE mortality_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE vet_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE samples ENABLE ROW LEVEL SECURITY;
ALTER TABLE vet_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE vaccinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE outbreak_clusters ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisories ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- Helper function: Get current user's profile ID
CREATE OR REPLACE FUNCTION get_current_profile_id()
RETURNS UUID AS $$
    SELECT id FROM profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE;

-- Helper function: Get current user's role
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS user_role AS $$
    SELECT role FROM profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE;

-- ─── 1. PROFILES POLICIES ────────────────────────────────────────────────────

CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth_user_id = auth.uid() OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN'));

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth_user_id = auth.uid());

CREATE POLICY "Enable profile insert during registration"
    ON profiles FOR INSERT
    WITH CHECK (auth_user_id = auth.uid() OR auth.uid() IS NULL);

-- ─── 2. FARMS & ANIMALS POLICIES ─────────────────────────────────────────────

CREATE POLICY "Farmers can manage own farms"
    ON farms FOR ALL
    USING (owner_id = get_current_profile_id() OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN'));

CREATE POLICY "Farmers can view and manage their animals"
    ON animals FOR ALL
    USING (owner_id = get_current_profile_id() OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN'));

-- ─── 3. CASES & TIMELINE POLICIES ────────────────────────────────────────────

-- Farmers see their own cases; Vets see assigned cases or district cases; Govt sees all in district
CREATE POLICY "Farmers view own cases"
    ON cases FOR SELECT
    USING (
        farmer_id = get_current_profile_id()
        OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN', 'LAB_STAFF')
    );

CREATE POLICY "Farmers can submit cases"
    ON cases FOR INSERT
    WITH CHECK (
        farmer_id = get_current_profile_id()
        OR get_current_user_role() IN ('FARMER', 'VETERINARIAN', 'ADMIN')
    );

CREATE POLICY "Vets and Admins can update cases"
    ON cases FOR UPDATE
    USING (
        get_current_user_role() IN ('VETERINARIAN', 'ADMIN')
        OR (get_current_user_role() = 'GOVERNMENT_OFFICER' AND is_escalated_to_govt = TRUE)
    );

CREATE POLICY "Anyone with case access can read timeline"
    ON case_timeline_events FOR SELECT
    USING (
        EXISTS (SELECT 1 FROM cases WHERE cases.id = case_timeline_events.case_id AND (
            cases.farmer_id = get_current_profile_id()
            OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN')
        ))
    );

CREATE POLICY "Authorized users can add timeline event"
    ON case_timeline_events FOR INSERT
    WITH CHECK (
        get_current_user_role() IN ('FARMER', 'VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN')
    );

-- ─── 4. LABORATORY SAMPLES POLICIES ──────────────────────────────────────────

CREATE POLICY "Vets and Lab Staff can view and manage samples"
    ON samples FOR ALL
    USING (
        get_current_user_role() IN ('VETERINARIAN', 'LAB_STAFF', 'GOVERNMENT_OFFICER', 'ADMIN')
        OR EXISTS (SELECT 1 FROM cases WHERE cases.id = samples.case_id AND cases.farmer_id = get_current_profile_id())
    );

-- ─── 5. VACCINATIONS & TREATMENTS POLICIES ───────────────────────────────────

CREATE POLICY "Users can view animal vaccinations"
    ON vaccinations FOR SELECT
    USING (
        EXISTS (SELECT 1 FROM animals WHERE animals.id = vaccinations.animal_id AND animals.owner_id = get_current_profile_id())
        OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN')
    );

CREATE POLICY "Vets and Farmers can log vaccinations"
    ON vaccinations FOR INSERT
    WITH CHECK (
        get_current_user_role() IN ('FARMER', 'VETERINARIAN', 'PARAVET', 'ADMIN')
    );

CREATE POLICY "Vets manage treatments, farmers view"
    ON treatments FOR SELECT
    USING (
        EXISTS (SELECT 1 FROM animals WHERE animals.id = treatments.animal_id AND animals.owner_id = get_current_profile_id())
        OR get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN')
    );

CREATE POLICY "Only Vets can insert/update treatments"
    ON treatments FOR INSERT
    WITH CHECK (
        get_current_user_role() IN ('VETERINARIAN', 'ADMIN')
    );

-- ─── 6. SURVEILLANCE & ADVISORIES POLICIES ───────────────────────────────────

CREATE POLICY "Outbreak clusters visible to Vets and Govt"
    ON outbreak_clusters FOR SELECT
    USING (
        get_current_user_role() IN ('VETERINARIAN', 'GOVERNMENT_OFFICER', 'ADMIN')
    );

CREATE POLICY "Govt and Vets can manage clusters"
    ON outbreak_clusters FOR ALL
    USING (
        get_current_user_role() IN ('GOVERNMENT_OFFICER', 'ADMIN', 'VETERINARIAN')
    );

CREATE POLICY "Everyone can read published advisories"
    ON advisories FOR SELECT
    USING (status = 'PUBLISHED' OR get_current_user_role() IN ('GOVERNMENT_OFFICER', 'ADMIN'));

CREATE POLICY "Govt officers manage advisories"
    ON advisories FOR ALL
    USING (get_current_user_role() IN ('GOVERNMENT_OFFICER', 'ADMIN'));

CREATE POLICY "Users view own alerts"
    ON alerts FOR ALL
    USING (
        recipient_id = get_current_profile_id()
        OR target_role = get_current_user_role()
        OR get_current_user_role() = 'ADMIN'
    );
