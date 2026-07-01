/// Pure whitelist check — the domain rule under test, independent of how the email was obtained.
bool isAuthorizedEmail(String email, List<String> whitelist) {
  final normalized = email.trim().toLowerCase();
  return whitelist.any((allowed) => allowed.trim().toLowerCase() == normalized);
}
