class MoodEntry {
  final int id;
  final String mood;
  final int moodScore;
  final String? note;
  final String recordedDate;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.moodScore,
    required this.note,
    required this.recordedDate,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: (json['id'] as num).toInt(),
      mood: json['mood']?.toString() ?? '',
      moodScore: (json['mood_score'] as num).toInt(),
      note: json['note']?.toString(),
      recordedDate: json['recorded_date']?.toString() ?? '',
    );
  }

  String get label {
    switch (moodScore) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Very Good';
      default:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (moodScore) {
      case 1:
        return '😢';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '❔';
    }
  }

  String get displayDate {
    final date = DateTime.tryParse(recordedDate);

    if (date == null) return recordedDate;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class MoodSummary {
  final int days;
  final String todayDate;
  final int recordCount;
  final double? averageScore;
  final MoodEntry? today;
  final List<MoodEntry> entries;

  const MoodSummary({
    required this.days,
    required this.todayDate,
    required this.recordCount,
    required this.averageScore,
    required this.today,
    required this.entries,
  });

  factory MoodSummary.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];

    if (rawEntries is! List) {
      throw const FormatException('Invalid mood history response.');
    }

    final rawToday = json['today'];

    return MoodSummary(
      days: (json['days'] as num).toInt(),
      todayDate: json['today_date'].toString(),
      recordCount: (json['record_count'] as num).toInt(),
      averageScore: (json['average_score'] as num?)?.toDouble(),
      today: rawToday is Map
          ? MoodEntry.fromJson(Map<String, dynamic>.from(rawToday))
          : null,
      entries: rawEntries.map((entry) {
        return MoodEntry.fromJson(Map<String, dynamic>.from(entry as Map));
      }).toList(),
    );
  }
}
