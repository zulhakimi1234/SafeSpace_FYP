import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SafeSpaceApp());
}

class SafeSpaceApp extends StatelessWidget {
  const SafeSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeSpace',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E7AB5)),
        scaffoldBackgroundColor: const Color(0xFFF8F6FC),
        fontFamily: 'Roboto',
      ),

      home: const AuthGate(),
    );
  }
}

// Check login session on app startup
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();

    _userFuture = AuthService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        // Waiting for session check
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF8E7AB5)),
            ),
          );
        }

        final user = snapshot.data;

        // Existing valid session
        if (user != null) {
          return HomeScreen(username: user['username']?.toString() ?? 'User');
        }

        // Not logged in
        return const LoginScreen();
      },
    );
  }
}
