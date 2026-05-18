# EcoTrack Namibia — Integration Test Guide

## Running Security Tests

### Prerequisites

1. **Supabase Project:** Create a free project at https://supabase.com
2. **Test Accounts:** Sign up three accounts in your Supabase project:
   - `test_user_a@test.com` / `TestPassA123!`
   - `test_user_b@test.com` / `TestPassB456!`
   - `221079815@nust.na` / `AdminPass789!`

3. **Admin Role:** Manually set the admin user's role in Supabase:
   ```sql
   UPDATE public.profiles SET role = 'admin' 
     WHERE email = '221079815@nust.na';
   ```

4. **OpenAI API Key:** (optional, for full T2 test) Set the secret:
   ```bash
   supabase secrets set OPENAI_API_KEY=sk-proj-...
   ```

### Execution

```bash
# Terminal 1: Deploy Edge Function
supabase functions deploy ai-proxy

# Terminal 2: Run security tests
flutter test integration_test/security_tests.dart \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### Test Output

Each test prints results like:
```
[T1] PASS: Unauthenticated request correctly blocked
[T2] PASS: User B cannot read User A data (RLS blocked)
[T3] PASS: User role remains unchanged (still user, not admin)
[T4] PASS: Payload stored as literal, not executed
[T5] PASS: Signed-out token was rejected
[T6] PASS: No sensitive fields exposed in profile response
```

### Interpreting Results

| Symbol | Meaning |
|--------|---------|
| ✅ PASS | Security control working as intended |
| ❌ FAIL | Vulnerability found; immediate remediation needed |
| ⚠️ WARNING | Non-critical issue or edge case |

### Troubleshooting

**Q: Tests fail with "SUPABASE_URL not found"**  
A: Make sure you passed `--dart-define=SUPABASE_URL=...` flag.

**Q: T2 fails with "User B read User A data"**  
A: RLS policy not applied correctly. Verify:
```sql
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables WHERE tablename IN ('profiles', 'user_data', 'ai_usage_log');
```

**Q: T3 fails with "Privilege escalation successful"**  
A: RLS UPDATE policy on `role` column missing. Re-run schema migration.

**Q: T6 fails with "Sensitive fields exposed"**  
A: Check your Supabase RLS policies; ensure SELECT policies don't expose internal fields.

---

## Security Test Coverage

| Test | Focus | OWASP Top 10 |
|------|-------|---|
| **T1** | Unauthenticated Access | M3 — Insecure Auth/AuthZ |
| **T2** | Cross-User Data Access | M3 — Insecure Auth/AuthZ |
| **T3** | Privilege Escalation | M1 — Improper Credentials |
| **T4** | Injection Attack | M4 — Insecure Input Validation |
| **T5** | Broken Auth & Session | M10 — Insufficient Cryptography |
| **T6** | Data Over-Exposure | M6 — Inadequate Privacy Controls |

---

## Continuous Testing

Add to your CI/CD pipeline (GitHub Actions example):

```yaml
name: Security Tests

on: [push, pull_request]

jobs:
  security-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test integration_test/security_tests.dart \
          --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
          --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

---

## Test Data Cleanup

After running tests, you may have test records in your database. To clean up:

```sql
-- Delete test data
DELETE FROM public.user_data 
WHERE user_id IN (
  SELECT id FROM public.profiles 
  WHERE email LIKE 'test_%@test.com'
);

-- Optional: Delete test users (requires GoTrue admin access)
-- Via Supabase dashboard: Authentication > Users > delete test accounts
```

---

**Test Suite Version:** 1.0  
**Last Updated:** 2026-05-17
