import 'package:flutter/material.dart';

import '../services/journal_service.dart';

class CreateJournalScreen extends StatefulWidget {
  const CreateJournalScreen({super.key});

  @override
  State<CreateJournalScreen> createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends State<CreateJournalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // Publish journal to Laravel
  Future<void> _publish() async {
    if (_isPublishing) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      await JournalService.createJournal(
        title: _titleController.text,
        content: _contentController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal published successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'New Journal Post',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Anonymous information
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DFF5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: Color(0xFF594780),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your post will appear as Anonymous. Avoid including personal information in your writing.',
                              style: TextStyle(
                                color: Color(0xFF594780),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Journal Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _titleController,
                      maxLength: 150,
                      enabled: !_isPublishing,
                      decoration: InputDecoration(
                        hintText: 'Give your journal a title...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Your Thoughts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _contentController,
                      maxLines: 10,
                      minLines: 6,
                      maxLength: 5000,
                      enabled: !_isPublishing,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write what is on your mind...',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please write your thoughts';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: _isPublishing ? null : _publish,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8E7AB5),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                      ),
                      icon: _isPublishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isPublishing ? 'Publishing...' : 'Publish Anonymously',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
