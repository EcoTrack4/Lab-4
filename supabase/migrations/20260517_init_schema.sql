-- ECOTRACK NAMIBIA — SUPABASE SCHEMA & RLS
-- Date: 2026-05-17
-- Platform: PostgreSQL via Supabase

-- ============================================================================
-- AUTO-UPDATE TRIGGER FUNCTION
-- ============================================================================
-- This function updates the updated_at column to the current timestamp.
-- Used on all mutable tables to keep audit trails current.
-- SECURITY DEFINER is not needed here — trigger runs as table owner.

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TABLE: profiles
-- ============================================================================
-- Extends Supabase auth.users with application-specific metadata.
-- One row per registered user. Never physically deleted — deactivated only.
-- 
-- KEY DESIGN DECISIONS:
-- - id references auth.users(id) to maintain foreign key integrity
-- - role column controls access to admin-only features
-- - email is denormalized for quick lookups (matches auth.users email)
-- - no deleted_at: profiles are deactivated, not soft-deleted

CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Index for role-based queries
CREATE INDEX idx_profiles_role ON public.profiles(role);

-- Trigger: auto-update timestamps
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Enable RLS on profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTIONS (defined after tables exist)
-- ============================================================================
-- is_admin() checks if the current authenticated user has the 'admin' role.
-- Used in RLS policies to grant admin-only access.
-- SECURITY DEFINER allows the function to bypass the caller's permissions.

CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- RLS POLICY: SELECT — user reads own profile
-- Rationale: every user needs to read their own profile to display name/avatar.
-- Threat model: prevents reading other users' profiles, including email.
CREATE POLICY "profiles_select_own"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

-- RLS POLICY: SELECT — admin reads all profiles
-- Rationale: admin panel requires visibility into all users.
-- Threat model: only users with role='admin' in the database can read all rows.
CREATE POLICY "profiles_select_admin"
  ON public.profiles FOR SELECT
  USING (is_admin());

-- RLS POLICY: UPDATE — user updates own profile only
-- Rationale: users must be able to update name, avatar, etc.
-- Threat model: prevents updating other users' profiles.
-- Note: role updates are prevented by trigger (see handle_role_update below).
CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Note: INSERT is NOT allowed on profiles table via client.
-- Profiles are auto-created by a trigger on auth.users INSERT (see below).

-- ============================================================================
-- TABLE: user_data
-- ============================================================================
-- Application-specific user-generated content.
-- For EcoTrack: stores Schedule G returns, hunting activity, etc.
-- Soft-delete enabled: deleted_at is set, not physically removed.
--
-- Extend this table with domain-specific columns:
-- - hunting_permit_id: reference to permit in Namibia system
-- - species_harvested: array or FK to species table
-- - quantity: number harvested
-- - location: GPS coordinates or area name
-- - notes: free-text field

CREATE TABLE public.user_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  hunting_permit_id TEXT,
  species_harvested TEXT,
  quantity INT,
  location JSONB, -- { "lat": float, "lng": float, "area_name": string }
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- Index for fast user_data lookups
CREATE INDEX idx_user_data_user_id ON public.user_data(user_id);
CREATE INDEX idx_user_data_deleted_at ON public.user_data(deleted_at);

-- Trigger: auto-update timestamps
CREATE TRIGGER user_data_updated_at
  BEFORE UPDATE ON public.user_data
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Enable RLS
ALTER TABLE public.user_data ENABLE ROW LEVEL SECURITY;

-- RLS POLICY: SELECT — user reads own non-deleted data only
-- Rationale: user views only their own hunting records and returns.
-- Threat model: prevents cross-user data leakage; soft-deletes are invisible to owner.
CREATE POLICY "user_data_select_own"
  ON public.user_data FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

-- RLS POLICY: SELECT — admin reads all data including soft-deleted
-- Rationale: admin needs full audit trail, including deleted records.
-- Threat model: is_admin() ensures only database-validated admins access this.
CREATE POLICY "user_data_select_admin"
  ON public.user_data FOR SELECT
  USING (is_admin());

-- RLS POLICY: INSERT — user inserts into own records only
-- Rationale: user creates their own hunting records.
-- Threat model: prevents inserting records claiming to be another user.
CREATE POLICY "user_data_insert_own"
  ON public.user_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS POLICY: UPDATE — user updates own non-deleted data
-- Rationale: user corrects their own records before submission.
-- Threat model: prevents modifying already-deleted records or other users' data.
CREATE POLICY "user_data_update_own"
  ON public.user_data FOR UPDATE
  USING (auth.uid() = user_id AND deleted_at IS NULL)
  WITH CHECK (auth.uid() = user_id AND deleted_at IS NULL);

-- RLS POLICY: DELETE — block physical deletes (soft-delete enforced)
-- Rationale: all deletes must be audit-logged via deleted_at timestamp.
-- Threat model: prevents hard-deletes that would hide historical data; users must use UPDATE to set deleted_at.
-- Note: even admins cannot physically DELETE; they use UPDATE to set deleted_at.
CREATE POLICY "user_data_no_delete"
  ON public.user_data FOR DELETE
  USING (false);

-- ============================================================================
-- TABLE: ai_usage_log
-- ============================================================================
-- Audit trail for all AI proxy calls (OpenAI Chat Completions).
-- Also used to enforce rate limiting: max N calls per user per time window.
-- Never updated or deleted by client — only inserted by Edge Function.
--
-- Key decision: tokens are cached at insert time so we can bill accurately
-- without re-querying OpenAI.

CREATE TABLE public.ai_usage_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  prompt_tokens INT NOT NULL DEFAULT 0,
  completion_tokens INT NOT NULL DEFAULT 0,
  total_tokens INT NOT NULL DEFAULT 0,
  model TEXT NOT NULL,
  called_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Index for rate limit lookups: user_id + called_at
CREATE INDEX idx_ai_usage_log_user_called_at ON public.ai_usage_log(user_id, called_at);

-- Trigger: auto-update timestamps
CREATE TRIGGER ai_usage_log_updated_at
  BEFORE UPDATE ON public.ai_usage_log
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Enable RLS
ALTER TABLE public.ai_usage_log ENABLE ROW LEVEL SECURITY;

-- RLS POLICY: SELECT — user reads own logs only
-- Rationale: user views their own AI usage history and billing info.
-- Threat model: prevents reading other users' AI call history.
CREATE POLICY "ai_usage_log_select_own"
  ON public.ai_usage_log FOR SELECT
  USING (auth.uid() = user_id);

-- RLS POLICY: SELECT — admin reads all logs
-- Rationale: admin monitors platform-wide AI usage for billing and abuse detection.
-- Threat model: is_admin() restricts to validated admins only.
CREATE POLICY "ai_usage_log_select_admin"
  ON public.ai_usage_log FOR SELECT
  USING (is_admin());

-- RLS POLICY: INSERT — DENY from client
-- Rationale: only the Edge Function (service role) inserts; client cannot.
-- Threat model: prevents user from logging fake AI calls or bypassing rate limits.
-- Note: service role key bypasses RLS, so this policy effectively blocks anon key.
CREATE POLICY "ai_usage_log_no_client_insert"
  ON public.ai_usage_log FOR INSERT
  WITH CHECK (false);

-- RLS POLICY: UPDATE — DENY all
-- Rationale: logs are immutable after insertion for audit integrity.
-- Threat model: prevents modifying historical call records.
CREATE POLICY "ai_usage_log_no_update"
  ON public.ai_usage_log FOR UPDATE
  USING (false);

-- RLS POLICY: DELETE — DENY all
-- Rationale: logs are immutable for audit integrity.
-- Threat model: prevents erasing historical call records.
CREATE POLICY "ai_usage_log_no_delete"
  ON public.ai_usage_log FOR DELETE
  USING (false);

-- ============================================================================
-- TRIGGER: Prevent role column modification
-- ============================================================================
-- Non-admin users cannot change their role via UPDATE.
-- This is more reliable than RLS policy approach.

CREATE OR REPLACE FUNCTION prevent_role_update()
RETURNS TRIGGER AS $$
BEGIN
  -- If role is being changed and user is not admin, raise error
  IF NEW.role != OLD.role AND NOT is_admin() THEN
    RAISE EXCEPTION 'Role cannot be modified by non-admin users';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER profiles_prevent_role_update
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION prevent_role_update();

-- ============================================================================
-- TRIGGER: Auto-create profile on auth.users INSERT
-- ============================================================================
-- When a new user signs up via Supabase GoTrue, this trigger creates a
-- matching row in the profiles table.
-- 
-- SECURITY DEFINER allows the trigger to insert into profiles even when
-- the triggering context is the anon user (who would normally lack INSERT
-- permission on profiles).
--
-- The trigger runs AFTER INSERT so the auth.users row is definitely complete.

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'user'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- COMMENT BLOCK: DEPLOYMENT CHECKLIST
-- ============================================================================
/*
After running this migration in the Supabase SQL editor:

1. ✅ Verify all tables created and RLS enabled:
   SELECT tablename FROM pg_tables WHERE schemaname = 'public';
   SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';

2. ✅ Test RLS policies by switching to anon key context (in test):
   - Unauthenticated user cannot select from profiles
   - Authenticated user sees only own row

3. ✅ Verify trigger on auth.users:
   - Sign up a test account via GoTrue
   - Confirm a row appears in profiles table with role='user'

4. ✅ Create test data for integration tests:
   -- Sign up three test users via Supabase dashboard or CLI:
   -- test_user_a@test.com / TestPassA123!
   -- test_user_b@test.com / TestPassB456!
   -- 221079815@nust.na / AdminPass789!
   -- Manually update role to 'admin' for the admin account:
   UPDATE public.profiles SET role = 'admin' 
     WHERE email = '221079815@nust.na';

5. ✅ Set OPENAI_API_KEY secret in Supabase:
   supabase secrets set OPENAI_API_KEY=sk-proj-...

6. ✅ Deploy Edge Function (ai-proxy) before running AI tests.
*/

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
