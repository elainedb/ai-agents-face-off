import 'package:flutter/services.dart';

/// The raw UI-test-mode launch extras (constitution §4), read once at startup from the host
/// Activity's intent via a MethodChannel (Flutter has no direct API for Android intent extras).
class TestConfig {
  const TestConfig({
    required this.uiTestMode,
    required this.mockAuthEmail,
    required this.apiBaseUrl,
    required this.apiKey,
    required this.authorizedEmails,
    required this.captureExternalLinks,
  });

  const TestConfig.disabled()
    : uiTestMode = false,
      mockAuthEmail = null,
      apiBaseUrl = null,
      apiKey = null,
      authorizedEmails = null,
      captureExternalLinks = false;

  final bool uiTestMode;
  final String? mockAuthEmail;
  final String? apiBaseUrl;
  final String? apiKey;
  final String? authorizedEmails;
  final bool captureExternalLinks;

  static const MethodChannel _channel = MethodChannel('ytdash/testconfig');

  /// Reads the launch extras once. If the platform channel is unavailable (non-Android, or the
  /// host activity wiring is missing), fails safe to production behavior (disabled).
  static Future<TestConfig> load() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('get');
      if (raw == null) return const TestConfig.disabled();
      return TestConfig(
        uiTestMode: raw['uiTestMode'] as bool? ?? false,
        mockAuthEmail: raw['mockAuthEmail'] as String?,
        apiBaseUrl: raw['apiBaseUrl'] as String?,
        apiKey: raw['apiKey'] as String?,
        authorizedEmails: raw['authorizedEmails'] as String?,
        captureExternalLinks: raw['captureExternalLinks'] as bool? ?? false,
      );
    } on MissingPluginException {
      return const TestConfig.disabled();
    } on PlatformException {
      return const TestConfig.disabled();
    }
  }
}
