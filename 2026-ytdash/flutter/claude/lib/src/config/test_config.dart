import 'package:flutter/services.dart';

/// Runtime configuration delivered via Android launch-intent extras
/// (the UI-test-mode contract, constitution §4). Read once at startup from the
/// host Activity through a [MethodChannel]; never baked in at compile time.
class TestConfig {
  const TestConfig({
    this.uiTestMode = false,
    this.mockAuthEmail,
    this.apiBaseUrl,
    this.apiKey,
    this.authorizedEmails,
    this.captureExternalLinks = false,
  });

  /// Master switch for all deterministic test behavior.
  final bool uiTestMode;

  /// When set, signing in skips the real Google picker and uses this email.
  final String? mockAuthEmail;

  /// Overrides the API host root (mock server or real YouTube).
  final String? apiBaseUrl;

  /// YouTube Data API key, read at runtime so one build serves mock + real.
  final String? apiKey;

  /// Comma-separated whitelist override for the run.
  final String? authorizedEmails;

  /// When true, "open in YouTube" surfaces the URL instead of launching.
  final bool captureExternalLinks;

  /// Parsed whitelist; empty when nothing was supplied.
  List<String> get authorizedEmailList => (authorizedEmails ?? '')
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();

  static const MethodChannel _channel = MethodChannel('ytdash/testconfig');

  /// Reads the launch extras from the host Activity. Falls back to a
  /// production-mode config if the channel is unavailable.
  static Future<TestConfig> fromHost() async {
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('get');
      if (map == null) return const TestConfig();
      return TestConfig(
        uiTestMode: map['uiTestMode'] == true,
        mockAuthEmail: _str(map['mockAuthEmail']),
        apiBaseUrl: _str(map['apiBaseUrl']),
        apiKey: _str(map['apiKey']),
        authorizedEmails: _str(map['authorizedEmails']),
        captureExternalLinks: map['captureExternalLinks'] == true,
      );
    } catch (_) {
      return const TestConfig();
    }
  }

  static String? _str(Object? v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }
}
