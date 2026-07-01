/** Whitelist check — the single access rule (spec §Users & access, AC-LOGIN-01/02). */
export function isAuthorized(email: string | null | undefined, whitelist: string[]): boolean {
  if (!email) return false;
  const normalized = email.trim().toLowerCase();
  if (!normalized) return false;
  return whitelist.some((w) => w.trim().toLowerCase() === normalized);
}
