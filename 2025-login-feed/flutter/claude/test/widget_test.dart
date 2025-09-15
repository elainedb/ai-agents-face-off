// Flutter widget test for authentication app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_claude/config/auth_config.dart';

void main() {
  test('AuthConfig has authorized emails list', () {
    // Test that the config is properly structured
    expect(AuthConfig.authorizedEmails, isA<List<String>>());
  });

  test('AuthConfig authorizedEmails is not null', () {
    // Simple test to ensure the configuration loads
    expect(AuthConfig.authorizedEmails, isNotNull);
  });
}
