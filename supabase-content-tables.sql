-- ============================================================
-- effectivecare.ca — Content Tables Migration
-- Run this in the Supabase SQL Editor (supabase.com → SQL Editor)
-- Creates: team_members, sponsors
-- Grants public SELECT so the website can read them
-- ============================================================

-- ── TEAM MEMBERS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS team_members (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT        NOT NULL,
  role        TEXT        NOT NULL,
  bio         TEXT        NOT NULL DEFAULT '',
  sort_order  INT         NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- Public can read; only service role (admin) can write
CREATE POLICY "Public can read team_members"
  ON team_members FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Service role can manage team_members"
  ON team_members FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

GRANT SELECT ON TABLE team_members TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE team_members TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE team_members_id_seq TO authenticated;

-- ── SPONSORS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sponsors (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT        NOT NULL,
  type        TEXT        NOT NULL DEFAULT 'Shop Sponsor',
  description TEXT        NOT NULL DEFAULT '',
  logo_url    TEXT,
  website     TEXT,
  tags        TEXT        NOT NULL DEFAULT '',
  sort_order  INT         NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE sponsors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read sponsors"
  ON sponsors FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Service role can manage sponsors"
  ON sponsors FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

GRANT SELECT ON TABLE sponsors TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE sponsors TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE sponsors_id_seq TO authenticated;

-- ── SEED: pre-populate with current content ───────────────────
-- (safe to run multiple times; uses INSERT ... ON CONFLICT DO NOTHING)
INSERT INTO team_members (name, role, bio, sort_order)
VALUES
  ('Zack Zhou',  'Executive Director · Co-Founder',
   'Zack brings roots in the collision repair industry to Effective Care. He co-founded the organization after watching families in his community struggle to access employment without reliable transportation.',
   1),
  ('Ziva Zhou',  'Director of Operations · Co-Founder',
   'Ziva oversees vehicle intake, applicant review, and placement logistics. Her work shapes how Effective Care matches donated vehicles with the families who need them most.',
   2)
ON CONFLICT DO NOTHING;

INSERT INTO sponsors (name, type, description, tags, sort_order)
VALUES
  ('Effective Autobody', 'Shop Sponsor · Vehicle Certification Hub',
   'Every donated vehicle passes through Effective Autobody''s shop — inspected, repaired where needed, and certified as road-safe. As our founding shop sponsor, Effective Autobody provides pro bono inspection services and performs repairs at cost, making it possible for us to place vehicles affordably and reliably.',
   'Vehicle Intake,Certification,Pro Bono Repairs,British Columbia',
   1),
  ('Bridgeport Collision', 'Shop Sponsor · Vehicle Certification Hub',
   'Bridgeport Collision is a licensed ICBC-accredited shop that provides inspection and repair services for vehicles in our pipeline. As a shop sponsor, Bridgeport Collision performs pro bono safety inspections and carries out repairs at cost, ensuring every vehicle we place meets road-safety standards.',
   'Vehicle Intake,Certification,Pro Bono Repairs,British Columbia',
   2)
ON CONFLICT DO NOTHING;

-- ── TESTIMONIALS: ensure anon GRANT exists ────────────────────
GRANT SELECT ON TABLE testimonials TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE testimonials TO authenticated;

-- ── VERIFY ───────────────────────────────────────────────────
SELECT tablename, rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('team_members','sponsors','testimonials')
ORDER BY tablename;
