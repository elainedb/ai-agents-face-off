import 'package:flutter/services.dart';

/// Runtime configuration read from Android launch-intent extras (constitution §4), with
/// production fallbacks used when the app is launched normally (no Maestro/UI-test-mode extras).
class TestConfig {
  const TestConfig({
    required this.uiTestMode,
    required this.mockAuthEmail,
    required this.apiBaseUrl,
    required this.apiKey,
    required this.authorizedEmails,
    required this.captureExternalLinks,
  });

  final bool uiTestMode;
  final String? mockAuthEmail;
  final String apiBaseUrl;
  final String apiKey;
  final List<String> authorizedEmails;
  final bool captureExternalLinks;

  static const _channel = MethodChannel('ytdash/testconfig');

  // Production defaults — used whenever the corresponding launch extra is absent, so a normal
  // (non-Maestro) launch still works against the real API without a rebuild.
  static const _defaultBaseUrl = 'https://www.googleapis.com';
  static const _defaultApiKey = String.fromEnvironment('YOUTUBE_API_KEY');
  static const _defaultAuthorizedEmails = <String>[
    'user1@example.com',
    'user2@example.com',
  ];

  static Future<TestConfig> load() async {
    Map<Object?, Object?>? extras;
    try {
      extras = await _channel.invokeMapMethod<Object?, Object?>('get');
    } on PlatformException {
      extras = null;
    } on MissingPluginException {
      extras = null;
    }

    final authorizedEmailsCsv = extras?['authorizedEmails'] as String?;
    return TestConfig(
      uiTestMode: (extras?['uiTestMode'] as bool?) ?? false,
      mockAuthEmail: extras?['mockAuthEmail'] as String?,
      apiBaseUrl: (extras?['apiBaseUrl'] as String?) ?? _defaultBaseUrl,
      apiKey: (extras?['apiKey'] as String?) ?? _defaultApiKey,
      authorizedEmails:
          authorizedEmailsCsv != null && authorizedEmailsCsv.isNotEmpty
          ? authorizedEmailsCsv
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : _defaultAuthorizedEmails,
      captureExternalLinks: (extras?['captureExternalLinks'] as bool?) ?? false,
    );
  }
}
