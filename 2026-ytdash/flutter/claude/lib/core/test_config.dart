import 'package:flutter/services.dart';

/// Runtime configuration sourced from Android launch-intent extras (constitution §4).
///
/// The same compiled build talks to the mock or the real YouTube Data API by swapping
/// [apiBaseUrl] + [apiKey] at launch — nothing is baked in at compile time. Outside UI test
/// mode the app behaves normally (real Google sign-in, real external launch, production host).
class TestConfig {
  const TestConfig({
    this.uiTestMode = false,
    this.mockAuthEmail,
    this.apiBaseUrl,
    this.apiKey,
    this.authorizedEmails,
    this.captureExternalLinks = false,
  });

  final bool uiTestMode;
  final String? mockAuthEmail;
  final String? apiBaseUrl;
  final String? apiKey;
  final String? authorizedEmails;
  final bool captureExternalLinks;

  static const MethodChannel _channel = MethodChannel('ytdash/testconfig');

  /// Production host root. The app appends `/youtube/v3/<endpoint>` itself, so the base is the
  /// host only (constitution §2 / youtube-api.md).
  static const String productionApiBase = 'https://www.googleapis.com';

  /// Default whitelist for production (overridden by the `authorizedEmails` extra in test mode).
  static const List<String> defaultAuthorizedEmails = <String>[
    'user1@example.com',
    'user2@example.com',
  ];

  String get effectiveApiBase {
    final base = apiBaseUrl;
    if (base != null && base.isNotEmpty) return base.replaceAll(RegExp(r'/+$'), '');
    return productionApiBase;
  }

  List<String> get authorizedEmailList {
    final raw = authorizedEmails;
    if (raw != null && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return defaultAuthorizedEmails.map((e) => e.toLowerCase()).toList();
  }

  /// Reads the host Activity intent extras once at startup. Never throws — falls back to a
  /// production (non-test) config if the channel is unavailable.
  static Future<TestConfig> load() async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('get');
      if (map == null) return const TestConfig();
      return TestConfig(
        uiTestMode: map['uiTestMode'] as bool? ?? false,
        mockAuthEmail: map['mockAuthEmail'] as String?,
        apiBaseUrl: map['apiBaseUrl'] as String?,
        apiKey: map['apiKey'] as String?,
        authorizedEmails: map['authorizedEmails'] as String?,
        captureExternalLinks: map['captureExternalLinks'] as bool? ?? false,
      );
    } catch (_) {
      return const TestConfig();
    }
  }
}
