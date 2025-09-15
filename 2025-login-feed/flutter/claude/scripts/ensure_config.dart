#!/usr/bin/env dart

import 'dart:io';

void main() {
  final configFile = File('lib/config/auth_config.dart');

  if (!configFile.existsSync()) {


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

  } else {

  }
}