import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/task_model.dart';

class TaskException implements Exception {
  final String message;

  const TaskException(this.message);

  @override
  String toString() => message;
}

class TaskService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Same Sanctum token key used by AuthService
  static const String _tokenKey = 'safespace_auth_token';

  static const Duration _timeout = Duration(seconds: 20);

  // Send authenticated API request
  static Future<Map<String, dynamic>> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token == null || token.isEmpty) {
        throw const TaskException('Please login again to continue.');
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late final http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(_timeout);
          break;

        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;

        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;

        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(_timeout);
          break;

        default:
          throw const TaskException('Unsupported request method.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const TaskException('Invalid response from server.');
      }

      if (response.statusCode == 401) {
        throw const TaskException('Session expired. Please login again.');
      }

      if (response.statusCode >= 400) {
        String message =
            decoded['message']?.toString() ?? 'Task operation failed.';

        final errors = decoded['errors'];

        if (errors is Map) {
          for (final error in errors.values) {
            if (error is List && error.isNotEmpty) {
              message = error.first.toString();
              break;
            }
          }
        }

        throw TaskException(message);
      }

      return decoded;
    } on TaskException {
      rethrow;
    } on SocketException {
      throw const TaskException('Cannot connect to Laravel server.');
    } on TimeoutException {
      throw const TaskException('Connection timed out.');
    } on http.ClientException {
      throw const TaskException('Network request failed.');
    } on FormatException {
      throw const TaskException('Invalid server response.');
    } catch (_) {
      throw const TaskException('Something went wrong. Please try again.');
    }
  }

  // GET ALL PERSONAL TASKS
  static Future<List<TaskModel>> getTasks() async {
    final data = await _request('GET', Uri.parse(ApiConfig.tasksUrl));

    final rawTasks = data['data'];

    if (rawTasks is! List) {
      throw const TaskException('Invalid task list received.');
    }

    return rawTasks.map((item) {
      return TaskModel.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  // CREATE TASK
  static Future<TaskModel> createTask({
    required String title,
    String? description,
    String? category,
    String? dueDate,
    String status = 'pending',
  }) async {
    final data = await _request(
      'POST',
      Uri.parse(ApiConfig.tasksUrl),
      body: {
        'title': title.trim(),
        'description': description,
        'category': category,
        'due_date': dueDate,
        'status': status,
      },
    );

    return TaskModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  // UPDATE TASK OR STATUS
  static Future<TaskModel> updateTask(TaskModel task) async {
    final data = await _request(
      'PUT',
      Uri.parse('${ApiConfig.tasksUrl}/${task.id}'),
      body: task.toRequestBody(),
    );

    return TaskModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  // DELETE TASK
  static Future<void> deleteTask(int id) async {
    await _request('DELETE', Uri.parse('${ApiConfig.tasksUrl}/$id'));
  }
}
