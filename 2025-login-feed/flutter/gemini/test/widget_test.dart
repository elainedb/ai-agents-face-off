import 'package:flutter/material.dart';
import 'package:flutter_gemini/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

void main() {
  setUp(() async {
    await setupTestDependencies();
  });

  testWidgets('App starts with LoginPage and shows login button',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Allow the widget to settle.
    await tester.pumpAndSettle();

    // Verify that the LoginPage is displayed.
    expect(find.text('Login with Google'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
