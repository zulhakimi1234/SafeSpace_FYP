import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/assessment_model.dart';

class AssessmentException implements Exception {
  final String message;

  const AssessmentException(this.message);

  @override
  String toString() => message;
}

class AssessmentService {
  static const String _tokenKey = 'safespace_auth_token';

  static const Duration _timeout = Duration(seconds: 20);

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // ======================================
  // AUTHENTICATED REQUEST
  // ======================================
  static Future<Map<String, dynamic>> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        throw const AssessmentException('Please login again.');
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
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(_timeout);
      } else {
        throw const AssessmentException('Unsupported request.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const AssessmentException('Invalid server response.');
      }

      if (response.statusCode == 401) {
        throw const AssessmentException('Session expired. Please login again.');
      }

      if (response.statusCode >= 400) {
        String message = decoded['message']?.toString() ?? 'Request failed.';

        final errors = decoded['errors'];

        if (errors is Map) {
          for (final item in errors.values) {
            if (item is List && item.isNotEmpty) {
              message = item.first.toString();
              break;
            }
          }
        }

        throw AssessmentException(message);
      }

      return decoded;
    } on AssessmentException {
      rethrow;
    } on SocketException {
      throw const AssessmentException('Cannot connect to Laravel server.');
    } on TimeoutException {
      throw const AssessmentException('Connection timed out.');
    } on http.ClientException {
      throw const AssessmentException('Network connection failed.');
    } on FormatException {
      throw const AssessmentException('Invalid response from Laravel.');
    } catch (_) {
      throw const AssessmentException(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ======================================
  // GET PUBLISHED ASSESSMENTS
  // ======================================
  static Future<List<AssessmentInfo>> getAssessments() async {
    final data = await _request('GET', Uri.parse(ApiConfig.assessmentsUrl));

    final raw = data['data'];

    if (raw is! List) {
      throw const AssessmentException('Invalid assessment list.');
    }

    return raw
        .map(
          (item) =>
              AssessmentInfo.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  // ======================================
  // GET QUESTIONS
  // ======================================
  static Future<AssessmentDetail> getAssessment(int id) async {
    final data = await _request(
      'GET',
      Uri.parse('${ApiConfig.assessmentsUrl}/$id'),
    );

    return AssessmentDetail.fromJson(data);
  }

  // ======================================
  // SUBMIT ANSWERS
  // ======================================
  static Future<AssessmentResult> submitAnswers({
    required int assessmentId,
    required Map<int, int> answers,
  }) async {
    final data = await _request(
      'POST',
      Uri.parse('${ApiConfig.assessmentsUrl}/$assessmentId/submit'),
      body: {
        'answers': answers.entries.map((entry) {
          return {'question_id': entry.key, 'option_index': entry.value};
        }).toList(),
      },
    );

    final result = data['result'];

    if (result is! Map) {
      throw const AssessmentException('Assessment result is missing.');
    }

    return AssessmentResult.fromJson(Map<String, dynamic>.from(result));
  }
}
