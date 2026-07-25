-- =============================================================
-- PRAMAN: Foreign Employment Agency Verification
-- =============================================================

-- 0. CLEAN SLATE
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS agencies CASCADE;

-- 1. AGENCIES TABLE (admin-managed)
CREATE TABLE agencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  license TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL CHECK (status IN ('verified', 'flagged', 'under_review')),
  location TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. COMPLAINTS TABLE (linked to agencies)
CREATE TABLE complaints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  date TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. REPORTS TABLE (community-submitted, unverified)
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  has_file BOOLEAN NOT NULL DEFAULT false,
  evidence_url TEXT NOT NULL DEFAULT '',
  date TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. INDEXES
CREATE INDEX idx_complaints_agency ON complaints(agency_id);
CREATE INDEX idx_reports_created ON reports(created_at DESC);
CREATE INDEX idx_reports_name ON reports(name);

-- 5. ROW LEVEL SECURITY
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Agencies: public read + update (for auto under_review trigger)
CREATE POLICY "Public can read agencies"
  ON agencies FOR SELECT
  USING (true);

CREATE POLICY "Public can update agencies"
  ON agencies FOR UPDATE
  USING (true);

-- Complaints: public read + insert
CREATE POLICY "Public can read complaints"
  ON complaints FOR SELECT
  USING (true);

CREATE POLICY "Public can insert complaints"
  ON complaints FOR INSERT
  WITH CHECK (true);

-- Reports: public read + insert
CREATE POLICY "Public can read reports"
  ON reports FOR SELECT
  USING (true);

CREATE POLICY "Public can insert reports"
  ON reports FOR INSERT
  WITH CHECK (true);

-- =============================================================
-- 6. AUTO-TRIGGER: When 5+ reports match an agency name,
--    set that agency's status to 'under_review'
-- =============================================================
CREATE OR REPLACE FUNCTION check_report_threshold()
RETURNS TRIGGER AS $$
DECLARE
  report_count BIGINT;
  matched_agency RECORD;
BEGIN
  SELECT COUNT(*) INTO report_count
  FROM reports
  WHERE LOWER(name) = LOWER(NEW.name);

  IF report_count >= 10 THEN
    UPDATE agencies
    SET status = 'under_review'
    WHERE LOWER(name) = LOWER(NEW.name)
      AND status = 'verified';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_report_threshold
  AFTER INSERT ON reports
  FOR EACH ROW
  EXECUTE FUNCTION check_report_threshold();

-- =============================================================
-- 7. SEED DATA
-- =============================================================

INSERT INTO agencies (name, license, status, location) VALUES
  ('Sunrise Global Overseas Pvt. Ltd.', '614/069/070', 'verified', 'Putalisadak, Kathmandu'),
  ('Sun-Rise Global Overseas Consultancy', 'N/A — no valid license on file', 'flagged', 'Claims ''Putalisadak, Kathmandu'' — address unverifiable'),
  ('Himalayan Manpower Services Pvt. Ltd.', '302/058/059', 'verified', 'Gongabu, Kathmandu'),
  ('Everest Career Link Overseas', '781/071/072', 'verified', 'New Baneshwor, Kathmandu'),
  ('Everest Career Bridge International', 'Unregistered entity — flagged on community reports', 'flagged', 'Operates via Facebook ads only, no listed office'),
  ('Annapurna Overseas Employment Pvt. Ltd.', '459/065/066', 'verified', 'Kalanki, Kathmandu'),
  ('Gulf Dream Recruiters', 'No DoFE license found', 'flagged', 'Address changes between postings'),
  ('Lumbini Global Manpower Pvt. Ltd.', '197/056/057', 'verified', 'Butwal, Rupandehi');

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Processing fee took two weeks longer than quoted, but was refundable and fully explained in the contract.', '2 Mar 2025'
FROM agencies WHERE name = 'Sunrise Global Overseas Pvt. Ltd.';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Used a name and logo almost identical to a licensed agency, then asked for NPR 80,000 ''visa guarantee'' fee in cash before any job offer existed.', '18 Jan 2025'
FROM agencies WHERE name = 'Sun-Rise Global Overseas Consultancy';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Phone number listed on their Facebook page was disconnected after payment was made.', '22 Jan 2025'
FROM agencies WHERE name = 'Sun-Rise Global Overseas Consultancy';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Interview was rescheduled three times without clear communication.', '9 Nov 2024'
FROM agencies WHERE name = 'Everest Career Link Overseas';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Promised a Dubai hospitality job with no interview and demanded NPR 150,000 upfront ''training fee''.', '4 Feb 2025'
FROM agencies WHERE name = 'Everest Career Bridge International';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Deleted their Facebook page after multiple people asked for a receipt.', '10 Feb 2025'
FROM agencies WHERE name = 'Everest Career Bridge International';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Same operators previously used the name ''Everest Gulf Careers'' before rebranding.', '15 Feb 2025'
FROM agencies WHERE name = 'Everest Career Bridge International';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Collected passports ''for processing'' and became unreachable for three weeks afterward.', '30 Dec 2024'
FROM agencies WHERE name = 'Gulf Dream Recruiters';

INSERT INTO complaints (agency_id, text, date)
SELECT id, 'Contract terms in Nepali and English didn''t fully match; agency corrected it after being asked in writing.', '5 Jun 2024'
FROM agencies WHERE name = 'Lumbini Global Manpower Pvt. Ltd.';

INSERT INTO reports (name, description, has_file, date) VALUES
  ('Golden Horizon Overseas', 'Contacted me on TikTok offering a Korea factory job with ''no exam needed''. Asked for NPR 40,000 as a ''file registration'' fee via personal eSewa account, not a company account.', true, '20 Jul 2026'),
  ('Prime Gulf Careers Nepal', 'Office address given during the call does not exist at that location in Baneshwor. No signage, no staff recognized the name.', false, '14 Jul 2026');
