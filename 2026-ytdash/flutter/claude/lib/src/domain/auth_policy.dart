/// Pure access-control logic: an email is authorized iff it appears on the
/// whitelist (case-insensitive, whitespace-trimmed). Kept free of any UI or
/// network dependency so it is trivially unit-testable.
class AuthPolicy {
  const AuthPolicy(this.authorizedEmails);

  final List<String> authorizedEmails;

  bool isAuthorized(String? email) {
    if (email == null) return false;
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return authorizedEmails
        .map((e) => e.trim().toLowerCase())
        .contains(normalized);
  }
}
