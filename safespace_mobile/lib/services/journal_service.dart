import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/journal_model.dart';

class JournalException implements Exception {
  final String message;

  const JournalException(this.message);

  @override
  String toString() => message;
}

class JournalService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Same key used by AuthService
  static const String _tokenKey = 'safespace_auth_token';

  static const Duration _timeout = Duration(seconds: 20);

  // Send authenticated request to Laravel
  static Future<Map<String, dynamic>> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        throw const JournalException('Please login again to continue.');
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
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers).timeout(_timeout);
      } else {
        throw const JournalException('Unsupported request method.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const JournalException('Invalid response from Laravel.');
      }

      if (response.statusCode == 401) {
        throw const JournalException(
          'Your session has expired. Please login again.',
        );
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

        throw JournalException(message);
      }

      return decoded;
    } on JournalException {
      rethrow;
    } on SocketException {
      throw const JournalException('Cannot connect to Laravel server.');
    } on TimeoutException {
      throw const JournalException('Connection timed out. Please try again.');
    } on http.ClientException {
      throw const JournalException('Network connection failed.');
    } on FormatException {
      throw const JournalException('Invalid JSON response from server.');
    } catch (_) {
      throw const JournalException('Something went wrong. Please try again.');
    }
  }

  // GET COMMUNITY FEED
  static Future<JournalPage> getJournals({int page = 1}) async {
    final uri = Uri.parse(
      ApiConfig.journalsUrl,
    ).replace(queryParameters: {'page': page.toString()});

    final data = await _request('GET', uri);

    final rawPosts = data['data'];

    if (rawPosts is! List) {
      throw const JournalException('Invalid journal list.');
    }

    final posts = rawPosts.map((item) {
      return JournalPost.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();

    return JournalPage(
      posts: posts,
      hasMore: data['has_more'] == true,
      currentPage: (data['current_page'] as num?)?.toInt() ?? page,
    );
  }

  // CREATE A NEW POST
  static Future<void> createJournal({
    required String title,
    required String content,
  }) async {
    await _request(
      'POST',
      Uri.parse(ApiConfig.journalsUrl),
      body: {'title': title.trim(), 'content': content.trim()},
    );
  }

  // GET SINGLE JOURNAL AND REPLIES
  static Future<JournalDetailsData> getJournalDetails(int id) async {
    final data = await _request(
      'GET',
      Uri.parse('${ApiConfig.journalsUrl}/$id'),
    );

    final rawPost = data['post'];
    final rawReplies = data['replies'];

    if (rawPost is! Map || rawReplies is! List) {
      throw const JournalException('Invalid journal details.');
    }

    final post = JournalPost.fromJson(Map<String, dynamic>.from(rawPost));

    final replies = rawReplies.map((item) {
      return JournalReply.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();

    return JournalDetailsData(post: post, replies: replies);
  }

  // REPLY TO JOURNAL
  static Future<void> addReply({
    required int journalId,
    required String content,
  }) async {
    await _request(
      'POST',
      Uri.parse('${ApiConfig.journalsUrl}/$journalId/replies'),
      body: {'content': content.trim()},
    );
  }

  // DELETE OWN JOURNAL
  static Future<void> deleteJournal(int id) async {
    await _request('DELETE', Uri.parse('${ApiConfig.journalsUrl}/$id'));
  }
}
