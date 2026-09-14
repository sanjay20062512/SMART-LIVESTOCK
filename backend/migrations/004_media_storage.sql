-- ==============================================================================
-- MIGRATION 004: Media Storage & Voice Transcript Setup
-- ==============================================================================

-- 1. Ensure storage bucket for livestock media exists
-- This can be run in Supabase SQL editor:
INSERT INTO storage.buckets (id, name, public)
VALUES ('livestock-media', 'livestock-media', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Storage policy for public read access to livestock-media
DO $$ BEGIN
    CREATE POLICY "Public Read Access on livestock-media"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'livestock-media');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 3. Storage policy for authenticated / service role insert to livestock-media
DO $$ BEGIN
    CREATE POLICY "Allow Upload on livestock-media"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'livestock-media');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 4. Ensure voice_transcript column exists on cases table (optional enhancement)
DO $$ BEGIN
    ALTER TABLE cases ADD COLUMN IF NOT EXISTS voice_transcript TEXT;
EXCEPTION WHEN duplicate_column THEN null; END $$;
