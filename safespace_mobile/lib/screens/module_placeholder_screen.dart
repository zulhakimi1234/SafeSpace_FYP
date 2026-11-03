import 'package:flutter/material.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DFF5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(icon, color: const Color(0xFF8E7AB5), size: 48),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF594780),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.construction_rounded,
                          size: 38,
                          color: Color(0xFF8E7AB5),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Module Under Development',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This feature will be available after its implementation is completed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8E7AB5),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
