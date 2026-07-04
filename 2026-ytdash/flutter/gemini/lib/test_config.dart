import 'package:flutter/services.dart';

class TestConfig {
  final bool uiTestMode;
  final String? mockAuthEmail;
  final String? apiBaseUrl;
  final String? authorizedEmails;
  final bool captureExternalLinks;
  final String? apiKey;

  TestConfig({
    required this.uiTestMode,
    this.mockAuthEmail,
    this.apiBaseUrl,
    this.authorizedEmails,
    required this.captureExternalLinks,
    this.apiKey,
  });

  static late final TestConfig instance;

  static Future<void> init() async {
    const channel = MethodChannel('ytdash/testconfig');
    final map = await channel.invokeMapMethod<String, dynamic>('get');
    
    instance = TestConfig(
      uiTestMode: map?['uiTestMode'] as bool? ?? false,
      mockAuthEmail: map?['mockAuthEmail'] as String?,
      apiBaseUrl: map?['apiBaseUrl'] as String?,
      authorizedEmails: map?['authorizedEmails'] as String?,
      captureExternalLinks: map?['captureExternalLinks'] as bool? ?? false,
      apiKey: map?['apiKey'] as String?,
    );
  }
}
