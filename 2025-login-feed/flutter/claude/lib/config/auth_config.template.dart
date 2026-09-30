/// Authentication configuration template
///
/// Copy this file to 'auth_config.dart' and customize with your authorized email addresses.
/// The 'auth_config.dart' file should not be committed to version control.
///
/// Usage:
/// 1. Copy this file: cp auth_config.template.dart auth_config.dart
/// 2. Edit auth_config.dart to add your authorized email addresses
/// 3. The auth_config.dart file is automatically ignored by git
class AuthConfig {
  /// List of email addresses authorized to access the application
  /// Replace these example emails with your actual authorized email addresses
  static const List<String> authorizedEmails = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
  ];
}