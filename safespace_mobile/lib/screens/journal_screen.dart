import 'package:flutter/material.dart';

import '../models/journal_model.dart';
import '../services/journal_service.dart';
import 'create_journal_screen.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalPost> _posts = [];

  bool _isLoading = false;
  bool _hasMore = false;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts(refresh: true);
  }

  // Fetch journal feed from Laravel
  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final nextPage = refresh ? 1 : _page + 1;

      final result = await JournalService.getJournals(page: nextPage);

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _posts.clear();
        }

        _posts.addAll(result.posts);
        _page = result.currentPage;
        _hasMore = result.hasMore;
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

  // Navigate to create journal screen
  Future<void> _openCreateScreen() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateJournalScreen()),
    );

    if (created == true && mounted) {
      await _loadPosts(refresh: true);
    }
  }

  // Navigate to journal details
  Future<void> _openDetails(JournalPost post) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JournalDetailScreen(journalId: post.id),
      ),
    );

    if (changed == true && mounted) {
      await _loadPosts(refresh: true);
    }
  }

  // Individual anonymous post card
  Widget _buildPostCard(JournalPost post) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetails(post),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8DFF5),
                    child: Icon(Icons.person_outline, color: Color(0xFF8E7AB5)),
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

                  if (post.isMine)
                    const Text(
                      'Your Post',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8E7AB5)),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 9),

              Text(
                post.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF555555),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      post.displayDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 17,
                    color: Color(0xFF8E7AB5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.replyCount} replies',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF594780),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeed() {
    return RefreshIndicator(
      onRefresh: () => _loadPosts(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Share your thoughts',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF594780),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'A space to express yourself and support others anonymously.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),

          const SizedBox(height: 20),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  TextButton(
                    onPressed: () {
                      _loadPosts(refresh: true);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),

          if (_posts.isEmpty && _isLoading)
            const Padding(
              padding: EdgeInsets.all(45),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (_posts.isEmpty && !_isLoading && _error == null)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 55,
                    color: Color(0xFF8E7AB5),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No journal posts yet.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to share your thoughts.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ..._posts.map(_buildPostCard),

          if (_hasMore)
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : () => _loadPosts(),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Load More Posts'),
              ),
            ),
        ],
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
          'Community Journal',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(child: _buildFeed()),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateScreen,
        backgroundColor: const Color(0xFF8E7AB5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('New Post'),
      ),
    );
  }
}
