-- ============================================================
-- effectivecare.ca — Enable RLS on all tables
-- Run this in the Supabase SQL Editor
-- This is SEPARATE from supabase-fix.sql (which created policies)
-- You must BOTH enable RLS AND have a policy for access to work
-- ============================================================

ALTER TABLE site_stats           ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_donations    ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications         ENABLE ROW LEVEL SECURITY;
ALTER TABLE repair_applications  ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials         ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_donations       ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_labour     ENABLE ROW LEVEL SECURITY;
ALTER TABLE syc_updates          ENABLE ROW LEVEL SECURITY;
ALTER TABLE cars_needing_work    ENABLE ROW LEVEL SECURITY;

-- If application_drafts table exists:
DO $$ BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname='public' AND tablename='application_drafts') THEN
    EXECUTE 'ALTER TABLE application_drafts ENABLE ROW LEVEL SECURITY';
  END IF;
END $$;

-- Verify: this should show rls_enabled = true for all your tables
SELECT tablename, rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'site_stats','vehicle_donations','applications','repair_applications',
    'testimonials','cash_donations','volunteer_labour','syc_updates',
    'cars_needing_work'
  )
ORDER BY tablename;
