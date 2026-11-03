class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.user(String content) {
    return ChatMessage(role: 'user', content: content);
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(role: 'assistant', content: content);
  }

  bool get isUser => role == 'user';

  Map<String, String> toJson() {
    return {'role': role, 'content': content};
  }
}
