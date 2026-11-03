import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'assessment_screen.dart';
import 'journal_screen.dart';
import 'login_screen.dart';
import 'module_placeholder_screen.dart';
import 'mood_screen.dart';
import 'tasks_screen.dart';
import 'wellness_screen.dart';
import 'chat_screen.dart';

class _DashboardModule {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const _DashboardModule({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggingOut = false;

  static const List<_DashboardModule> _modules = [
    _DashboardModule(
      title: 'AI Chatbot',
      subtitle: 'Talk about your feelings',
      description:
          'Express your feelings through the AI emotional support chatbot.',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    _DashboardModule(
      title: 'Community Journal',
      subtitle: 'Share anonymously',
      description: 'Share your thoughts with the community.',
      icon: Icons.menu_book_rounded,
    ),
    _DashboardModule(
      title: 'Mood Tracker',
      subtitle: 'Understand your emotions',
      description: 'Review your mood history and trends.',
      icon: Icons.favorite_border_rounded,
    ),
    _DashboardModule(
      title: 'Self-Assessment',
      subtitle: 'Reflect on yourself',
      description: 'Answer published self-assessment questions.',
      icon: Icons.fact_check_outlined,
    ),
    _DashboardModule(
      title: 'My Tasks',
      subtitle: 'Plan your daily activities',
      description: 'Manage your personal tasks and calendar.',
      icon: Icons.event_available_outlined,
    ),
    _DashboardModule(
      title: 'Wellness Tips',
      subtitle: 'Explore helpful resources',
      description: 'Read wellness tips and emotional support resources.',
      icon: Icons.spa_outlined,
    ),
  ];

  static const _DashboardModule _profile = _DashboardModule(
    title: 'My Profile',
    subtitle: 'Manage your account',
    description: 'View and manage your SafeSpace profile.',
    icon: Icons.person_outline_rounded,
  );

  // ======================================
  // NAVIGATION
  // ======================================
  void _openJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalScreen()),
    );
  }

  void _openMoodTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodScreen()),
    );
  }

  void _openAssessment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssessmentScreen()),
    );
  }

  void _openTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TasksScreen()),
    );
  }

  void _openWellness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WellnessScreen()),
    );
  }

  // ======================================
  // OPEN AI CHATBOT
  // ======================================
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _openModule(_DashboardModule module) {
    switch (module.title) {
      case 'AI Chatbot':
        _openChat();
        return;

      case 'Community Journal':
        _openJournal();
        return;

      case 'Mood Tracker':
        _openMoodTracker();
        return;

      case 'Self-Assessment':
        _openAssessment();
        return;

      case 'My Tasks':
        _openTasks();
        return;

      case 'Wellness Tips':
        _openWellness();
        return;
    }

    // Other unfinished modules, such as Profile
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModulePlaceholderScreen(
          title: module.title,
          description: module.description,
          icon: module.icon,
        ),
      ),
    );
  }

  void _onNavigationSelected(int index) {
    switch (index) {
      case 0:
        // Already on Home
        break;

      case 1:
        _openJournal();
        break;

      case 2:
        _openChat();
        break;

      case 3:
        _openTasks();
        break;

      case 4:
        _openModule(_profile);
        break;
    }
  }

  // ======================================
  // LOGOUT
  // ======================================
  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out of SafeSpace?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8E7AB5),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await _logout();
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    final success = await AuthService.logout();

    if (!mounted) return;

    setState(() {
      _isLoggingOut = false;
    });

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Check your server connection.'),
        ),
      );
    }
  }

  // ======================================
  // GREETING
  // ======================================
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';

    return 'Good Evening';
  }

  // ======================================
  // WELCOME BANNER
  // ======================================
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E7AB5), Color(0xFFA992CF)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}! 💜',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),

          const SizedBox(height: 10),

          Text(
            'Welcome, ${widget.username}!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'You deserve a safe place to express yourself. Take things one step at a time.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ======================================
  // DAILY MOOD CHECK-IN
  // ======================================
  Widget _buildMoodCheckIn() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _openAssessment,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFF8E7AB5),
                    size: 26,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Text(
                'Take a short self-assessment to reflect on your mood.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              SizedBox(height: 18),

              Card(
                elevation: 0,
                color: Color(0xFFEEE7F6),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Center(
                    child: Text(
                      'Start Mood Check-In',
                      style: TextStyle(
                        color: Color(0xFF594780),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================
  // FEATURE CARD
  // ======================================
  Widget _buildFeatureCard(_DashboardModule module) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openModule(module),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 142,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE7F6),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(module.icon, color: const Color(0xFF8E7AB5)),
                ),

                const Spacer(),

                Text(
                  module.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  module.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================================
  // RESPONSIVE GRID
  // ======================================
  Widget _buildModuleGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;

        final cardWidth = constraints.maxWidth < 330
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _modules.map((module) {
            return SizedBox(width: cardWidth, child: _buildFeatureCard(module));
          }).toList(),
        );
      },
    );
  }

  // ======================================
  // MAIN HOME DASHBOARD
  // ======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8F6FC),

        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              color: Color(0xFF8E7AB5),
              size: 28,
            ),

            SizedBox(width: 10),

            Text(
              'SafeSpace',
              style: TextStyle(
                color: Color(0xFF594780),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _isLoggingOut ? null : _confirmLogout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF594780)),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeBanner(),

                    const SizedBox(height: 25),

                    _buildMoodCheckIn(),

                    const SizedBox(height: 30),

                    const Text(
                      'Explore SafeSpace',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Choose what you need today.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 18),

                    _buildModuleGrid(),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE6F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFF8E7AB5),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'Your feelings matter. Take your time, and be kind to yourself.',
                              style: TextStyle(
                                color: Color(0xFF594780),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // ======================================
      // BOTTOM NAVIGATION
      // ======================================
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8DFF5),
        selectedIndex: 0,
        onDestinationSelected: _onNavigationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chatbot',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            selectedIcon: Icon(Icons.task_alt_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
