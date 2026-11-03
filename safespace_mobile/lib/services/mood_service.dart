import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/mood_model.dart';

class MoodException implements Exception {
  final String message;

  const MoodException(this.message);

  @override
  String toString() => message;
}

class MoodService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Same token key used by AuthService
  static const String _tokenKey = 'safespace_auth_token';

  static const Duration _timeout = Duration(seconds: 20);

  // =========================================
  // AUTHENTICATED API REQUEST
  // =========================================
  static Future<Map<String, dynamic>> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        throw const MoodException('Please login again to continue.');
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late final http.Response response;

      if (method == 'GET') {
        response = await http.get(uri, headers: headers).timeout(_timeout);
      } else if (method == 'POST') {
        response = await http
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(_timeout);
      } else {
        throw const MoodException('Unsupported request method.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const MoodException('Invalid server response.');
      }

      if (response.statusCode == 401) {
        throw const MoodException('Session expired. Please login again.');
      }

      if (response.statusCode >= 400) {
        String message = decoded['message']?.toString() ?? 'Request failed.';

        final errors = decoded['errors'];

        if (errors is Map) {
          for (final error in errors.values) {
            if (error is List && error.isNotEmpty) {
              message = error.first.toString();
              break;
            }
          }
        }

        throw MoodException(message);
      }

      return decoded;
    } on MoodException {
      rethrow;
    } on SocketException {
      throw const MoodException('Cannot connect to Laravel server.');
    } on TimeoutException {
      throw const MoodException('Connection timed out. Please try again.');
    } on http.ClientException {
      throw const MoodException('Network connection failed.');
    } on FormatException {
      throw const MoodException('Invalid response from Laravel.');
    } catch (_) {
      throw const MoodException('Something went wrong. Please try again.');
    }
  }

  // =========================================
  // GET WEEKLY / MONTHLY MOOD HISTORY
  // =========================================
  static Future<MoodSummary> getMoodHistory({int days = 7}) async {
    if (days != 7 && days != 30) {
      throw const MoodException('Only 7-day or 30-day history is supported.');
    }

    final uri = Uri.parse(
      ApiConfig.moodsUrl,
    ).replace(queryParameters: {'days': days.toString()});

    final data = await _request('GET', uri);

    return MoodSummary.fromJson(data);
  }

  // =========================================
  // SAVE OR UPDATE TODAY'S MOOD
  // =========================================
  static Future<void> saveMood({required int moodScore, String? note}) async {
    if (moodScore < 1 || moodScore > 5) {
      throw const MoodException('Please select a valid mood.');
    }

    await _request(
      'POST',
      Uri.parse(ApiConfig.moodsUrl),
      body: {'mood_score': moodScore, 'note': note?.trim()},
    );
  }
}
