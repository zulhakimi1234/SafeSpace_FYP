import 'package:flutter/material.dart';

import '../models/journal_model.dart';
import '../services/journal_service.dart';

class JournalDetailScreen extends StatefulWidget {
  final int journalId;

  const JournalDetailScreen({super.key, required this.journalId});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final _replyController = TextEditingController();

  JournalDetailsData? _details;

  bool _isLoading = true;
  bool _isSendingReply = false;
  bool _isDeleting = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Fetch journal and replies
  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await JournalService.getJournalDetails(widget.journalId);

      if (!mounted) return;

      setState(() {
        _details = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Submit anonymous reply
  Future<void> _sendReply() async {
    if (_isSendingReply) return;

    final content = _replyController.text.trim();

    if (content.isEmpty) {
      _showMessage('Please write a reply first.');
      return;
    }

    setState(() {
      _isSendingReply = true;
    });

    try {
      await JournalService.addReply(
        journalId: widget.journalId,
        content: content,
      );

      if (!mounted) return;

      _replyController.clear();
      FocusScope.of(context).unfocus();

      _showMessage('Reply posted successfully!');

      await _loadDetails();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSendingReply = false;
        });
      }
    }
  }

  // Confirm deletion
  Future<void> _confirmDelete() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Journal?'),
          content: const Text(
            'This will permanently delete your journal and all its replies. This action cannot be undone.',
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
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await JournalService.deleteJournal(widget.journalId);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // Reply card
  Widget _buildReplyCard(JournalReply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Color(0xFF8E7AB5),
                size: 23,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  reply.isMine ? 'Anonymous (You)' : 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF594780),
                  ),
                ),
              ),

              Text(
                reply.displayDate,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            reply.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  // Journal content and replies
  Widget _buildContent() {
    final details = _details!;

    return RefreshIndicator(
      onRefresh: _loadDetails,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE8DFF5),
                      child: Icon(
                        Icons.person_outline,
                        color: Color(0xFF8E7AB5),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'Anonymous',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF594780),
                        ),
                      ),
                    ),

                    if (details.post.isMine)
                      const Text(
                        'Your Post',
                        style: TextStyle(
                          color: Color(0xFF8E7AB5),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  details.post.title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  details.post.displayDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 18),

                Text(
                  details.post.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Replies (${details.replies.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF594780),
            ),
          ),

          const SizedBox(height: 15),

          if (details.replies.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No replies yet. Be the first to respond.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

          ...details.replies.map(_buildReplyCard),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Reply input
  Widget _buildReplyInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8DFF5))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                enabled: !_isSendingReply,
                minLines: 1,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: 'Write an anonymous reply...',
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F6FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton.filled(
              onPressed: _isSendingReply ? null : _sendReply,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF8E7AB5),
                foregroundColor: Colors.white,
              ),
              icon: _isSendingReply
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Journal Details',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (_details?.post.isMine == true)
            IconButton(
              tooltip: 'Delete Journal',
              onPressed: _isDeleting ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
        ],
      ),

      body: _isLoading && _details == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    FilledButton(
                      onPressed: _loadDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _details != null
          ? _buildContent()
          : const Center(child: Text('Journal unavailable.')),

      bottomNavigationBar: _details != null && _error == null
          ? _buildReplyInput()
          : null,
    );
  }
}
