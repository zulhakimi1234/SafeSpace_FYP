import 'package:flutter_test/flutter_test.dart';

import 'package:safespace_mobile/models/assessment_model.dart';

void main() {
  test('Assessment list parses correctly', () {
    final assessment = AssessmentInfo.fromJson({
      'id': 1,
      'title': 'Daily Wellbeing Check-In',
      'question_count': 3,
      'is_ready': true,
    });

    expect(assessment.id, 1);
    expect(assessment.title, 'Daily Wellbeing Check-In');
    expect(assessment.questionCount, 3);
    expect(assessment.isReady, true);
  });

  test('Assessment questions parse correctly', () {
    final assessment = AssessmentDetail.fromJson({
      'id': 1,
      'title': 'Daily Wellbeing Check-In',
      'questions': [
        {
          'id': 10,
          'question': 'How supported did you feel?',
          'options': [
            {'index': 0, 'label': 'Not at all'},
            {'index': 1, 'label': 'Moderately'},
            {'index': 2, 'label': 'Very much'},
          ],
        },
      ],
    });

    expect(assessment.questions.length, 1);
    expect(assessment.questions.first.id, 10);
    expect(assessment.questions.first.options.length, 3);
    expect(assessment.questions.first.options.last.index, 2);
  });

  test('Assessment result parses correctly', () {
    final result = AssessmentResult.fromJson({
      'title': 'Daily Wellbeing Check-In',
      'total_score': 12,
      'max_score': 15,
      'average_score': 4.0,
      'mood_score': 4,
      'mood_label': 'Good',
      'recorded_date': '2026-10-25',
      'guidance': 'General wellness guidance.',
    });

    expect(result.totalScore, 12);
    expect(result.maxScore, 15);
    expect(result.averageScore, 4.0);
    expect(result.moodScore, 4);
    expect(result.moodLabel, 'Good');
    expect(result.emoji, '🙂');
  });
}
