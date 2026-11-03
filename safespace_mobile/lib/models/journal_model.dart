class JournalPost {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final int replyCount;
  final bool isMine;

  const JournalPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.replyCount,
    required this.isMine,
  });

  factory JournalPost.fromJson(Map<String, dynamic> json) {
    return JournalPost(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
      isMine: json['is_mine'] == true,
    );
  }

  String get displayDate => formatJournalDate(createdAt);
}

class JournalReply {
  final int id;
  final String content;
  final String createdAt;
  final bool isMine;

  const JournalReply({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  factory JournalReply.fromJson(Map<String, dynamic> json) {
    return JournalReply(
      id: (json['id'] as num).toInt(),
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isMine: json['is_mine'] == true,
    );
  }

  String get displayDate => formatJournalDate(createdAt);
}

class JournalPage {
  final List<JournalPost> posts;
  final bool hasMore;
  final int currentPage;

  const JournalPage({
    required this.posts,
    required this.hasMore,
    required this.currentPage,
  });
}

class JournalDetailsData {
  final JournalPost post;
  final List<JournalReply> replies;

  const JournalDetailsData({required this.post, required this.replies});
}

String formatJournalDate(String value) {
  final date = DateTime.tryParse(value)?.toLocal();

  if (date == null) {
    return value;
  }

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  return '${twoDigits(date.day)}/'
      '${twoDigits(date.month)}/${date.year} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
