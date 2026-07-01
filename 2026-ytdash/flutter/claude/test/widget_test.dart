import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/core/app_config.dart';
import 'package:ytdash_flutter/presentation/app_root.dart';

void main() {
  testWidgets('shows the login screen with a Google sign-in button on startup', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              apiBaseUrl: 'http://127.0.0.1:8090',
              apiKey: 'test-key',
              authorizedEmails: ['allow@example.com'],
              uiTestMode: true,
              mockAuthEmail: 'allow@example.com',
              captureExternalLinks: true,
            ),
          ),
        ],
        child: const MaterialApp(home: AppRoot()),
      ),
    );

    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
