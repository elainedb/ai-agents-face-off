import 'package:flutter/services.dart';

/// Runtime configuration delivered as Android intent extras (constitution §4).
///
/// Read ONCE in `main()` via a MethodChannel against the host Activity's intent.
/// Outside UI-test-mode the app behaves normally (real Google sign-in, real
/// external launch, real/default API base).
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
  final List<String>? authorizedEmails;
  final bool captureExternalLinks;

  static const MethodChannel _channel = MethodChannel('ytdash/testconfig');

  static Future<TestConfig> load() async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('get');
      if (map == null) return const TestConfig();
      final emails = (map['authorizedEmails'] as String?)
          ?.split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return TestConfig(
        uiTestMode: _asBool(map['uiTestMode']),
        mockAuthEmail: _asNonEmpty(map['mockAuthEmail']),
        apiBaseUrl: _asNonEmpty(map['apiBaseUrl']),
        apiKey: _asNonEmpty(map['apiKey']),
        authorizedEmails: (emails != null && emails.isNotEmpty) ? emails : null,
        captureExternalLinks: _asBool(map['captureExternalLinks']),
      );
    } catch (_) {
      // No host channel (e.g. unit test) → production defaults.
      return const TestConfig();
    }
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v == 'true' || v == '1';
    return false;
  }

  static String? _asNonEmpty(dynamic v) {
    if (v is String && v.isNotEmpty) return v;
    return null;
  }
}
