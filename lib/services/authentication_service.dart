import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/data_models.dart';

/// Authentication Service - Handles user login and session management
class AuthenticationService {
  static const String _userKey = 'ecotrack_user';
  static const String _tokenKey = 'ecotrack_token';
  static const String _isLoggedInKey = 'ecotrack_is_logged_in';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      // TODO: Make API call to backend for authentication
      // For now, simulate successful login
      
      // Create mock user based on type
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: userType == 'hunter' ? 'Johannes Kamanga' : 'Petrus M.',
        email: email,
        userType: userType,
        licenseNumber: userType == 'hunter' ? 'PH-2024-001' : null,
        region: userType == 'hunter' ? 'Kunene Region' : 'Windhoek',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save user and token
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      await _prefs.setString(_tokenKey, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _prefs.setBool(_isLoggedInKey, true);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _prefs.remove(_userKey);
      await _prefs.remove(_tokenKey);
      await _prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    
    if (userJson != null && isLoggedIn) {
      try {
        final decoded = jsonDecode(userJson);
        return User.fromJson(decoded);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  String? getUserType() {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final decoded = jsonDecode(userJson);
        return decoded['userType'] as String?;
      } catch (e) {
        print('Error parsing user type: $e');
      }
    }
    return null;
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }
}
