#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('Ensuring configuration files exist...');

  // Ensure auth_config.dart exists
  final authConfigFile = File('lib/config/auth_config.dart');
  if (!authConfigFile.existsSync()) {
    print('Creating auth_config.dart from template...');
    final authCiConfig = '''class AuthConfig {
  static const List<String> authorizedEmails = <String>[];
}
''';
    authConfigFile.writeAsStringSync(authCiConfig);
    print('Created auth_config.dart');
  } else {
    print('auth_config.dart already exists');
  }

  // Ensure config.dart exists
  final configFile = File('lib/config/config.dart');
  if (!configFile.existsSync()) {
    print('Creating config.dart from template...');
    final configCiSafe = '''class Config {
  static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
}
''';
    configFile.writeAsStringSync(configCiSafe);
    print('Created config.dart');
  } else {
    print('config.dart already exists');
  }

  print('All configuration files are ready.');
}
