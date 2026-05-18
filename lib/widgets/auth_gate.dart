// ECOTRACK NAMIBIA — AUTH GATE WIDGET
// lib/widgets/auth_gate.dart
// Purpose: Top-level widget that enforces authentication state and routes accordingly
// Restores session from secure storage, listens to auth changes, routes to login or home
// Date: 2026-05-17

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// AuthGate wraps the app router and handles authentication state.
///
/// Behavior:
/// - Shows loading spinner while session is being restored from SecureStorage
/// - Routes to HomeScreen if session is active (user authenticated)
/// - Routes to LoginScreen if session is null (user not authenticated)
/// - Handles auth state changes: tokenRefreshed, signedOut, userUpdated
///
/// This widget must be placed ABOVE the GoRouter in the widget tree.
class AuthGate extends StatefulWidget {
  final Widget child;

  const AuthGate({required this.child, Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = context.read<AuthService>().authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        // CONNECTING state: session being restored from SecureStorage
        // Show loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ACTIVE state: stream has delivered an event
        if (snapshot.hasData) {
          final authState = snapshot.data!;

          // User is authenticated
          if (authState.session != null) {
            // Log significant events for debugging
            if (authState.event == AuthChangeEvent.tokenRefreshed) {
              debugPrint('[Auth] JWT token refreshed');
            } else if (authState.event == AuthChangeEvent.userUpdated) {
              debugPrint(
                  '[Auth] User profile updated: ${authState.user?.email}');
              // Could trigger profile refresh here if needed
            }

            // Render the authenticated app
            return widget.child;
          }

          // User is NOT authenticated (session is null)
          else {
            if (authState.event == AuthChangeEvent.signedOut) {
              debugPrint('[Auth] User signed out');
              // Clear any cached data here if needed
            }

            // Redirect to login screen
            // Use a delayed callback to avoid setState() during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
            });

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }

        // ERROR or null snapshot
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Authentication Error'),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Initial state: no session info yet, still loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
