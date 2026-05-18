# EcoTrack Namibia — Supabase Deployment Guide

## Quick Start

### 1. Create Supabase Project

1. Go to https://supabase.com and click "New Project"
2. Enter project name: `ecotrack-namibia`
3. Create a strong database password
4. Select region closest to your users (e.g., Africa - Johannesburg)
5. Click "Create new project" (takes ~2 minutes)

### 2. Get Credentials

In Supabase Dashboard:
- Go to **Settings > API**
- Copy `Project URL` → `SUPABASE_URL`
- Copy `anon public` key → `SUPABASE_ANON_KEY`

Save these; you'll need them in multiple places.

### 3. Deploy Database Schema

1. Go to **SQL Editor** in Supabase Dashboard
2. Copy the entire contents of `supabase/migrations/20260517_init_schema.sql`
3. Paste into the SQL editor
4. Click **Run** button
5. Verify: go to **Table Editor** and confirm you see `profiles`, `user_data`, `ai_usage_log` tables

Expected output:
```
✓ Function "update_updated_at" created
✓ Function "is_admin" created
✓ Table "profiles" created with RLS
✓ Table "user_data" created with RLS
✓ Table "ai_usage_log" created with RLS
✓ 8 RLS policies created
✓ Trigger "on_auth_user_created" created
```

### 4. Deploy Edge Function

```bash
# Terminal: at project root
supabase functions deploy ai-proxy

# Output should show:
# Deployed ai-proxy to https://YOUR_PROJECT_ID.supabase.co/functions/v1/ai-proxy
```

### 5. Set Secrets

```bash
# Set OpenAI API key
supabase secrets set OPENAI_API_KEY=sk-proj-YOUR_KEY_HERE

# Verify (does not show the actual key):
supabase secrets list
# Should show: OPENAI_API_KEY
```

### 6. Enable Email Confirmation (Optional but Recommended)

In Supabase Dashboard:
- Go to **Authentication > Email Templates**
- Enable "Confirm signup" template
- Users will receive email to confirm before logging in

Or disable for testing:
- Go to **Authentication > Settings**
- Set "Confirm email" to OFF

### 7. Configure Google OAuth (Optional)

1. Create OAuth credentials at https://console.cloud.google.com:
   - New Project → Create OAuth 2.0 credentials → OAuth consent screen
   - Authorized redirect URIs:
     ```
     https://YOUR_PROJECT.supabase.co/auth/v1/callback
     ```

2. Copy `Client ID` and `Client Secret`

3. In Supabase Dashboard:
   - Go to **Authentication > Providers > Google**
   - Paste Client ID and Client Secret
   - Enable provider

4. In Flutter app:
   - Add Google OAuth redirect to `android/app/build.gradle`:
     ```gradle
     manifestPlaceholders = [
       'FIREBASE_WEB_CLIENT_ID': 'YOUR_GOOGLE_CLIENT_ID'
     ]
     ```

### 8. Update Flutter App

Create `.env.local` (for development):
```
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Or use command-line flags:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### 9. Test Signup

1. Launch app: `flutter run`
2. Navigate to **Register**
3. Sign up: `test@example.com` / `TestPass123!` / `Test User`
4. If email confirmation enabled: check inbox for confirmation link
5. Sign in with your new account
6. Verify you see your profile on **Home Screen**

### 10. Create Admin Account

```sql
-- In Supabase SQL Editor:
UPDATE public.profiles SET role = 'admin' 
  WHERE email = 'your-email@example.com';
```

Then refresh app — you should see **Admin Tools** button.

---

## Production Deployment

### Android

```bash
# Build release APK
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --obfuscate --split-debug-info=./build/app/outputs/symbols

# Output: build/app/outputs/flutter-app.apk
```

### iOS

```bash
# Build release app
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY

# Or via Xcode:
open ios/Runner.xcworkspace
# Select Product > Build For > Running (Release)
```

---

## Environment Variables (CI/CD)

For GitHub Actions or other CI systems:

```bash
# Set as repository secrets
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
OPENAI_API_KEY=sk-proj-...
```

Then in workflow:
```yaml
- run: flutter test \
    --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
    --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

---

## Monitoring & Debugging

### View Logs

```bash
# Watch function logs in real-time
supabase functions list
supabase functions logs ai-proxy --follow
```

### Test Edge Function

```bash
# Get your anon key from Supabase dashboard
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/ai-proxy \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello, world!"}'

# Expected response:
# {"result": "Hello! How can I assist you today?"}
```

### Check Database

```bash
# In Supabase SQL Editor:
SELECT COUNT(*) FROM public.profiles;
SELECT COUNT(*) FROM public.ai_usage_log;
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Signup fails with "Email invalid" | Check Supabase email settings; may need to whitelist test domain |
| RLS policies blocking my queries | Verify you're signed in; test with admin account first |
| Edge Function returns 502 | Check function logs: `supabase functions logs ai-proxy`; verify OPENAI_API_KEY is set |
| Rate limit always exceeded | May be from previous tests; check `ai_usage_log` table and delete old entries |
| Token expired errors | JWT exp claim: default 1 hour; refresh token is automatic in `supabase_flutter` |

---

## Rollback Procedures

### Delete Everything (For Test Project Only)

```bash
# ⚠️ WARNING: This deletes all data

# In Supabase SQL Editor:
DROP TABLE IF EXISTS public.ai_usage_log CASCADE;
DROP TABLE IF EXISTS public.user_data CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at();
DROP FUNCTION IF EXISTS public.is_admin();
DROP FUNCTION IF EXISTS public.handle_new_user();

# Then: Re-run schema migration to recreate
```

---

**Last Updated:** 2026-05-17  
**Deployment Checklist Version:** 1.0
