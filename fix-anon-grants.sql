-- Fix: grant anon role write access to team_members and sponsors
-- The admin.html uses the anon key; security is the SHA-256 passphrase gate in the page itself.

-- team_members
GRANT INSERT, UPDATE, DELETE ON TABLE team_members TO anon;
GRANT USAGE, SELECT ON SEQUENCE team_members_id_seq TO anon;

CREATE POLICY "Anon can manage team_members"
  ON team_members FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

-- sponsors
GRANT INSERT, UPDATE, DELETE ON TABLE sponsors TO anon;
GRANT USAGE, SELECT ON SEQUENCE sponsors_id_seq TO anon;

CREATE POLICY "Anon can manage sponsors"
  ON sponsors FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

-- Verify
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_name IN ('team_members','sponsors')
  AND grantee = 'anon'
ORDER BY table_name, privilege_type;
