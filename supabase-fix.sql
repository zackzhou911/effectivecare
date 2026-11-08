-- ============================================================
-- effectivecare.ca — Supabase fix SQL
-- Run this in the Supabase SQL Editor (all at once)
-- ============================================================

-- 1. Secure public stats function (no private table access from browser)
CREATE OR REPLACE FUNCTION public.get_public_stats()
RETURNS json LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT json_build_object(
    'total_donations', (SELECT count(*) FROM vehicle_donations),
    'matched_pairs',   (SELECT count(*) FROM vehicle_donations WHERE matched_family_id IS NOT NULL),
    'families_helped', (SELECT count(*) FROM applications WHERE status IN ('delivered','matched')),
    'cars_repaired',   (SELECT count(*) FROM repair_applications WHERE status = 'completed')
  );
$$;
REVOKE ALL ON FUNCTION public.get_public_stats() FROM public;
GRANT EXECUTE ON FUNCTION public.get_public_stats() TO anon, authenticated;

-- 2. Clear seed zeros so live counts are used instead of manual overrides
UPDATE site_stats SET value = NULL
WHERE key IN ('total_donations','matched_pairs','families_helped','cars_repaired');

-- 3. RLS policies for tables missing them
--    (skip if you already ran these; they will error harmlessly if duplicate)

-- vehicle_donations
CREATE POLICY "anon_all" ON vehicle_donations FOR ALL TO anon USING (true) WITH CHECK (true);

-- applications
CREATE POLICY "anon_all" ON applications FOR ALL TO anon USING (true) WITH CHECK (true);

-- repair_applications
CREATE POLICY "anon_all" ON repair_applications FOR ALL TO anon USING (true) WITH CHECK (true);

-- site_stats
CREATE POLICY "anon_all" ON site_stats FOR ALL TO anon USING (true) WITH CHECK (true);

-- testimonials
CREATE POLICY "anon_all" ON testimonials FOR ALL TO anon USING (true) WITH CHECK (true);

-- cash_donations
CREATE POLICY "anon_all" ON cash_donations FOR ALL TO anon USING (true) WITH CHECK (true);

-- volunteer_labour
CREATE POLICY "anon_all" ON volunteer_labour FOR ALL TO anon USING (true) WITH CHECK (true);

-- syc_updates
CREATE POLICY "anon_all" ON syc_updates FOR ALL TO anon USING (true) WITH CHECK (true);

-- cars_needing_work
CREATE POLICY "anon_all" ON cars_needing_work FOR ALL TO anon USING (true) WITH CHECK (true);

-- application_drafts (if it exists)
DO $$ BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname='public' AND tablename='application_drafts') THEN
    EXECUTE 'CREATE POLICY "anon_all" ON application_drafts FOR ALL TO anon USING (true) WITH CHECK (true)';
  END IF;
END $$;
