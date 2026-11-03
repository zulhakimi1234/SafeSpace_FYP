class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Authentication
  static const String pingUrl = '$baseUrl/ping';
  static const String registerUrl = '$baseUrl/register';
  static const String loginUrl = '$baseUrl/login';
  static const String userUrl = '$baseUrl/user';
  static const String logoutUrl = '$baseUrl/logout';

  // Community Journal
  static const String journalsUrl = '$baseUrl/journals';

  // Mood Tracking
  static const String moodsUrl = '$baseUrl/moods';

  // Self-Assessment
  static const String assessmentsUrl = '$baseUrl/assessments';

  // Tasks & Calendar
  static const String tasksUrl = '$baseUrl/tasks';

  // Wellness Resources
  static const String wellnessUrl = '$baseUrl/wellness';

  // AI Chatbot
  static const String chatUrl = '$baseUrl/chat';
}
