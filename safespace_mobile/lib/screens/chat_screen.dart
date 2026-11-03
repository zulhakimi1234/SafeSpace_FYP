import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  bool _isSending = false;
  String? _error;

  @override
  void dispose() {
    // All session messages are discarded here
    _messages.clear();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ======================================
  // SCROLL TO THE LATEST MESSAGE
  // ======================================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ======================================
  // SEND MESSAGE
  // ======================================
  Future<void> _sendMessage() async {
    if (_isSending) return;

    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    // Save the previous context before adding
    // the current message.
    final history = List<ChatMessage>.from(_messages);

    _messageController.clear();

    setState(() {
      _isSending = true;
      _error = null;

      _messages.add(ChatMessage.user(message));
    });

    _scrollToBottom();

    try {
      final reply = await ChatService.sendMessage(
        message: message,
        history: history,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage.assistant(reply));
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        // Allow the user to retry the message
        if (_messages.isNotEmpty && _messages.last.isUser) {
          _messages.removeLast();
        }

        _messageController.text = message;
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });

        _scrollToBottom();
      }
    }
  }

  // ======================================
  // CLEAR CONVERSATION
  // ======================================
  Future<void> _clearConversation() async {
    if (_isSending || _messages.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Conversation?'),
          content: const Text(
            'All messages in this chat session will be cleared from the screen. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8E7AB5),
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _messages.clear();
      _messageController.clear();
      _error = null;
    });
  }

  // ======================================
  // AI SAFETY AND PRIVACY NOTICE
  // ======================================
  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE7F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF594780), size: 22),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'SafeSpace AI offers general emotional support, not professional therapy. Avoid sharing identifying details. If you are in immediate danger, contact emergency services or someone you trust.',
              style: TextStyle(
                color: Color(0xFF594780),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================
  // CHAT BUBBLE
  // ======================================
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          margin: const EdgeInsets.only(bottom: 13),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF8E7AB5) : Colors.white,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const Text(
                  'SafeSpace AI',
                  style: TextStyle(
                    color: Color(0xFF594780),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),
              ],

              SelectableText(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF333333),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================
  // CHAT MESSAGES
  // ======================================
  Widget _buildChatMessages() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      children: [
        _buildNotice(),

        const SizedBox(height: 24),

        // Initial greeting - not stored in history
        const Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(17)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Hi! I'm SafeSpace AI. I'm here to listen. How are you feeling today? 💜",
                style: TextStyle(color: Color(0xFF333333), height: 1.5),
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        ..._messages.map(_buildMessageBubble),

        if (_isSending)
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8E7AB5),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'SafeSpace AI is responding...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        if (_error != null) ...[
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),

          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ======================================
  // MESSAGE INPUT
  // ======================================
  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8DFF5))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isSending,
                maxLength: 1000,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8F6FC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 9),

            IconButton.filled(
              tooltip: 'Send Message',
              onPressed: _isSending ? null : _sendMessage,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF8E7AB5),
                foregroundColor: Colors.white,
                minimumSize: const Size(47, 47),
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================
  // MAIN CHAT SCREEN
  // ======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SafeSpace AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF594780),
                fontSize: 19,
              ),
            ),

            Text(
              'Powered by Ollama Llama 3',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Clear Conversation',
            onPressed: _isSending ? null : _clearConversation,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF8E7AB5),
            ),
          ),
        ],
      ),

      body: SafeArea(top: false, child: _buildChatMessages()),

      bottomNavigationBar: _buildMessageInput(),
    );
  }
}
