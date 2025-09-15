import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemini/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is displayed.
    expect(find.text('Login with Google'), findsOneWidget);

    // Verify that the sign-in button is displayed.
    expect(find.widgetWithText(ElevatedButton, 'Sign in with Google'), findsOneWidget);
  });
}