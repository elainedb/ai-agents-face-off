export function parseWhitelist(csv: string): string[] {
  return csv
    .split(',')
    .map((e) => e.trim().toLowerCase())
    .filter((e) => e.length > 0);
}

export function isAuthorizedEmail(email: string, whitelistCsv: string): boolean {
  const normalized = email.trim().toLowerCase();
  if (!normalized) return false;
  return parseWhitelist(whitelistCsv).includes(normalized);
}
