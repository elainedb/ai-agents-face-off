/// Access control: a signed-in user is admitted only if their email is on the whitelist
/// (spec §Users & access; AC-LOGIN-01/02). Case-insensitive, trimmed.
class AuthPolicy {
  const AuthPolicy(this.authorizedEmails);

  final List<String> authorizedEmails;

  bool isAuthorized(String? email) {
    if (email == null) return false;
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return authorizedEmails.map((e) => e.trim().toLowerCase()).contains(normalized);
  }
}
