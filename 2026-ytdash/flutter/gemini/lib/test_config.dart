import 'package:flutter/services.dart';

class TestConfig {
  final bool uiTestMode;
  final String? mockAuthEmail;
  final String? apiBaseUrl;
  final String? authorizedEmails;
  final bool captureExternalLinks;
  final String? apiKey;

  const TestConfig({
    required this.uiTestMode,
    this.mockAuthEmail,
    this.apiBaseUrl,
    this.authorizedEmails,
    required this.captureExternalLinks,
    this.apiKey,
  });

  static const _ch = MethodChannel('ytdash/testconfig');
  static TestConfig? _instance;

  static Future<void> init() async {
    try {
      final map = await _ch.invokeMapMethod<String, dynamic>('get');
      _instance = TestConfig(
        uiTestMode: map?['uiTestMode'] as bool? ?? false,
        mockAuthEmail: map?['mockAuthEmail'] as String?,
        apiBaseUrl: map?['apiBaseUrl'] as String?,
        authorizedEmails: map?['authorizedEmails'] as String?,
        captureExternalLinks: map?['captureExternalLinks'] as bool? ?? false,
        apiKey: map?['apiKey'] as String?,
      );
    } catch (e) {
      _instance = const TestConfig(
        uiTestMode: false,
        captureExternalLinks: false,
      );
    }
  }

  static TestConfig get instance =>
      _instance ??
      const TestConfig(uiTestMode: false, captureExternalLinks: false);
}
