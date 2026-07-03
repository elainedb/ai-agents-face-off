import 'package:flutter/services.dart';

class TestConfig {
  final bool uiTestMode;
  final String? mockAuthEmail;
  final String apiBaseUrl;
  final String apiKey;
  final List<String> authorizedEmails;
  final bool captureExternalLinks;

  TestConfig({
    required this.uiTestMode,
    this.mockAuthEmail,
    required this.apiBaseUrl,
    required this.apiKey,
    required this.authorizedEmails,
    required this.captureExternalLinks,
  });

  static const _channel = MethodChannel('ytdash/testconfig');

  /// Loads the test configuration from Android intent extras via MethodChannel.
  /// If [uiTestMode] is false or MethodChannel call fails, uses the [defaultBaseUrl] and [defaultApiKey].
  static Future<TestConfig> load({
    required String defaultBaseUrl,
    required String defaultApiKey,
    required List<String> defaultEmails,
  }) async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('get');
      if (map != null) {
        final bool uiTest = map['uiTestMode'] as bool? ?? false;
        final String? mockEmail = map['mockAuthEmail'] as String?;
        final String? intentBaseUrl = map['apiBaseUrl'] as String?;
        final String? intentKey = map['apiKey'] as String?;
        final String? intentEmails = map['authorizedEmails'] as String?;
        final bool captureLinks = map['captureExternalLinks'] as bool? ?? false;

        // Parse whitelist
        List<String> emails = defaultEmails;
        if (intentEmails != null && intentEmails.isNotEmpty) {
          emails = intentEmails
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        return TestConfig(
          uiTestMode: uiTest,
          mockAuthEmail: mockEmail,
          apiBaseUrl: (intentBaseUrl != null && intentBaseUrl.isNotEmpty)
              ? intentBaseUrl
              : defaultBaseUrl,
          apiKey: (intentKey != null && intentKey.isNotEmpty)
              ? intentKey
              : defaultApiKey,
          authorizedEmails: emails,
          captureExternalLinks: captureLinks,
        );
      }
    } catch (e) {
      // Fallback on platform channel error
      print('MethodChannel error reading test config: $e');
    }

    return TestConfig(
      uiTestMode: false,
      mockAuthEmail: null,
      apiBaseUrl: defaultBaseUrl,
      apiKey: defaultApiKey,
      authorizedEmails: defaultEmails,
      captureExternalLinks: false,
    );
  }

  @override
  String toString() {
    return 'TestConfig(uiTestMode: $uiTestMode, mockAuthEmail: $mockAuthEmail, apiBaseUrl: $apiBaseUrl, apiKey: $apiKey, authorizedEmails: $authorizedEmails, captureExternalLinks: $captureExternalLinks)';
  }
}
