import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safespace_mobile/screens/login_screen.dart';
import 'package:safespace_mobile/screens/home_screen.dart';
import 'package:safespace_mobile/screens/chat_screen.dart';

void main() {
  // ======================================
  // TEST 1: LOGIN UI
  // ======================================
  testWidgets('SafeSpace Login Screen Test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('SafeSpace'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ======================================
  // TEST 2: HOME -> CHATBOT NAVIGATION
  // ======================================
  testWidgets('SafeSpace Home Chatbot Navigation Test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(username: 'mobileuser01')),
    );

    expect(find.text('Welcome, mobileuser01!'), findsOneWidget);

    final chatbotCard = find.text('AI Chatbot');

    await tester.ensureVisible(chatbotCard);
    await tester.pumpAndSettle();

    await tester.tap(chatbotCard);
    await tester.pumpAndSettle();

    expect(find.text('SafeSpace AI'), findsOneWidget);

    expect(find.byType(TextField), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  // ======================================
  // TEST 3: CHATBOT UI
  // ======================================
  testWidgets('SafeSpace Chatbot Screen Test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

    expect(find.text('SafeSpace AI'), findsOneWidget);

    expect(find.text('Powered by Ollama Llama 3'), findsOneWidget);

    expect(find.byType(TextField), findsOneWidget);

    expect(find.byTooltip('Send Message'), findsOneWidget);

    expect(find.byTooltip('Clear Conversation'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
