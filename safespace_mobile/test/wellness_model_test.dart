import 'package:flutter_test/flutter_test.dart';

import 'package:safespace_mobile/models/wellness_model.dart';

void main() {
  // ======================================
  // TEST 1: PARSE ARTICLE
  // ======================================
  test('Wellness article parses correctly', () {
    final resource = WellnessResource.fromJson({
      'id': 1,
      'title': 'Understanding Daily Stress',
      'content': 'Full article content.',
      'category': 'Mental Health',
      'type': 'article',
      'updated_at': '2026-10-28 14:30:00',
    });

    expect(resource.id, 1);
    expect(resource.title, 'Understanding Daily Stress');
    expect(resource.category, 'Mental Health');
    expect(resource.isArticle, true);
    expect(resource.isTip, false);
    expect(resource.typeLabel, 'Article');
    expect(resource.displayDate, '28/10/2026');
  });

  // ======================================
  // TEST 2: PARSE WELLNESS TIP
  // ======================================
  test('Wellness tip parses correctly', () {
    final resource = WellnessResource.fromJson({
      'id': 2,
      'title': 'Simple Breathing Break',
      'content': 'Take a gentle breathing break.',
      'category': 'Relaxation',
      'type': 'tip',
      'updated_at': '2026-10-28 15:00:00',
    });

    expect(resource.id, 2);
    expect(resource.isTip, true);
    expect(resource.isArticle, false);
    expect(resource.typeLabel, 'Wellness Tip');
  });

  // ======================================
  // TEST 3: PARSE WELLNESS PAGE
  // ======================================
  test('Wellness page parses correctly', () {
    final page = WellnessPage.fromJson({
      'success': true,
      'current_page': 1,
      'has_more': false,
      'total': 2,
      'data': [
        {
          'id': 1,
          'title': 'Understanding Daily Stress',
          'preview': 'Article preview...',
          'category': 'Mental Health',
          'type': 'article',
          'updated_at': null,
        },
        {
          'id': 2,
          'title': 'Simple Breathing Break',
          'preview': 'Tip preview...',
          'category': 'Relaxation',
          'type': 'tip',
          'updated_at': null,
        },
      ],
    });

    expect(page.resources.length, 2);
    expect(page.total, 2);
    expect(page.hasMore, false);
    expect(page.currentPage, 1);
    expect(page.resources.first.isArticle, true);
    expect(page.resources.last.isTip, true);
  });

  // ======================================
  // TEST 4: EMPTY RESOURCES
  // ======================================
  test('Empty wellness resources handled correctly', () {
    final page = WellnessPage.fromJson({
      'success': true,
      'current_page': 1,
      'has_more': false,
      'total': 0,
      'data': [],
    });

    expect(page.resources, isEmpty);
    expect(page.total, 0);
  });

  // ======================================
  // TEST 5: OPTIONAL CATEGORY
  // ======================================
  test('Missing category uses a default label', () {
    final resource = WellnessResource.fromJson({
      'id': 3,
      'title': 'General Resource',
      'category': '',
      'type': 'tip',
    });

    expect(resource.categoryLabel, 'General Wellness');
    expect(resource.displayDate, 'Date unavailable');
  });
}
