// ECOTRACK NAMIBIA — ADMIN GUARD WIDGET
// lib/widgets/admin_guard.dart
// Purpose: Protects admin-only screens by verifying role from database
// Fetches role from profiles table on every access — never trusts JWT or constructor params
// Date: 2026-05-17

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/access_denied_screen.dart';

/// AdminGuard wraps admin-only screens and enforces role-based access control.
///
/// Behavior:
/// - On build: fetches role from profiles table server-side
/// - While loading: shows centered CircularProgressIndicator
/// - If role == 'admin': renders the child widget
/// - If role != 'admin': renders AccessDeniedScreen (403)
///
/// IMPORTANT: Role is always queried from the database, never from:
/// - Constructor parameters
/// - JWT payload
/// - Cached local state
/// - GoRouter route parameters
///
/// This prevents privilege escalation attacks where a user tries to pass
/// role='admin' as a parameter or modify their JWT locally.
class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return FutureBuilder<String>(
      future: authService.getUserRole(),
      builder: (context, snapshot) {
        // WAITING: role is being fetched from database
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ERROR: database query failed
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Failed to verify permissions'),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        // SUCCESS: role has been fetched
        final role = snapshot.data ?? 'user';

        // Role is 'admin': grant access
        if (role == 'admin') {
          return child;
        }

        // Role is NOT 'admin': deny access
        // Return AccessDeniedScreen
        return const AccessDeniedScreen();
      },
    );
  }
}
