// ECOTRACK NAMIBIA — AI SERVICE
// lib/services/ai_service.dart
// Purpose: Call Supabase Edge Function AI proxy with authentication
// Handles rate limiting, token refresh, and error mapping
// Date: 2026-05-17

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when AI rate limit is exceeded.
class RateLimitException implements Exception {
  final String message;
  final int? retryAfterSeconds;

  RateLimitException(this.message, {this.retryAfterSeconds});

  @override
  String toString() => message;
}

class AIService {
  final String supabaseUrl;

  AIService({required this.supabaseUrl});

  /// Send a prompt to the AI proxy.
  ///
  /// Returns the assistant's response as a string.
  ///
  /// Throws:
  /// - AuthException: if user is not authenticated
  /// - RateLimitException: if rate limit is exceeded (includes retryAfter)
  /// - Exception: if the request fails for any other reason
  Future<String> sendPrompt(
    String prompt, {
    String model = 'gpt-4o-mini',
  }) async {
    // Get current session
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      throw Exception('Not authenticated. Please sign in first.');
    }

    final accessToken = session.accessToken;

    // Prepare request
    final url = Uri.parse('$supabaseUrl/functions/v1/ai-proxy');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'prompt': prompt,
      'model': model,
    });

    // Make request
    late http.Response response;
    try {
      response = await http.post(url, headers: headers, body: body);
    } catch (e) {
      throw Exception('Network error: $e');
    }

    // Handle response
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] as String;
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please sign in again.');
    } else if (response.statusCode == 429) {
      // Rate limit exceeded
      final data = jsonDecode(response.body);
      final retryAfter = data['retryAfter'] as int?;
      throw RateLimitException(
        data['error'] ?? 'Rate limit exceeded',
        retryAfterSeconds: retryAfter,
      );
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Invalid request');
    } else if (response.statusCode == 502) {
      throw Exception(
          'AI service is currently unavailable. Please try again later.');
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  }

  /// Format retry-after time for user display.
  /// Takes seconds and returns a readable string like "2 minutes"
  static String formatRetryAfter(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      final minutes = (seconds / 60).ceil();
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      final hours = (seconds / 3600).ceil();
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
  }
}
