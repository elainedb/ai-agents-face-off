import 'package:flutter/services.dart';

class TestConfig {
  final bool uiTestMode;
  final String? mockAuthEmail;
  final String? apiBaseUrl;
  final String? apiKey;
  final String? authorizedEmails;
  final bool captureExternalLinks;

  TestConfig({
    required this.uiTestMode,
    this.mockAuthEmail,
    this.apiBaseUrl,
    this.apiKey,
    this.authorizedEmails,
    required this.captureExternalLinks,
  });

  static const _channel = MethodChannel('ytdash/testconfig');

  static Future<TestConfig> load() async {
    try {
      final config = await _channel.invokeMapMethod<String, dynamic>('get');
      if (config == null) {
        return TestConfig(uiTestMode: false, captureExternalLinks: false);
      }
      return TestConfig(
        uiTestMode: config['uiTestMode'] as bool? ?? false,
        mockAuthEmail: config['mockAuthEmail'] as String?,
        apiBaseUrl: config['apiBaseUrl'] as String?,
        apiKey: config['apiKey'] as String?,
        authorizedEmails: config['authorizedEmails'] as String?,
        captureExternalLinks: config['captureExternalLinks'] as bool? ?? false,
      );
    } catch (_) {
      return TestConfig(uiTestMode: false, captureExternalLinks: false);
    }
  }

  // Returns the resolved apiBaseUrl (points to mock or real)
  String getResolvedBaseUrl() {
    if (uiTestMode && apiBaseUrl != null && apiBaseUrl!.isNotEmpty) {
      // Remove trailing slash if any
      var url = apiBaseUrl!;
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      return url;
    }
    // Default real base URL
    return 'https://www.googleapis.com';
  }

  // Returns the resolved apiKey (read from extras, otherwise from secrets)
  String getResolvedApiKey(String secretsApiKey) {
    if (uiTestMode && apiKey != null && apiKey!.isNotEmpty) {
      return apiKey!;
    }
    return secretsApiKey;
  }

  // Returns list of whitelisted emails
  List<String> getWhitelistedEmails(List<String> defaultWhitelist) {
    if (uiTestMode && authorizedEmails != null && authorizedEmails!.isNotEmpty) {
      return authorizedEmails!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return defaultWhitelist;
  }
}
