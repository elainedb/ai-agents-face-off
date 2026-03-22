import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ytdash_flutter_codex/features/authentication/presentation/pages/login_page.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.text('Login with Google'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
