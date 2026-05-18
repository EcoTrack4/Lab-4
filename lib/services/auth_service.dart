// ECOTRACK NAMIBIA — AUTHENTICATION SERVICE
// lib/services/auth_service.dart
// Purpose: Supabase authentication with email, password, and Google OAuth
// Provides: user signup, signin, signout, role fetching, session management
// Date: 2026-05-17

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when AI rate limit is exceeded.
class RateLimitException implements Exception {
  final String message;
  final int? retryAfterSeconds;

  RateLimitException(this.message, {this.retryAfterSeconds});

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  late final Supabase _supabase;
  late final FlutterSecureStorage _secureStorage;
  late final GoogleSignIn _googleSignIn;

  // Getter for current user (from Supabase auth state)
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange();

  /// Initialize Supabase and secure storage.
  /// Must be called in main() before runApp().
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    // Initialize Supabase with secure local storage
    // This stores the JWT in Keychain (iOS) or Keystore (Android)
    // Never in SharedPreferences (OWASP M9: Insecure Data Storage)
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage:
            SecureLocalStorage(), // ✅ Secure storage, not SharedPreferences
      ),
    );

    _supabase = Supabase.instance;
    _secureStorage = const FlutterSecureStorage();
    _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  }

  /// Map Supabase AuthException codes to user-friendly error messages.
  String _mapAuthError(dynamic error) {
    if (error is AuthException) {
      final code = error.code;

      if (code == 'invalid_credentials') {
        return 'Email or password is incorrect.';
      } else if (code == 'email_address_already_used' ||
          code == 'user_already_registered') {
        return 'An account with this email already exists.';
      } else if (code == 'weak_password') {
        return 'Password must be at least 8 characters.';
      } else if (code == 'network_error' || code == 'connection_timeout') {
        return 'Connection failed. Please check your internet and try again.';
      }
    }

    // Catch-all for unexpected errors
    return 'Something went wrong. Please try again.';
  }

  /// Sign up with email, password, and full name.
  ///
  /// Throws:
  /// - AuthException: if signup fails (email already used, weak password, network, etc.)
  ///
  /// On success:
  /// - Supabase sends confirmation email (if email confirmation is enabled in Supabase project)
  /// - A row is auto-created in the profiles table via database trigger
  /// - User is NOT automatically signed in; they must confirm email first
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );

      // Trigger on auth.users will auto-create profiles row
      if (response.user == null) {
        throw AuthException('Signup failed: no user returned');
      }
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  /// Sign in with email and password.
  ///
  /// Throws:
  /// - AuthException: if credentials are invalid, account doesn't exist, or network fails
  ///
  /// On success:
  /// - JWT is stored in flutter_secure_storage (iOS Keychain / Android Keystore)
  /// - currentUser is updated
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  /// Sign in with Google OAuth.
  ///
  /// Throws:
  /// - AuthException: if Google sign-in fails or OpenID token is invalid
  /// - Returns gracefully if user cancels the Google picker (no exception)
  ///
  /// On success:
  /// - JWT is stored in flutter_secure_storage
  /// - currentUser is updated with Google identity
  /// - Profile auto-created if first-time login
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      // User cancelled the Google sign-in flow
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw AuthException('Failed to obtain Google ID token');
      }

      // Exchange Google ID token for Supabase session
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e), code: e.code);
    } catch (e) {
      // User likely cancelled — handle gracefully
      if (e.toString().contains('PlatformException') ||
          e.toString().contains('cancelled')) {
        return;
      }
      throw AuthException(_mapAuthError(e));
    }
  }

  /// Get the current user's role from the profiles table.
  ///
  /// IMPORTANT: Role is ALWAYS fetched from the database, never from JWT payload.
  /// JWT role claims are client-controlled and cannot be trusted.
  ///
  /// Throws:
  /// - Exception: if user is not authenticated or database query fails
  ///
  /// Returns:
  /// - 'admin' or 'user' from the profiles table
  Future<String> getUserRole() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return (data['role'] as String?) ?? 'user';
    } catch (e) {
      throw Exception('Failed to fetch user role: $e');
    }
  }

  /// Sign out the user.
  ///
  /// Throws:
  /// - Exception: if signout fails (rare, usually network)
  ///
  /// On success:
  /// - JWT is removed from flutter_secure_storage
  /// - currentUser is set to null
  /// - authStateChanges stream emits AuthChangeEvent.signedOut
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Clear any locally cached role value
      await _secureStorage.delete(key: 'user_role_cache');
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get the current session's access token.
  ///
  /// Returns null if no active session.
  /// Used to make authenticated requests to Edge Functions and REST API.
  String? getAccessToken() {
    return _supabase.auth.currentSession?.accessToken;
  }
}
