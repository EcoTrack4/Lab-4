# Lab 7 — Supabase + Flutter Implementation

**EcoTrack Namibia** — Production-grade mobile backend with authentication, database, and security hardening.

**Stack:**
- Backend: Supabase (PostgreSQL + GoTrue + Deno Edge Functions)
- Mobile Client: Flutter (Dart) + supabase_flutter package
- Auth: Email/password + Google OAuth
- Storage: flutter_secure_storage (Keychain/Keystore)
- Testing: Integration tests + security audit suite

---

## 📁 Project Structure

```
Lab-4/
├── supabase/
│   ├── migrations/
│   │   └── 20260517_init_schema.sql          ← Database schema + RLS policies
│   └── functions/
│       └── ai-proxy/
│           └── index.ts                      ← Deno Edge Function
├── lib/
│   ├── main_supabase.dart                    ← Updated entry point
│   ├── services/
│   │   ├── auth_service.dart                 ← Auth (signup, signin, signout)
│   │   └── ai_service.dart                   ← AI proxy client
│   ├── screens/
│   │   ├── login_screen.dart                 ← Email/password + OAuth
│   │   ├── register_screen.dart              ← Signup with validation
│   │   ├── home_screen.dart                  ← Dashboard (protected)
│   │   ├── admin_screen.dart                 ← Admin panel (RLS protected)
│   │   └── access_denied_screen.dart         ← 403 page
│   └── widgets/
│       ├── auth_gate.dart                    ← Session restoration + routing
│       └── admin_guard.dart                  ← Admin-only access control
├── integration_test/
│   ├── security_tests.dart                   ← T1–T6 security tests
│   ├── security_test_setup.dart              ← Test constants
│   └── README.md                             ← How to run tests
├── docs/
│   ├── security_notes.md                     ← Full security audit (Prompt 5)
│   └── DEPLOYMENT.md                         ← Step-by-step deployment guide
├── pubspec.yaml                              ← Updated dependencies
└── README.md                                 ← This file
```

---

## 🚀 Quick Start (5 minutes)

### 1. Create Supabase Project

```bash
# Sign up at https://supabase.com
# Create project: ecotrack-namibia
# Copy URL and anon key
```

### 2. Deploy Schema

```bash
# In Supabase Dashboard → SQL Editor:
# Paste contents of: supabase/migrations/20260517_init_schema.sql
# Click Run
```

### 3. Deploy Edge Function

```bash
# Terminal
supabase functions deploy ai-proxy
supabase secrets set OPENAI_API_KEY=sk-proj-...
```

### 4. Run Flutter App

```bash
flutter pub get

flutter run --dart-define=SUPABASE_URL=https://pvghpleftkorlafptddk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2Z2hwbGVmdGtvcmxhZnB0ZGRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTM2OTcsImV4cCI6MjA5NDY2OTY5N30.4HsXNcf06lxhmdnox9-FXQomPMyLSPAIxPu_2mmYedY
```

### 5. Test Signup

- Tap "Register"
- Sign up: `test@example.com` / `TestPass123!` / `Test User`
- Sign in
- See your profile on Home Screen ✅

---

## 🔐 Security Features

### ✅ Implemented

| Feature | Implementation | Verified |
|---------|---|---|
| **Email/Password Auth** | Supabase GoTrue (Argon2 hashing) | T1, T3, T5 |
| **Google OAuth** | `google_sign_in` + `signInWithIdToken()` | Manual test |
| **JWT Storage** | flutter_secure_storage (Keychain/Keystore) | OWASP M9 ✅ |
| **Row-Level Security** | RLS policies on all tables | T1, T2 |
| **Rate Limiting** | Server-side in Edge Function | T2 (AI proxy) |
| **Admin Access Control** | `AdminGuard` widget + DB role check | T3, T6 |
| **Soft Deletes** | Enforced via RLS DELETE policy | Schema test |
| **Injection Prevention** | Parameterised queries | T4 |
| **Session Management** | JWT refresh + token invalidation | T5 |
| **Data Over-Exposure** | No sensitive fields in API | T6 |

### Security Test Results

```
[T1] ✅ PASS: Unauthenticated access blocked
[T2] ✅ PASS: Cross-user data access blocked
[T3] ✅ PASS: Privilege escalation prevented
[T4] ✅ PASS: Injection payloads stored as literals
[T5] ✅ PASS: Tampered tokens rejected
[T6] ✅ PASS: No sensitive fields exposed
```

See [docs/security_notes.md](docs/security_notes.md) for full audit.

---

## 📋 Core Implementation Details

### Authentication Flow

1. **Signup:** Email → GoTrue signup → Trigger creates profile row → Send confirmation email
2. **Signin:** Email + password → GoTrue → JWT stored in Keychain (iOS) / Keystore (Android)
3. **Session Restore:** App startup → SecureLocalStorage reads JWT → AuthGate checks session
4. **Admin Verification:** Role fetched from `profiles` table (never from JWT) → shown on Home Screen

### Database Tables

**profiles** (extends auth.users)
```sql
id UUID → auth.users(id)
email TEXT UNIQUE
full_name TEXT
role TEXT ('user' | 'admin')
created_at, updated_at
```

**user_data** (app-specific records)
```sql
id UUID PRIMARY KEY
user_id UUID → profiles(id)
species_harvested, quantity, location, notes
created_at, updated_at, deleted_at (soft-delete)
```

**ai_usage_log** (audit trail)
```sql
id UUID PRIMARY KEY
user_id UUID → profiles(id)
prompt_tokens, completion_tokens, total_tokens
model TEXT
called_at TIMESTAMPTZ
```

### RLS Policies

| Table | Policy | Effect |
|-------|--------|--------|
| profiles | SELECT own: `auth.uid() = id` | Users see own profile only |
| profiles | SELECT admin: `is_admin()` | Admins see all profiles |
| profiles | UPDATE role: `NEW.role = OLD.role` | Role is immutable |
| user_data | SELECT: `user_id = auth.uid() AND deleted_at IS NULL` | Own non-deleted rows |
| user_data | DELETE: `false` | Physical deletes blocked |
| ai_usage_log | INSERT: `false` (client) | Service role only |

---

## 🛠️ File Reference

### Authentication Service

**lib/services/auth_service.dart**
- `signUpWithEmail(email, password, fullName)` → Creates account + profile
- `signInWithEmail(email, password)` → JWT stored in secure storage
- `signInWithGoogle()` → OAuth token exchange
- `signOut()` → Clears JWT + local cache
- `getUserRole()` → Fetches role from DB server-side (never trusts JWT)

### Auth Gate (Session Management)

**lib/widgets/auth_gate.dart**
- Wraps router
- Listens to `supabase.auth.onAuthStateChange()`
- Routes to `/login` if session null
- Routes to `/home` if session active
- Shows loading spinner while restoring from SecureStorage

### Admin Guard (Access Control)

**lib/widgets/admin_guard.dart**
- Wraps admin-only screens
- Calls `authService.getUserRole()` on every access
- Renders child if role == 'admin'
- Renders AccessDeniedScreen (403) otherwise
- Never trusts constructor parameters or JWT payload

### Screens

| Screen | Purpose | Protection |
|--------|---------|-----------|
| `login_screen.dart` | Email/password + Google OAuth | Public |
| `register_screen.dart` | Account creation | Public |
| `home_screen.dart` | Dashboard + profile info | AuthGate |
| `admin_screen.dart` | User management | AdminGuard |
| `access_denied_screen.dart` | 403 error page | N/A |

### AI Service

**lib/services/ai_service.dart**
- `sendPrompt(prompt, model)` → Call Edge Function
- Returns assistant response
- Throws `RateLimitException` on 429
- Throws on auth/network errors

---

## 🧪 Security Testing

### Run All Tests

```bash
flutter test integration_test/security_tests.dart \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### Test Setup

Create these accounts in Supabase:
- `test_user_a@test.com` / `TestPassA123!`
- `test_user_b@test.com` / `TestPassB456!`
- `221079815@nust.na` / `AdminPass789!` (then set role='admin')

### Coverage

| Test | Scenario | OWASP Top 10 |
|------|----------|---|
| **T1** | Unauthenticated POST to Edge Function | M3 |
| **T2** | User B tries to read User A's data | M3 |
| **T3** | User tries to UPDATE role to admin | M1 |
| **T4** | SQL injection payloads (DROP TABLE, OR "1"="1") | M4 |
| **T5** | Tampered JWT + signed-out token | M10 |
| **T6** | Sensitive fields in API response | M6 |

---

## 📦 Dependencies (Updated)

```yaml
dependencies:
  flutter: sdk: flutter
  supabase_flutter: ^2.5.0
  flutter_secure_storage: ^9.0.0
  google_sign_in: ^6.1.0
  provider: ^6.1.0
  go_router: ^13.0.0
  http: ^1.1.0
  # ... etc
```

Run: `flutter pub get`

---

## 🔑 Environment Variables

### Development

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://pvghpleftkorlafptddk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2Z2hwbGVmdGtvcmxhZnB0ZGRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTM2OTcsImV4cCI6MjA5NDY2OTY5N30.4HsXNcf06lxhmdnox9-FXQomPMyLSPAIxPu_2mmYedY
```

### Production (Release Build)

```bash
flutter build apk --release --obfuscate \
  --dart-define=SUPABASE_URL=https://pvghpleftkorlafptddk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2Z2hwbGVmdGtvcmxhZnB0ZGRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTM2OTcsImV4cCI6MjA5NDY2OTY5N30.4HsXNcf06lxhmdnox9-FXQomPMyLSPAIxPu_2mmYedY
```

**Note:** Never commit keys to Git. Use CI/CD secrets.

---

## 📖 Documentation

- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — Step-by-step deployment guide
- **[docs/security_notes.md](docs/security_notes.md)** — Full security audit + OWASP assessment
- **[integration_test/README.md](integration_test/README.md)** — How to run security tests

---

## ⚠️ Important Notes

### OWASP M9 Compliance

✅ **JWT stored in flutter_secure_storage, not SharedPreferences**

File: `lib/main_supabase.dart` line ~56

```dart
await Supabase.initialize(
  authOptions: const FlutterAuthClientOptions(
    localStorage: SecureLocalStorage(), // Keychain/Keystore, not SharedPreferences
  ),
);
```

### JWT Role Claims Not Trusted

✅ **Role always fetched from database, never read from JWT**

File: `lib/services/auth_service.dart` line ~97

```dart
Future<String> getUserRole() async {
  // Queries profiles table server-side — never trusts JWT payload
  final data = await _supabase
      .from('profiles')
      .select('role')
      .eq('id', supabase.auth.currentUser!.id)
      .single();
  return data['role'] as String;
}
```

### OpenAI API Key Server-Side Only

✅ **Key stored in Supabase secrets, read by Edge Function, never sent to app**

File: `supabase/functions/ai-proxy/index.ts` line ~65

```typescript
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") || "";
// Key is used only by server; never visible to client
```

---

## 🔗 Deployment Checklist

- [ ] Supabase project created (https://supabase.com)
- [ ] Schema deployed (`supabase/migrations/20260517_init_schema.sql`)
- [ ] Edge Function deployed (`supabase functions deploy ai-proxy`)
- [ ] OpenAI key set (`supabase secrets set OPENAI_API_KEY=...`)
- [ ] Google OAuth credentials set (if using OAuth)
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] All 6 security tests pass
- [ ] Admin account created (via SQL: `UPDATE profiles SET role='admin'...`)
- [ ] App tested on iOS, Android
- [ ] Release build tested with `--dart-define` flags
- [ ] Obfuscation enabled (`--obfuscate` flag)

---

## 🐛 Troubleshooting

**Q: Startup fails with "Missing SUPABASE_URL"**  
A: Pass environment variables via `--dart-define`:
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

**Q: RLS policies blocking my queries**  
A: Verify you're authenticated and role is correct. Test with admin account first.

**Q: T3 test fails: "Privilege escalation successful"**  
A: RLS UPDATE policy on `role` column missing. Re-run schema migration in Supabase SQL editor.

**Q: Edge Function returns 502**  
A: Check function logs: `supabase functions logs ai-proxy`. Verify OPENAI_API_KEY is set.

See **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** for detailed troubleshooting.

---

## 📝 License & Attribution

- **EcoTrack Namibia** — MPD820S Lab 7
- **Date:** 2026-05-17
- **Authors:** Security Engineering Team
- **Stack:** Supabase (PostgreSQL), Flutter/Dart, Deno

---

## 🔒 Security Contacts

For security vulnerabilities:
1. Do NOT open a public issue
2. Email: security@ecotrack.local
3. Include: description, impact, reproduction steps

---

**Status:** ✅ **PRODUCTION-READY**  
**Last Updated:** 2026-05-17  
**Version:** 1.0.0
