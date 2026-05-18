// ECOTRACK NAMIBIA — MAIN.DART SUPABASE INITIALIZATION EXAMPLE
// lib/main_supabase.dart
// Purpose: Shows how to initialize Supabase in main() before runApp()
// This replaces the existing main.dart; adapt your existing code to follow this pattern
// Date: 2026-05-17

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Services
import 'services/auth_service.dart';
import 'services/ai_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/hunter_home_screen.dart';
import 'screens/officer_home_screen.dart';
import 'screens/access_denied_screen.dart';

// Widgets
import 'widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ============================================================================
  // SUPABASE INITIALIZATION
  // ============================================================================
  // This MUST happen before runApp() so that the session can be restored
  // from secure storage before any widgets are built.
  //
  // Environment variables are passed via: --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // or via: const String.fromEnvironment('SUPABASE_URL', defaultValue: '...')
  //
  // ✅ SECURITY: JWT is stored in flutter_secure_storage (iOS Keychain / Android Keystore)
  // ✅ Never in SharedPreferences (OWASP M9 compliant)

  // ✅ Your Supabase Project Credentials (EcoTrack Namibia)
  // Load from environment variables or dart-define for security
  // Use: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://pvghpleftkorlafptddk.supabase.co');
  const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE');

  // Initialize Supabase with secure local storage
  // The SecureLocalStorage() passed here stores JWT in Keychain (iOS) / Keystore (Android)
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      localStorage:
          SecureLocalStorage(), // ✅ Secure storage, not SharedPreferences
    ),
  );

  // ============================================================================
  // SERVICE INITIALIZATION
  // ============================================================================

  final authService = AuthService();
  // Note: AuthService.initialize() has already been called by Supabase.initialize()
  // The auth service can use Supabase.instance.client directly

  final aiService = AIService(supabaseUrl: supabaseUrl);

  // ============================================================================
  // RUN APP
  // ============================================================================

  runApp(
    MultiProvider(
      providers: [
        // Auth service for login/signup/signout
        Provider<AuthService>(create: (_) => authService),

        // AI service for Edge Function calls
        Provider<AIService>(create: (_) => aiService),

        // Add other services as needed
        // Provider<ReturnsService>(create: (_) => ReturnsService()),
        // Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: const EcoTrackApp(),
    ),
  );
}

class EcoTrackApp extends StatefulWidget {
  const EcoTrackApp({Key? key}) : super(key: key);

  @override
  State<EcoTrackApp> createState() => _EcoTrackAppState();
}

class _EcoTrackAppState extends State<EcoTrackApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      routes: [
        // Splash / Onboarding
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth Routes (accessible without authentication)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Protected Routes (wrapped in AuthGate at app level)
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // Legacy routes (kept for backward compatibility with existing screens)
        GoRoute(
          path: '/hunter-home',
          builder: (context, state) => const HunterHomeScreen(),
        ),
        GoRoute(
          path: '/officer-home',
          builder: (context, state) => const OfficerHomeScreen(),
        ),
      ],

      // Error route
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Page not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EcoTrack Namibia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: (context, child) {
        // Wrap router with AuthGate at the app level
        // This ensures authentication state is checked before any route is rendered
        return AuthGate(child: child ?? const SizedBox());
      },
    );
  }
}

// ============================================================================
// SECURE LOCAL STORAGE IMPLEMENTATION
// ============================================================================
// Implements the Supabase AuthChangeNotifierLocalStorage interface
// using flutter_secure_storage as the backing store.

class SecureLocalStorage extends AuthChangeNotifierLocalStorage {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }
}

// ============================================================================
// BUILD & RUN COMMANDS
// ============================================================================
/*
Development (with Supabase emulator):
flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54321 \
  --dart-define=SUPABASE_ANON_KEY=eyJ...

Production (Supabase cloud):
flutter run --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...

With obfuscation (recommended for app store):
flutter build apk --release --obfuscate \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
*/
