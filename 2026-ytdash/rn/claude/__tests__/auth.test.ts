import { isAuthorized } from '../src/domain/auth';

const whitelist = ['user1@example.com', 'user2@example.com'];

describe('isAuthorized (whitelist)', () => {
  it('accepts an email on the whitelist', () => {
    expect(isAuthorized('user2@example.com', whitelist)).toBe(true);
  });

  it('is case-insensitive and trims', () => {
    expect(isAuthorized('  USER2@example.com ', whitelist)).toBe(true);
  });

  it('rejects an email not on the whitelist', () => {
    expect(isAuthorized('deny@example.com', whitelist)).toBe(false);
  });

  it('rejects null/empty', () => {
    expect(isAuthorized(null, whitelist)).toBe(false);
    expect(isAuthorized('', whitelist)).toBe(false);
    expect(isAuthorized('   ', whitelist)).toBe(false);
  });

  it('rejects everything against an empty whitelist', () => {
    expect(isAuthorized('user2@example.com', [])).toBe(false);
  });
});
