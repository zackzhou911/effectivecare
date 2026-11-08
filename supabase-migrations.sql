-- ============================================================
-- Effective Care — Supabase SQL Migrations
-- Safe to re-run: all policies wrapped in DO blocks.
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. Add missing column: repair_applications.special_circumstances
-- ────────────────────────────────────────────────────────────
ALTER TABLE repair_applications
  ADD COLUMN IF NOT EXISTS special_circumstances TEXT;


-- ────────────────────────────────────────────────────────────
-- 2. RLS: cash_donations
-- ────────────────────────────────────────────────────────────
ALTER TABLE cash_donations ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='cash_donations' AND policyname='Authenticated users can insert cash donations') THEN
    CREATE POLICY "Authenticated users can insert cash donations" ON cash_donations FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='cash_donations' AND policyname='Users can view own cash donations') THEN
    CREATE POLICY "Users can view own cash donations" ON cash_donations FOR SELECT TO authenticated USING (donor_id = auth.uid());
  END IF;
END $$;


-- ────────────────────────────────────────────────────────────
-- 3. RLS: volunteer_labour
-- ────────────────────────────────────────────────────────────
ALTER TABLE volunteer_labour ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='volunteer_labour' AND policyname='Authenticated users can insert volunteer labour') THEN
    CREATE POLICY "Authenticated users can insert volunteer labour" ON volunteer_labour FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='volunteer_labour' AND policyname='Users can view own volunteer labour') THEN
    CREATE POLICY "Users can view own volunteer labour" ON volunteer_labour FOR SELECT TO authenticated USING (donor_id = auth.uid());
  END IF;
END $$;


-- ────────────────────────────────────────────────────────────
-- 4. RLS: vehicle_messages
-- ────────────────────────────────────────────────────────────
ALTER TABLE vehicle_messages ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='vehicle_messages' AND policyname='Authenticated users can insert vehicle messages') THEN
    CREATE POLICY "Authenticated users can insert vehicle messages" ON vehicle_messages FOR INSERT TO authenticated WITH CHECK (sender_id = auth.uid());
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='vehicle_messages' AND policyname='Authenticated users can read vehicle messages') THEN
    CREATE POLICY "Authenticated users can read vehicle messages" ON vehicle_messages FOR SELECT TO authenticated USING (true);
  END IF;
END $$;


-- ────────────────────────────────────────────────────────────
-- 5. RLS: testimonials
-- ────────────────────────────────────────────────────────────
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='testimonials' AND policyname='Authenticated users can insert testimonials') THEN
    CREATE POLICY "Authenticated users can insert testimonials" ON testimonials FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='testimonials' AND policyname='Public can read testimonials') THEN
    CREATE POLICY "Public can read testimonials" ON testimonials FOR SELECT TO anon, authenticated USING (true);
  END IF;
END $$;


-- ────────────────────────────────────────────────────────────
-- 6. site_stats RLS + seed rows
-- (Table already exists with columns: key, value, updated_at)
-- ────────────────────────────────────────────────────────────
ALTER TABLE site_stats ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='site_stats' AND policyname='Public can read site stats') THEN
    CREATE POLICY "Public can read site stats" ON site_stats FOR SELECT TO anon, authenticated USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='site_stats' AND policyname='Authenticated users can upsert site stats') THEN
    CREATE POLICY "Authenticated users can upsert site stats" ON site_stats FOR ALL TO authenticated USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Seed default rows (skips any that already exist)
INSERT INTO site_stats (key, value)
VALUES
  ('total_donations', 0),
  ('matched_pairs',   0),
  ('families_helped', 0),
  ('cars_repaired',   0),
  ('stats_visible',   1)
ON CONFLICT (key) DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- Done! Reload your portal and admin pages after running.
-- ────────────────────────────────────────────────────────────
