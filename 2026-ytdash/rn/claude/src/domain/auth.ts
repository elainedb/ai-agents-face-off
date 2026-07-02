// Auth whitelist rule: an email is authorized iff it (case-insensitively) appears in the
// configured whitelist. Pure and framework-free so it's directly unit testable.
export function isAuthorized(email: string | null | undefined, whitelist: string[]): boolean {
  if (!email) return false;
  const needle = email.trim().toLowerCase();
  if (!needle) return false;
  return whitelist.some((w) => w.trim().toLowerCase() === needle);
}
