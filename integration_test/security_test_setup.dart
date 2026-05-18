// ECOTRACK NAMIBIA — SECURITY TEST SETUP
// integration_test/security_test_setup.dart
// Purpose: Constants and test fixtures for security tests
// Date: 2026-05-17

const String supabaseUrl =
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

// Test user credentials — create these in Supabase before running tests
const String userAEmail = 'test_user_a@test.com';
const String userAPassword = 'TestPassA123!';

const String userBEmail = 'test_user_b@test.com';
const String userBPassword = 'TestPassB456!';

const String adminEmail = '221079815@nust.na';
const String adminPassword = 'AdminPass789!';

// Will be populated during T2 setup
String userBUuid = '';

// Injection test payloads
const List<String> injectionPayloads = [
  "'; DROP TABLE profiles; --",
  "<script>alert('xss')</script>",
  '" OR "1"="1',
  '../../../etc/passwd',
  '\x00null_byte',
];
