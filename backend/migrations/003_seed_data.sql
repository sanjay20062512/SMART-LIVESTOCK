-- ==============================================================================
-- MIGRATION 003: Maharashtra Pilot Seed Data (DEMO ONLY)
-- ==============================================================================

-- 1. Locations: Maharashtra -> Pune -> Haveli -> Uruli Kanchan & others
INSERT INTO locations (id, state, district, block, village, pincode, latitude, longitude)
VALUES 
    ('11111111-1111-1111-1111-111111111101', 'Maharashtra', 'Pune', 'Haveli', 'Uruli Kanchan', '412202', 18.4870000, 74.1330000),
    ('11111111-1111-1111-1111-111111111102', 'Maharashtra', 'Pune', 'Haveli', 'Loni Kalbhor', '412201', 18.4900000, 74.0200000),
    ('11111111-1111-1111-1111-111111111103', 'Maharashtra', 'Pune', 'Baramati', 'Malegaon', '413115', 18.1500000, 74.5800000),
    ('11111111-1111-1111-1111-111111111104', 'Maharashtra', 'Ahmednagar', 'Rahata', 'Shirdi', '423109', 19.7600000, 74.4700000)
ON CONFLICT (state, district, block, village) DO NOTHING;

-- 2. Demo Profiles
-- Farmer: Ramesh Pawar
INSERT INTO profiles (id, full_name, phone, email, role, preferred_language, location_id, state, district, block, village)
VALUES 
    ('22222222-2222-2222-2222-222222222201', 'Ramesh Pawar', '9876543210', 'farmer@example.com', 'FARMER', 'en', '11111111-1111-1111-1111-111111111101', 'Maharashtra', 'Pune', 'Haveli', 'Uruli Kanchan')
ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;

-- Veterinarian: Dr. Rajesh Kumar (VET001)
INSERT INTO profiles (id, full_name, phone, email, role, preferred_language, location_id, state, district, block, village)
VALUES 
    ('22222222-2222-2222-2222-222222222202', 'Dr. Rajesh Kumar', '9822001122', 'dr.rajesh@vet.gov.in', 'VETERINARIAN', 'en', '11111111-1111-1111-1111-111111111101', 'Maharashtra', 'Pune', 'Haveli', 'Uruli Kanchan')
ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;

-- Government Officer: District Animal Husbandry Officer (GOV001)
INSERT INTO profiles (id, full_name, phone, email, role, preferred_language, location_id, state, district, block, village)
VALUES 
    ('22222222-2222-2222-2222-222222222203', 'Dr. Anil Deshmukh', '9823004455', 'dahopune@maharashtra.gov.in', 'GOVERNMENT_OFFICER', 'en', '11111111-1111-1111-1111-111111111101', 'Maharashtra', 'Pune', 'Haveli', 'Pune City')
ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;

-- 3. Demo Farm: Green Meadows Farm
INSERT INTO farms (id, owner_id, farm_name, farm_size, farm_size_unit, location_id, latitude, longitude, livestock_types)
VALUES 
    ('33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'Green Meadows Farm', 5.0, 'Acres', '11111111-1111-1111-1111-111111111101', 18.4870, 74.1330, ARRAY['Cow', 'Goat'])
ON CONFLICT DO NOTHING;

-- 4. Demo Animals
INSERT INTO animals (id, farm_id, owner_id, ear_tag, species, breed, gender, age_category, health_status, location)
VALUES 
    ('44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'C001', 'COW', 'Jersey', 'FEMALE', '2–5 years', 'ACTIVE_CASE', 'Uruli Kanchan'),
    ('44444444-4444-4444-4444-444444444402', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'C002', 'COW', 'Holstein Friesian (HF)', 'FEMALE', '5–10 years', 'UNDER_MONITORING', 'Uruli Kanchan'),
    ('44444444-4444-4444-4444-444444444403', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'G001', 'GOAT', 'Boer', 'MALE', '1–2 years', 'HEALTHY', 'Uruli Kanchan')
ON CONFLICT DO NOTHING;

-- 5. Demo Vaccinations
INSERT INTO vaccinations (id, animal_id, animal_tag, vaccine_name, administered_date, next_due_date, status, veterinarian_id, veterinarian_name)
VALUES 
    ('55555555-5555-5555-5555-555555555501', '44444444-4444-4444-4444-444444444401', 'C001', 'FMD Vaccine', CURRENT_DATE - INTERVAL '180 days', CURRENT_DATE + INTERVAL '15 days', 'DUE', '22222222-2222-2222-2222-222222222202', 'Dr. Rajesh Kumar'),
    ('55555555-5555-5555-5555-555555555502', '44444444-4444-4444-4444-444444444402', 'C002', 'HS Vaccine', CURRENT_DATE - INTERVAL '90 days', CURRENT_DATE + INTERVAL '90 days', 'UPCOMING', '22222222-2222-2222-2222-222222222202', 'Dr. Rajesh Kumar')
ON CONFLICT DO NOTHING;

-- 6. Demo Primary Case: CASE001 (High Risk in Uruli Kanchan)
INSERT INTO cases (
    id, case_code, reporter_id, farmer_id, farm_id, animal_id, animal_tag, species, breed, age,
    symptoms, duration, eating_status, drinking_status, affected_count,
    risk_score, risk_level, status, description, has_voice_note, has_photo,
    village, block, district, state, assigned_vet_id, assigned_vet_name, visit_scheduled_date
) VALUES (
    '66666666-6666-6666-6666-666666666601', 'CASE001',
    '22222222-2222-2222-2222-222222222201', '22222222-2222-2222-2222-222222222201',
    '33333333-3333-3333-3333-333333333301', '44444444-4444-4444-4444-444444444401',
    'C001', 'Cow', 'Jersey', '2–5 years',
    '["Fever", "Not eating", "Diarrhea"]'::jsonb, '2–3 days', 'Less than usual', 'Less than usual', '3',
    82, 'HIGH', 'TREATMENT_STARTED', 'Cow has developed sudden high fever and blister-like lesions on mouth.',
    TRUE, TRUE,
    'Uruli Kanchan', 'Haveli', 'Pune', 'Maharashtra',
    '22222222-2222-2222-2222-222222222202', 'Dr. Rajesh Kumar', CURRENT_TIMESTAMP + INTERVAL '4 hours'
) ON CONFLICT (case_code) DO NOTHING;

-- Case Timeline
INSERT INTO case_timeline_events (case_id, status, description, actor, actor_id)
VALUES 
    ('66666666-6666-6666-6666-666666666601', 'Report Submitted', 'Farmer submitted health report for Cow C001.', 'Farmer', '22222222-2222-2222-2222-222222222201'),
    ('66666666-6666-6666-6666-666666666601', 'Risk Assessed', 'Automated Triage: HIGH Risk (Score 82). Recommended immediate isolation.', 'System', NULL),
    ('66666666-6666-6666-6666-666666666601', 'Vet Assigned', 'Dr. Rajesh Kumar accepted case assignment.', 'Veterinarian', '22222222-2222-2222-2222-222222222202'),
    ('66666666-6666-6666-6666-666666666601', 'Visit Scheduled', 'On-site clinical examination scheduled.', 'Veterinarian', '22222222-2222-2222-2222-222222222202')
ON CONFLICT DO NOTHING;

-- 7. Outbreak Cluster
INSERT INTO outbreak_clusters (
    id, cluster_code, name, location, village, block, district, state,
    risk_level, species, report_count, animal_count, mortality, symptoms, suspected_disease, description, status, created_by
) VALUES (
    '77777777-7777-7777-7777-777777777701', 'CLU001',
    'Uruli Kanchan Bovine Cluster', 'Uruli Kanchan, Haveli, Pune', 'Uruli Kanchan', 'Haveli', 'Pune', 'Maharashtra',
    'HIGH', 'Cattle', 3, 7, 1,
    '["Fever", "Not eating", "Diarrhea", "Skin lesions"]'::jsonb,
    'Suspected Foot-and-Mouth Disease (FMD)',
    'Cluster of 3 independent cases with acute fever and vesicle lesions reported within 3km radius.',
    'ESCALATED', 'Dr. Rajesh Kumar'
) ON CONFLICT (cluster_code) DO NOTHING;

-- 8. Government Advisory
INSERT INTO advisories (
    id, advisory_code, title, message, target, target_location, language, created_by, created_by_id, status, published_at
) VALUES (
    '88888888-8888-8888-8888-888888888801', 'ADV001',
    'Precautionary Livestock Advisory: Pune District',
    'Increased cases of high fever reported in Haveli block. Isolate any animals showing salivation or foot lesions immediately. Avoid moving livestock between villages.',
    'DISTRICT', 'Pune', 'en', 'Dr. Anil Deshmukh', '22222222-2222-2222-2222-222222222203',
    'PUBLISHED', CURRENT_TIMESTAMP
) ON CONFLICT (advisory_code) DO NOTHING;

-- 9. Active Farmer Alert
INSERT INTO alerts (
    id, category, title, message, severity, recipient_id, target_role, related_id, is_read
) VALUES (
    '99999999-9999-9999-9999-999999999901', 'HIGH_RISK_HEALTH_ALERT',
    'High Risk: Cow C001',
    'High fever and lesions detected. Maintain strict quarantine and ensure clean separate drinking water.',
    'HIGH', '22222222-2222-2222-2222-222222222201', 'FARMER', 'CASE001', FALSE
) ON CONFLICT DO NOTHING;
