import { isAuthorizedEmail, parseWhitelist } from '../src/domain/auth';

describe('isAuthorizedEmail', () => {
  const whitelist = 'allow@example.com, Other@Example.com ,third@example.com';

  it('allows an exact match', () => {
    expect(isAuthorizedEmail('allow@example.com', whitelist)).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isAuthorizedEmail('OTHER@example.com', whitelist)).toBe(true);
  });

  it('rejects an email not on the whitelist', () => {
    expect(isAuthorizedEmail('deny@example.com', whitelist)).toBe(false);
  });

  it('rejects an empty email', () => {
    expect(isAuthorizedEmail('', whitelist)).toBe(false);
  });
});

describe('parseWhitelist', () => {
  it('trims, lowercases, and drops empty entries', () => {
    expect(parseWhitelist(' A@b.com ,, C@D.com')).toEqual(['a@b.com', 'c@d.com']);
  });
});
