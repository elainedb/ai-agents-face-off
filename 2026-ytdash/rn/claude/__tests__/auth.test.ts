import { isAuthorizedEmail, parseWhitelist } from '../src/domain/auth';

describe('isAuthorizedEmail', () => {
  const whitelist = 'allow@example.com, Other@Example.com';

  it('accepts an exact-case match', () => {
    expect(isAuthorizedEmail('allow@example.com', whitelist)).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isAuthorizedEmail('ALLOW@EXAMPLE.COM', whitelist)).toBe(true);
    expect(isAuthorizedEmail('other@example.com', whitelist)).toBe(true);
  });

  it('rejects an email not on the whitelist', () => {
    expect(isAuthorizedEmail('deny@example.com', whitelist)).toBe(false);
  });

  it('rejects when email or whitelist is empty', () => {
    expect(isAuthorizedEmail('', whitelist)).toBe(false);
    expect(isAuthorizedEmail('allow@example.com', '')).toBe(false);
    expect(isAuthorizedEmail(null, whitelist)).toBe(false);
  });
});

describe('parseWhitelist', () => {
  it('trims and lowercases entries', () => {
    expect(parseWhitelist(' A@B.com , C@D.com ')).toEqual(['a@b.com', 'c@d.com']);
  });

  it('returns empty array for falsy input', () => {
    expect(parseWhitelist(null)).toEqual([]);
    expect(parseWhitelist(undefined)).toEqual([]);
    expect(parseWhitelist('')).toEqual([]);
  });
});
