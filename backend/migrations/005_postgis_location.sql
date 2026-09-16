-- Migration 005: PostGIS Extension, Geospatial Point Column, and Proximity Queries

-- 1. Enable PostGIS Extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Add geography(Point, 4326) column to cases table
ALTER TABLE cases 
ADD COLUMN IF NOT EXISTS geom geography(Point, 4326);

-- 3. Spatial Index for ultra-fast radius & proximity queries
CREATE INDEX IF NOT EXISTS idx_cases_geom ON cases USING GIST (geom);

-- 4. Automatically synchronize geom from latitude & longitude on INSERT or UPDATE
CREATE OR REPLACE FUNCTION set_cases_geom()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    ELSE
        NEW.geom := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_cases_geom ON cases;
CREATE TRIGGER trg_set_cases_geom
BEFORE INSERT OR UPDATE ON cases
FOR EACH ROW
EXECUTE FUNCTION set_cases_geom();

-- 5. Backfill existing cases with coordinates into PostGIS geom
UPDATE cases
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND geom IS NULL;

-- 6. Add geom column to outbreak_clusters for spatial surveillance
ALTER TABLE outbreak_clusters
ADD COLUMN IF NOT EXISTS geom geography(Point, 4326);

CREATE INDEX IF NOT EXISTS idx_outbreak_clusters_geom ON outbreak_clusters USING GIST (geom);

CREATE OR REPLACE FUNCTION set_clusters_geom()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    ELSE
        NEW.geom := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_clusters_geom ON outbreak_clusters;
CREATE TRIGGER trg_set_clusters_geom
BEFORE INSERT OR UPDATE ON outbreak_clusters
FOR EACH ROW
EXECUTE FUNCTION set_clusters_geom();

UPDATE outbreak_clusters
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND geom IS NULL;

-- 7. PostGIS Stored Procedure for Proximity Search
CREATE OR REPLACE FUNCTION get_nearby_cases(
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 10.0,
    limit_count INT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    case_code VARCHAR,
    farmer_id UUID,
    animal_tag VARCHAR,
    species VARCHAR,
    symptoms JSONB,
    risk_level risk_level,
    status case_status,
    village VARCHAR,
    block VARCHAR,
    district VARCHAR,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_km DOUBLE PRECISION,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.case_code,
        c.farmer_id,
        c.animal_tag,
        c.species,
        c.symptoms,
        c.risk_level,
        c.status,
        c.village,
        c.block,
        c.district,
        c.latitude,
        c.longitude,
        ROUND((ST_Distance(c.geom, ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography) / 1000.0)::numeric, 2)::double precision AS distance_km,
        c.created_at
    FROM cases c
    WHERE c.geom IS NOT NULL
      AND ST_DWithin(c.geom, ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography, radius_km * 1000.0)
    ORDER BY distance_km ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;
