import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static late final TestConfig instance;

  static Future<void> init() async {
    const channel = MethodChannel('ytdash/testconfig');
    try {
      final map = await channel.invokeMapMethod<String, dynamic>('get');
      print('TEST CONFIG MAP: $map');
      bool parseBool(dynamic value) {
        if (value is bool) return value;
        if (value is String) return value.toLowerCase() == 'true';
        return false;
      }
      instance = TestConfig(
        uiTestMode: parseBool(map?['uiTestMode']),
        mockAuthEmail: map?['mockAuthEmail'] as String?,
        apiBaseUrl: map?['apiBaseUrl'] as String?,
        apiKey: map?['apiKey'] as String?,
        authorizedEmails: map?['authorizedEmails'] as String?,
        captureExternalLinks: parseBool(map?['captureExternalLinks']),
      );
    } catch (e) {
      // Fallback if MethodChannel not implemented (e.g. running on non-Android or before we set it up)
      instance = TestConfig(
        uiTestMode: false,
        captureExternalLinks: false,
      );
    }
    
    if (instance.uiTestMode) {
      SharedPreferences.setMockInitialValues({});
    }
  }
}
