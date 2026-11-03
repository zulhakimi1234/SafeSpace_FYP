import 'package:flutter_test/flutter_test.dart';

import 'package:safespace_mobile/models/chat_message.dart';

void main() {
  test('User message is created correctly', () {
    final message = ChatMessage.user('I feel stressed today.');

    expect(message.role, 'user');
    expect(message.isUser, true);
    expect(message.content, 'I feel stressed today.');
  });

  test('Assistant message is created correctly', () {
    final message = ChatMessage.assistant('I am here to listen.');

    expect(message.role, 'assistant');
    expect(message.isUser, false);
  });

  test('Message converts to API JSON correctly', () {
    final message = ChatMessage.user('Hello SafeSpace AI');

    final json = message.toJson();

    expect(json['role'], 'user');
    expect(json['content'], 'Hello SafeSpace AI');
    expect(json.containsKey('user_id'), false);
  });
}
