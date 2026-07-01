// Access control: a signed-in user is allowed in only if their email is on the whitelist.
// Case-insensitive, whitespace-tolerant.
export function isAuthorized(email: string | null | undefined, whitelist: string[]): boolean {
  if (!email) return false;
  const normalized = email.trim().toLowerCase();
  if (!normalized) return false;
  return whitelist.map((e) => e.trim().toLowerCase()).includes(normalized);
}
