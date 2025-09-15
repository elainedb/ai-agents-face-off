#!/usr/bin/env dart

import 'dart:io';

void main() {
  final configFile = File('lib/config/auth_config.dart');

  if (!configFile.existsSync()) {
    print('auth_config.dart missing, creating CI-safe version...');

    final ciConfig = '''/// Authentication configuration (CI-safe fallback)
///
/// This file was auto-generated because auth_config.dart was missing.
/// Contains empty authorized emails list for CI safety.
class AuthConfig {
  /// Empty list of authorized emails for CI safety
  static const List<String> authorizedEmails = <String>[];
}
''';

    configFile.writeAsStringSync(ciConfig);
    print('Created CI-safe auth_config.dart');
  } else {
    print('auth_config.dart already exists');
  }
}