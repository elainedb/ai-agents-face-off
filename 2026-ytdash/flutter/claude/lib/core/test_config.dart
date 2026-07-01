import 'package:flutter/services.dart';

/// Runtime configuration read from Android intent extras (constitution §4).
///
/// The extras are delivered to the launched Activity regardless of framework; Flutter
/// surfaces them to Dart via a MethodChannel read once, before `runApp()`.
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
  final String? apiBaseUrl;
  final String? apiKey;
  final String? authorizedEmails;
  final bool captureExternalLinks;

  static const _channel = MethodChannel('ytdash/testconfig');

  /// Production default: no test mode, no overrides — the app behaves normally.
  static const disabled = TestConfig(
    uiTestMode: false,
    mockAuthEmail: null,
    apiBaseUrl: null,
    apiKey: null,
    authorizedEmails: null,
    captureExternalLinks: false,
  );

  static Future<TestConfig> load() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('get');
      if (raw == null) return disabled;
      return TestConfig(
        uiTestMode: raw['uiTestMode'] as bool? ?? false,
        mockAuthEmail: raw['mockAuthEmail'] as String?,
        apiBaseUrl: raw['apiBaseUrl'] as String?,
        apiKey: raw['apiKey'] as String?,
        authorizedEmails: raw['authorizedEmails'] as String?,
        captureExternalLinks: raw['captureExternalLinks'] as bool? ?? false,
      );
    } on PlatformException {
      return disabled;
    } on MissingPluginException {
      return disabled;
    }
  }

  List<String> get authorizedEmailList {
    final csv = authorizedEmails;
    if (csv == null || csv.trim().isEmpty) return const [];
    return csv
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
