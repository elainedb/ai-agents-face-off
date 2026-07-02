export function parseWhitelist(csv: string | null | undefined): string[] {
  if (!csv) return [];
  return csv
    .split(',')
    .map((e) => e.trim().toLowerCase())
    .filter((e) => e.length > 0);
}

export function isAuthorizedEmail(email: string | null | undefined, whitelistCsv: string | null | undefined): boolean {
  if (!email) return false;
  const whitelist = parseWhitelist(whitelistCsv);
  return whitelist.includes(email.trim().toLowerCase());
}
