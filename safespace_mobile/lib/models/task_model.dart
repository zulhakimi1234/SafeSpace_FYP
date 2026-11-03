class TaskModel {
  final int id;
  final String title;
  final String? description;
  final String? category;
  final String? dueDate;
  final String status;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.dueDate,
    required this.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      dueDate: json['due_date']?.toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }

  // Create an updated copy of the same task
  TaskModel copyWith({String? title, String? status}) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description,
      category: category,
      dueDate: dueDate,
      status: status ?? this.status,
    );
  }

  DateTime? get date {
    if (dueDate == null || dueDate!.isEmpty) {
      return null;
    }

    return DateTime.tryParse(dueDate!);
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  String get displayDate {
    final value = date;

    if (value == null) {
      return 'No Due Date';
    }

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  bool get isCompleted => status == 'completed';

  bool get isOverdue {
    final value = date;

    if (value == null || isCompleted) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return value.isBefore(today);
  }

  Map<String, dynamic> toRequestBody() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'due_date': dueDate,
      'status': status,
    };
  }
}
