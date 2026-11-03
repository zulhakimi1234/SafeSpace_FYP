import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/wellness_model.dart';

class WellnessException implements Exception {
  final String message;

  const WellnessException(this.message);

  @override
  String toString() => message;
}

class WellnessService {
  static const String _tokenKey = 'safespace_auth_token';

  static const Duration _timeout = Duration(seconds: 20);

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // ======================================
  // AUTHENTICATED GET REQUEST
  // ======================================
  static Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        throw const WellnessException('Please login again to continue.');
      }

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const WellnessException('Invalid server response.');
      }

      if (response.statusCode == 401) {
        throw const WellnessException('Session expired. Please login again.');
      }

      if (response.statusCode >= 400) {
        String message =
            decoded['message']?.toString() ??
            'Failed to load wellness resources.';

        final errors = decoded['errors'];

        if (errors is Map) {
          for (final error in errors.values) {
            if (error is List && error.isNotEmpty) {
              message = error.first.toString();
              break;
            }
          }
        }

        throw WellnessException(message);
      }

      return decoded;
    } on WellnessException {
      rethrow;
    } on SocketException {
      throw const WellnessException('Cannot connect to Laravel server.');
    } on TimeoutException {
      throw const WellnessException('Connection timed out. Please try again.');
    } on http.ClientException {
      throw const WellnessException('Network request failed.');
    } on FormatException {
      throw const WellnessException('Invalid response from Laravel.');
    } catch (_) {
      throw const WellnessException('Something went wrong. Please try again.');
    }
  }

  // ======================================
  // GET PUBLISHED WELLNESS RESOURCES
  // ======================================
  static Future<WellnessPage> getResources({
    int page = 1,
    String type = 'all',
    String search = '',
  }) async {
    if (page < 1) {
      throw const WellnessException('Invalid page number.');
    }

    final parameters = <String, String>{'page': page.toString()};

    if (type == 'article' || type == 'tip') {
      parameters['type'] = type;
    }

    if (search.trim().isNotEmpty) {
      parameters['search'] = search.trim();
    }

    final uri = Uri.parse(
      ApiConfig.wellnessUrl,
    ).replace(queryParameters: parameters);

    final data = await _get(uri);

    return WellnessPage.fromJson(data);
  }

  // ======================================
  // GET SINGLE RESOURCE
  // ======================================
  static Future<WellnessResource> getResource(int id) async {
    final data = await _get(Uri.parse('${ApiConfig.wellnessUrl}/$id'));

    final raw = data['data'];

    if (raw is! Map) {
      throw const WellnessException('Wellness resource not found.');
    }

    return WellnessResource.fromJson(Map<String, dynamic>.from(raw));
  }
}
