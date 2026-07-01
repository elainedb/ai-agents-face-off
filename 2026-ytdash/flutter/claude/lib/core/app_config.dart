import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth/whitelist.dart';
import 'test_config.dart';

/// Merges the UI-test-mode extras with compile-time production defaults into the config the rest
/// of the app actually reads. This is the single seam that lets one build talk to the mock or the
/// real YouTube Data API by swapping only `apiBaseUrl`/`apiKey`/`authorizedEmails` (constitution §4).
///
/// Production (no test extras) falls back to `--dart-define` values supplied at *build* time from
/// `config/secrets.env` (gitignored) — never compiled-in literals. An unconfigured production build
/// fails closed (empty whitelist, denying everyone) rather than open.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.apiKey,
    required this.authorizedEmails,
    required this.uiTestMode,
    required this.mockAuthEmail,
    required this.captureExternalLinks,
  });

  static const String _prodApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );
  static const String _prodAuthorizedEmails = String.fromEnvironment(
    'PROD_AUTHORIZED_EMAILS',
    defaultValue: '',
  );
  static const String _defaultRealBaseUrl = 'https://www.googleapis.com';

  final String apiBaseUrl;
  final String apiKey;
  final List<String> authorizedEmails;
  final bool uiTestMode;
  final String? mockAuthEmail;
  final bool captureExternalLinks;

  factory AppConfig.from(TestConfig test) {
    final baseUrl = (test.apiBaseUrl != null && test.apiBaseUrl!.isNotEmpty)
        ? test.apiBaseUrl!
        : _defaultRealBaseUrl;
    final apiKey = (test.apiKey != null && test.apiKey!.isNotEmpty)
        ? test.apiKey!
        : _prodApiKey;
    final whitelistCsv =
        (test.authorizedEmails != null && test.authorizedEmails!.isNotEmpty)
        ? test.authorizedEmails!
        : _prodAuthorizedEmails;
    return AppConfig(
      apiBaseUrl: baseUrl,
      apiKey: apiKey,
      authorizedEmails: parseAuthorizedEmails(whitelistCsv),
      uiTestMode: test.uiTestMode,
      mockAuthEmail: test.mockAuthEmail,
      captureExternalLinks: test.captureExternalLinks,
    );
  }
}

/// Overridden once at app startup (see `main.dart`) with the config resolved from `TestConfig.load()`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(
    'appConfigProvider must be overridden at ProviderScope root',
  ),
);
