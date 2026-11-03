import 'package:flutter_test/flutter_test.dart';

import 'package:safespace_mobile/models/task_model.dart';

void main() {
  // ======================================
  // TEST 1: PARSE TASK
  // ======================================
  test('Task model parses Laravel JSON', () {
    final task = TaskModel.fromJson({
      'id': 1,
      'title': 'Complete FYP Report',
      'description': 'Finish testing chapter',
      'category': 'Study',
      'due_date': '2026-11-03',
      'status': 'pending',
    });

    expect(task.id, 1);
    expect(task.title, 'Complete FYP Report');
    expect(task.category, 'Study');
    expect(task.dueDate, '2026-11-03');
    expect(task.statusLabel, 'Pending');
    expect(task.displayDate, '03/11/2026');
    expect(task.isCompleted, false);
  });

  // ======================================
  // TEST 2: UPDATE STATUS
  // ======================================
  test('Task status can be updated', () {
    const original = TaskModel(
      id: 5,
      title: 'Morning Exercise',
      status: 'pending',
    );

    final updated = original.copyWith(status: 'completed');

    expect(original.status, 'pending');
    expect(updated.status, 'completed');
    expect(updated.statusLabel, 'Completed');
    expect(updated.isCompleted, true);
    expect(updated.id, 5);
  });

  // ======================================
  // TEST 3: OPTIONAL DUE DATE
  // ======================================
  test('Task without due date is supported', () {
    const task = TaskModel(
      id: 7,
      title: 'Practice mindfulness',
      status: 'in_progress',
    );

    expect(task.date, isNull);
    expect(task.displayDate, 'No Due Date');
    expect(task.isOverdue, false);
  });

  // ======================================
  // TEST 4: REQUEST BODY
  // ======================================
  test('Task request body is correct', () {
    const task = TaskModel(
      id: 8,
      title: 'Read a Book',
      description: 'Read two chapters',
      category: 'Personal',
      dueDate: '2026-11-05',
      status: 'in_progress',
    );

    final body = task.toRequestBody();

    expect(body['title'], 'Read a Book');
    expect(body['description'], 'Read two chapters');
    expect(body['category'], 'Personal');
    expect(body['due_date'], '2026-11-05');
    expect(body['status'], 'in_progress');

    // User ID must be determined by Laravel
    expect(body.containsKey('user_id'), false);
  });
}
