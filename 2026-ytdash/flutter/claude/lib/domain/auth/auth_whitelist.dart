/// Whitelist check — pure, no Flutter/network dependency, so it's directly unit-testable.
bool isAuthorized(String email, List<String> whitelist) {
  final normalized = email.trim().toLowerCase();
  return whitelist.any((w) => w.trim().toLowerCase() == normalized);
}
