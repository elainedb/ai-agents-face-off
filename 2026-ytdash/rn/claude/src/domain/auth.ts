// Authorization rule (domain layer). A signed-in user is admitted only if their email is on the
// whitelist, case-insensitively. Pure + unit-tested (AC-LOGIN-01/02).

export function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

export function isAuthorized(email: string | null | undefined, whitelist: string[]): boolean {
  if (!email) return false;
  const target = normalizeEmail(email);
  if (!target) return false;
  return whitelist.map(normalizeEmail).includes(target);
}
