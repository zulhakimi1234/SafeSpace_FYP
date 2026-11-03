class AssessmentInfo {
  final int id;
  final String title;
  final int questionCount;
  final bool isReady;

  const AssessmentInfo({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.isReady,
  });

  factory AssessmentInfo.fromJson(Map<String, dynamic> json) {
    return AssessmentInfo(
      id: (json['id'] as num).toInt(),
      title: json['title'].toString(),
      questionCount: (json['question_count'] as num).toInt(),
      isReady: json['is_ready'] == true,
    );
  }
}

class AssessmentOption {
  final int index;
  final String label;

  const AssessmentOption({required this.index, required this.label});

  factory AssessmentOption.fromJson(Map<String, dynamic> json) {
    return AssessmentOption(
      index: (json['index'] as num).toInt(),
      label: json['label'].toString(),
    );
  }
}

class AssessmentQuestion {
  final int id;
  final String question;
  final List<AssessmentOption> options;

  const AssessmentQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: (json['id'] as num).toInt(),
      question: json['question'].toString(),
      options: (json['options'] as List)
          .map(
            (item) => AssessmentOption.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class AssessmentDetail {
  final int id;
  final String title;
  final List<AssessmentQuestion> questions;

  const AssessmentDetail({
    required this.id,
    required this.title,
    required this.questions,
  });

  factory AssessmentDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentDetail(
      id: (json['id'] as num).toInt(),
      title: json['title'].toString(),
      questions: (json['questions'] as List)
          .map(
            (item) => AssessmentQuestion.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class AssessmentResult {
  final String title;
  final int totalScore;
  final int maxScore;
  final double averageScore;
  final int moodScore;
  final String moodLabel;
  final String recordedDate;
  final String guidance;

  const AssessmentResult({
    required this.title,
    required this.totalScore,
    required this.maxScore,
    required this.averageScore,
    required this.moodScore,
    required this.moodLabel,
    required this.recordedDate,
    required this.guidance,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      title: json['title'].toString(),
      totalScore: (json['total_score'] as num).toInt(),
      maxScore: (json['max_score'] as num).toInt(),
      averageScore: (json['average_score'] as num).toDouble(),
      moodScore: (json['mood_score'] as num).toInt(),
      moodLabel: json['mood_label'].toString(),
      recordedDate: json['recorded_date'].toString(),
      guidance: json['guidance'].toString(),
    );
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
}
