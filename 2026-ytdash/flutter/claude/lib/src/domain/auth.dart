/// Access control: a signed-in email is allowed in only if it is on the
/// whitelist (spec §Users & access). Case-insensitive, whitespace-trimmed.
bool isAuthorized(String? email, List<String> whitelist) {
  if (email == null) return false;
  final e = email.trim().toLowerCase();
  if (e.isEmpty) return false;
  return whitelist.any((w) => w.trim().toLowerCase() == e);
}
