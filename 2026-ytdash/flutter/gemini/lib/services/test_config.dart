import 'package:flutter/services.dart';

class TestConfig {
  static const MethodChannel _channel = MethodChannel('ytdash/testconfig');

  final bool uiTestMode;
  final String? mockAuthEmail;
  final String? apiBaseUrl;
  final String? apiKey;
  final List<String> authorizedEmails;
  final bool captureExternalLinks;

  TestConfig({
    required this.uiTestMode,
    this.mockAuthEmail,
    this.apiBaseUrl,
    this.apiKey,
    required this.authorizedEmails,
    required this.captureExternalLinks,
  });

  static Future<TestConfig> load() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod<Map<dynamic, dynamic>>('get');
      if (result != null) {
        final bool uiTestMode = result['uiTestMode'] as bool? ?? false;
        final String? mockAuthEmail = result['mockAuthEmail'] as String?;
        final String? apiBaseUrl = result['apiBaseUrl'] as String?;
        final String? apiKey = result['apiKey'] as String?;
        final String? authEmailsStr = result['authorizedEmails'] as String?;
        
        List<String> authorizedEmails = ['user1@example.com', 'user2@example.com'];
        if (authEmailsStr != null && authEmailsStr.isNotEmpty) {
          authorizedEmails = authEmailsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }

        final bool captureExternalLinks = result['captureExternalLinks'] as bool? ?? false;

        return TestConfig(
          uiTestMode: uiTestMode,
          mockAuthEmail: mockAuthEmail,
          apiBaseUrl: apiBaseUrl,
          apiKey: apiKey,
          authorizedEmails: authorizedEmails,
          captureExternalLinks: captureExternalLinks,
        );
      }
    } catch (e) {
      print('Failed to load test config via MethodChannel: $e');
    }

    return TestConfig(
      uiTestMode: false,
      mockAuthEmail: null,
      apiBaseUrl: null,
      apiKey: null,
      authorizedEmails: ['user1@example.com', 'user2@example.com'],
      captureExternalLinks: false,
    );
  }
}
