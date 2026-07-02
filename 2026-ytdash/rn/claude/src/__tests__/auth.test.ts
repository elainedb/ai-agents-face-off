import { isAuthorized } from '../domain/auth';

describe('isAuthorized', () => {
  const whitelist = ['allow@example.com', 'Second.User@Example.com'];

  it('allows an exact match', () => {
    expect(isAuthorized('allow@example.com', whitelist)).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isAuthorized('ALLOW@EXAMPLE.COM', whitelist)).toBe(true);
    expect(isAuthorized('second.user@example.com', whitelist)).toBe(true);
  });

  it('denies an email not on the whitelist', () => {
    expect(isAuthorized('deny@example.com', whitelist)).toBe(false);
  });

  it('denies null/empty email', () => {
    expect(isAuthorized(null, whitelist)).toBe(false);
    expect(isAuthorized('', whitelist)).toBe(false);
  });

  it('denies everything against an empty whitelist', () => {
    expect(isAuthorized('allow@example.com', [])).toBe(false);
  });
});
