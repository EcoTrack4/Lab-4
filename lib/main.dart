import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/authentication_service.dart';
import 'services/returns_service.dart';
import 'services/database_service.dart';
import 'services/sync_service.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/hunter_home_screen.dart';
import 'screens/officer_home_screen.dart';
import 'screens/hunter_dashboard_screen.dart';
import 'screens/annual_return_form_screen.dart';
import 'screens/officer_dashboard_screen.dart';
import 'screens/return_details_screen.dart';
import 'screens/export_reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/hunter_returns_history_screen.dart';
import 'screens/hunter_return_status_screen.dart';
import 'screens/offline_sync_status_screen.dart';
import 'screens/officer_search_returns_screen.dart';
import 'screens/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize services
  final authService = AuthenticationService();
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationService>(create: (_) => authService),
        Provider<ReturnsService>(create: (_) => ReturnsService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<SyncService>(
          create: (context) => SyncService(
            databaseService: context.read<DatabaseService>(),
            returnsService: context.read<ReturnsService>(),
          ),
        ),
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
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initRouter();
    _initializeApp();
  }

  void _initRouter() {
    _router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/hunter-home',
          builder: (context, state) => const HunterHomeScreen(),
        ),
        GoRoute(
          path: '/officer-home',
          builder: (context, state) => const OfficerHomeScreen(),
        ),
        GoRoute(
          path: '/hunter-dashboard',
          builder: (context, state) => const HunterDashboardScreen(),
          routes: [
            GoRoute(
              path: 'new-return',
              builder: (context, state) => const AnnualReturnFormScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const HunterReturnsHistoryScreen(),
            ),
            GoRoute(
              path: 'return-status/:id',
              builder: (context, state) => HunterReturnStatusScreen(
                returnId: state.pathParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: 'offline-sync',
              builder: (context, state) => const OfflineSyncStatusScreen(),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const UserProfileScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/officer-dashboard',
          builder: (context, state) => const OfficerDashboardScreen(),
          routes: [
            GoRoute(
              path: 'search',
              builder: (context, state) => const OfficerSearchReturnsScreen(),
            ),
            GoRoute(
              path: 'return-details/:id',
              builder: (context, state) => ReturnDetailsScreen(
                returnId: state.pathParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: 'export-reports',
              builder: (context, state) => const ExportReportsScreen(),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const UserProfileScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _initializeApp() async {
    // Use addPostFrameCallback to access context after first build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final databaseService = context.read<DatabaseService>();
      final syncService = context.read<SyncService>();

      try {
        // Initialize database
        await databaseService.init();

        // Start sync service
        await syncService.startAutoSync();
      } catch (e) {
        print('Error initializing services: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EcoTrack Namibia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

