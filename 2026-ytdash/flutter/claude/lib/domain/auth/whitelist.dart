/// Pure whitelist check: an authorized email may access the app; anything else is denied.
/// Comparison is case-insensitive and trims whitespace (real email input is not case-sensitive
/// in practice, and Google account emails are always lowercase already).
bool isAuthorized(String email, Iterable<String> authorizedEmails) {
  final normalized = email.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return authorizedEmails.any((e) => e.trim().toLowerCase() == normalized);
}

/// Parses the comma-separated `authorizedEmails` launch extra / build config into a clean list.
List<String> parseAuthorizedEmails(String csv) => csv
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList(growable: false);
