import {
  isPalindrome,
  countWords,
  reverseWords,
  capitalizeWords,
  removeVowels,
  isValidEmail,
} from '../string-helpers';

describe('isPalindrome', () => {
  it('should return true for a palindrome', () => {
    expect(isPalindrome('racecar')).toBe(true);
  });

  it('should ignore non-alphanumeric characters', () => {
    expect(isPalindrome('A man, a plan, a canal: Panama')).toBe(true);
  });

  it('should be case-insensitive', () => {
    expect(isPalindrome('RaceCar')).toBe(true);
  });

  it('should return false for non-palindromes', () => {
    expect(isPalindrome('hello')).toBe(false);
  });

  it('should handle empty string', () => {
    expect(isPalindrome('')).toBe(true);
  });
});

describe('countWords', () => {
  it('should count words correctly', () => {
    expect(countWords('hello world')).toBe(2);
  });

  it('should handle multiple spaces', () => {
    expect(countWords('hello   world   test')).toBe(3);
  });

  it('should return 0 for empty string', () => {
    expect(countWords('')).toBe(0);
  });

  it('should return 0 for whitespace only', () => {
    expect(countWords('   ')).toBe(0);
  });
});

describe('reverseWords', () => {
  it('should reverse word order', () => {
    expect(reverseWords('hello world')).toBe('world hello');
  });

  it('should handle single word', () => {
    expect(reverseWords('hello')).toBe('hello');
  });
});

describe('capitalizeWords', () => {
  it('should capitalize each word', () => {
    expect(capitalizeWords('hello world')).toBe('Hello World');
  });

  it('should handle mixed case', () => {
    expect(capitalizeWords('hELLO wORLD')).toBe('Hello World');
  });
});

describe('removeVowels', () => {
  it('should remove all vowels', () => {
    expect(removeVowels('hello world')).toBe('hll wrld');
  });

  it('should be case-insensitive', () => {
    expect(removeVowels('AEIOU')).toBe('');
  });
});

describe('isValidEmail', () => {
  it('should validate correct emails', () => {
    expect(isValidEmail('test@example.com')).toBe(true);
  });

  it('should reject invalid emails', () => {
    expect(isValidEmail('not-an-email')).toBe(false);
    expect(isValidEmail('missing@domain')).toBe(false);
    expect(isValidEmail('@no-user.com')).toBe(false);
  });
});
