import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

// Register response
class RegisterResult {
  final bool success;
  final String message;

  const RegisterResult({required this.success, required this.message});
}

// Login response
class LoginResult {
  final bool success;
  final String message;
  final String? username;

  const LoginResult({
    required this.success,
    required this.message,
    this.username,
  });
}

class AuthService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'safespace_auth_token';

  static const Duration _timeout = Duration(seconds: 20);

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Extract Laravel validation error
  static String _getErrorMessage(Map<String, dynamic> data, String fallback) {
    final errors = data['errors'];

    if (errors is Map) {
      for (final item in errors.values) {
        if (item is List && item.isNotEmpty) {
          return item.first.toString();
        }
      }
    }

    return data['message']?.toString() ?? fallback;
  }

  // REGISTER USER
  static Future<RegisterResult> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: _jsonHeaders,
            body: jsonEncode({
              'username': username.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
              'password_confirmation': confirmPassword,
            }),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return const RegisterResult(
          success: false,
          message: 'Invalid server response.',
        );
      }

      if (response.statusCode == 201 && decoded['success'] == true) {
        return RegisterResult(
          success: true,
          message: decoded['message']?.toString() ?? 'Registration successful.',
        );
      }

      return RegisterResult(
        success: false,
        message: _getErrorMessage(decoded, 'Registration failed.'),
      );
    } on SocketException {
      return const RegisterResult(
        success: false,
        message: 'Cannot connect to Laravel server.',
      );
    } on TimeoutException {
      return const RegisterResult(
        success: false,
        message: 'Connection timed out.',
      );
    } on http.ClientException {
      return const RegisterResult(
        success: false,
        message: 'Network request failed.',
      );
    } on FormatException {
      return const RegisterResult(
        success: false,
        message: 'Invalid response from Laravel.',
      );
    } catch (_) {
      return const RegisterResult(
        success: false,
        message: 'Registration failed. Please try again.',
      );
    }
  }

  // LOGIN USER
  static Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: _jsonHeaders,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return const LoginResult(
          success: false,
          message: 'Invalid server response.',
        );
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        final token = decoded['access_token'];

        if (token is! String || token.isEmpty) {
          return const LoginResult(
            success: false,
            message: 'Login token is missing.',
          );
        }

        // Save token securely on device
        await _storage.write(key: _tokenKey, value: token);

        final user = decoded['user'];

        String? username;

        if (user is Map) {
          username = user['username']?.toString();
        }

        return LoginResult(
          success: true,
          message: 'Login successful.',
          username: username,
        );
      }

      return LoginResult(
        success: false,
        message: _getErrorMessage(decoded, 'Login failed.'),
      );
    } on SocketException {
      return const LoginResult(
        success: false,
        message: 'Cannot connect to Laravel server.',
      );
    } on TimeoutException {
      return const LoginResult(
        success: false,
        message: 'Connection timed out.',
      );
    } on http.ClientException {
      return const LoginResult(
        success: false,
        message: 'Network request failed.',
      );
    } on FormatException {
      return const LoginResult(
        success: false,
        message: 'Invalid response from Laravel.',
      );
    } catch (_) {
      return const LoginResult(
        success: false,
        message: 'Login failed. Please try again.',
      );
    }
  }

  // GET CURRENT USER USING SAVED TOKEN
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.userUrl),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      // Expired or invalid token
      if (response.statusCode == 401) {
        await _storage.delete(key: _tokenKey);
        return null;
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded['user'] is Map) {
          return Map<String, dynamic>.from(decoded['user'] as Map);
        }
      }

      return null;
    } catch (_) {
      // Keep saved token if network is temporarily unavailable
      return null;
    }
  }

  // LOGOUT USER
  static Future<bool> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        return true;
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.logoutUrl),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 401) {
        await _storage.delete(key: _tokenKey);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
