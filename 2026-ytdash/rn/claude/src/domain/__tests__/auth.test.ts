import { isAuthorized, normalizeEmail } from '../auth';

describe('isAuthorized (whitelist)', () => {
  const whitelist = ['User1@example.com', 'user2@example.com'];

  it('admits a whitelisted email (case-insensitive)', () => {
    expect(isAuthorized('user2@example.com', whitelist)).toBe(true);
    expect(isAuthorized('USER2@example.com', whitelist)).toBe(true);
    expect(isAuthorized(' user1@example.com ', whitelist)).toBe(true);
  });

  it('rejects a non-whitelisted email', () => {
    expect(isAuthorized('intruder@example.com', whitelist)).toBe(false);
  });

  it('rejects null / empty', () => {
    expect(isAuthorized(null, whitelist)).toBe(false);
    expect(isAuthorized('', whitelist)).toBe(false);
    expect(isAuthorized('someone@x.com', [])).toBe(false);
  });

  it('normalizes emails', () => {
    expect(normalizeEmail('  A@B.COM ')).toBe('a@b.com');
  });
});
