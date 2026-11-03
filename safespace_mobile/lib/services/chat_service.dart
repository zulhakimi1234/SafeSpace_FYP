import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat_message.dart';

class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => message;
}

class ChatService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'safespace_auth_token';

  // AI inference may take longer on a local PC
  static const Duration _timeout = Duration(seconds: 200);

  // ======================================
  // SEND MESSAGE TO LARAVEL
  // ======================================
  static Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final text = message.trim();

    if (text.isEmpty) {
      throw const ChatException('Please enter a message.');
    }

    if (text.length > 1000) {
      throw const ChatException(
        'Message is too long. Maximum 1000 characters.',
      );
    }

    try {
      // Read the existing Sanctum token
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        throw const ChatException('Please login again to use the chatbot.');
      }

      // Only send recent messages for context
      final recentHistory = history.length > 8
          ? history.sublist(history.length - 8)
          : history;

      final response = await http
          .post(
            Uri.parse(ApiConfig.chatUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'message': text,
              'history': recentHistory.map((item) => item.toJson()).toList(),
            }),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const ChatException('Invalid response from Laravel.');
      }

      if (response.statusCode == 401) {
        throw const ChatException('Session expired. Please login again.');
      }

      if (response.statusCode >= 400) {
        throw ChatException(
          decoded['message']?.toString() ?? 'The chatbot is unavailable.',
        );
      }

      if (decoded['success'] != true) {
        throw const ChatException(
          'The chatbot could not complete the request.',
        );
      }

      final reply = decoded['reply'];

      if (reply is! String || reply.trim().isEmpty) {
        throw const ChatException('The AI returned an empty response.');
      }

      return reply.trim();
    } on ChatException {
      rethrow;
    } on SocketException {
      throw const ChatException('Cannot connect to Laravel server.');
    } on TimeoutException {
      throw const ChatException('AI response timed out. Please try again.');
    } on http.ClientException {
      throw const ChatException('Network request failed.');
    } on FormatException {
      throw const ChatException('Invalid JSON response from server.');
    } catch (_) {
      throw const ChatException('Something went wrong. Please try again.');
    }
  }
}
