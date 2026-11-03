class WellnessResource {
  final int id;
  final String title;
  final String content;
  final String preview;
  final String category;
  final String type;
  final String? updatedAt;

  const WellnessResource({
    required this.id,
    required this.title,
    this.content = '',
    this.preview = '',
    required this.category,
    required this.type,
    this.updatedAt,
  });

  factory WellnessResource.fromJson(Map<String, dynamic> json) {
    return WellnessResource(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      preview: json['preview']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isArticle => type == 'article';

  bool get isTip => type == 'tip';

  String get typeLabel {
    if (isArticle) return 'Article';
    if (isTip) return 'Wellness Tip';
    return 'Resource';
  }

  String get categoryLabel {
    if (category.trim().isEmpty) {
      return 'General Wellness';
    }

    return category;
  }

  String get displayDate {
    if (updatedAt == null || updatedAt!.isEmpty) {
      return 'Date unavailable';
    }

    final value = DateTime.tryParse(updatedAt!);

    if (value == null) {
      return updatedAt!;
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }
}

class WellnessPage {
  final List<WellnessResource> resources;
  final int currentPage;
  final bool hasMore;
  final int total;

  const WellnessPage({
    required this.resources,
    required this.currentPage,
    required this.hasMore,
    required this.total,
  });

  factory WellnessPage.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];

    if (raw is! List) {
      throw const FormatException('Invalid wellness resource list.');
    }

    return WellnessPage(
      resources: raw.map((item) {
        return WellnessResource.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList(),
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      hasMore: json['has_more'] == true,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
