import 'package:flutter_test/flutter_test.dart';

import 'package:safespace_mobile/models/mood_model.dart';

void main() {
  // ======================================
  // TEST 1: MOOD ENTRY
  // ======================================
  test('Mood entry parses correctly', () {
    final entry = MoodEntry.fromJson({
      'id': 1,
      'mood': 'good',
      'mood_score': 4,
      'note': 'Today was a good day.',
      'recorded_date': '2026-10-25',
    });

    expect(entry.id, 1);
    expect(entry.moodScore, 4);
    expect(entry.label, 'Good');
    expect(entry.note, 'Today was a good day.');
    expect(entry.displayDate, '25/10/2026');
  });

  // ======================================
  // TEST 2: WEEKLY SUMMARY
  // ======================================
  test('Mood summary parses correctly', () {
    final summary = MoodSummary.fromJson({
      'days': 7,
      'today_date': '2026-10-25',
      'record_count': 1,
      'average_score': 5.0,
      'today': {
        'id': 1,
        'mood': 'very_good',
        'mood_score': 5,
        'note': null,
        'recorded_date': '2026-10-25',
      },
      'entries': [
        {
          'id': 1,
          'mood': 'very_good',
          'mood_score': 5,
          'note': null,
          'recorded_date': '2026-10-25',
        },
      ],
    });

    expect(summary.days, 7);
    expect(summary.recordCount, 1);
    expect(summary.averageScore, 5.0);
    expect(summary.today?.moodScore, 5);
    expect(summary.entries.length, 1);
  });

  // ======================================
  // TEST 3: EMPTY MOOD HISTORY
  // ======================================
  test('Empty mood history is handled', () {
    final summary = MoodSummary.fromJson({
      'days': 30,
      'today_date': '2026-10-25',
      'record_count': 0,
      'average_score': null,
      'today': null,
      'entries': [],
    });

    expect(summary.entries, isEmpty);
    expect(summary.today, isNull);
    expect(summary.averageScore, isNull);
  });
}
