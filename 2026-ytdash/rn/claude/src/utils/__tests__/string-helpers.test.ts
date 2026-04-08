import {
  isPalindrome,
  countWords,
  reverseWords,
  capitalizeWords,
  removeVowels,
  isValidEmail,
} from '../string-helpers';

describe('isPalindrome', () => {
  it('returns true for a palindrome', () => {
    expect(isPalindrome('racecar')).toBe(true);
  });

  it('ignores non-alphanumeric characters', () => {
    expect(isPalindrome('A man, a plan, a canal: Panama')).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isPalindrome('RaceCar')).toBe(true);
  });

  it('returns false for non-palindrome', () => {
    expect(isPalindrome('hello')).toBe(false);
  });

  it('returns true for empty string', () => {
    expect(isPalindrome('')).toBe(true);
  });
});

describe('countWords', () => {
  it('counts words in a sentence', () => {
    expect(countWords('hello world')).toBe(2);
  });

  it('handles multiple spaces', () => {
    expect(countWords('hello   world   foo')).toBe(3);
  });

  it('returns 0 for empty string', () => {
    expect(countWords('')).toBe(0);
  });

  it('returns 0 for whitespace only', () => {
    expect(countWords('   ')).toBe(0);
  });
});

describe('reverseWords', () => {
  it('reverses word order', () => {
    expect(reverseWords('hello world')).toBe('world hello');
  });

  it('handles single word', () => {
    expect(reverseWords('hello')).toBe('hello');
  });
});

describe('capitalizeWords', () => {
  it('capitalizes each word', () => {
    expect(capitalizeWords('hello world')).toBe('Hello World');
  });

  it('handles already capitalized', () => {
    expect(capitalizeWords('Hello World')).toBe('Hello World');
  });
});

describe('removeVowels', () => {
  it('removes vowels', () => {
    expect(removeVowels('hello')).toBe('hll');
  });

  it('is case-insensitive', () => {
    expect(removeVowels('HELLO')).toBe('HLL');
  });

  it('handles no vowels', () => {
    expect(removeVowels('gym')).toBe('gym');
  });
});

describe('isValidEmail', () => {
  it('returns true for valid email', () => {
    expect(isValidEmail('test@example.com')).toBe(true);
  });

  it('returns false for missing @', () => {
    expect(isValidEmail('testexample.com')).toBe(false);
  });

  it('returns false for missing domain', () => {
    expect(isValidEmail('test@')).toBe(false);
  });

  it('returns false for empty string', () => {
    expect(isValidEmail('')).toBe(false);
  });
});
