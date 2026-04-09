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
  it('ignores case', () => {
    expect(isPalindrome('RaceCar')).toBe(true);
  });
  it('ignores non-alphanumeric characters', () => {
    expect(isPalindrome('A man, a plan, a canal: Panama')).toBe(true);
  });
  it('returns false for non-palindromes', () => {
    expect(isPalindrome('hello')).toBe(false);
  });
  it('handles empty string', () => {
    expect(isPalindrome('')).toBe(true);
  });
});

describe('countWords', () => {
  it('counts words in a sentence', () => {
    expect(countWords('hello world')).toBe(2);
  });
  it('handles multiple spaces', () => {
    expect(countWords('hello   world')).toBe(2);
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
  it('capitalizes first letter of each word', () => {
    expect(capitalizeWords('hello world')).toBe('Hello World');
  });
  it('handles already capitalized text', () => {
    expect(capitalizeWords('Hello World')).toBe('Hello World');
  });
});

describe('removeVowels', () => {
  it('removes vowels', () => {
    expect(removeVowels('hello')).toBe('hll');
  });
  it('removes uppercase vowels', () => {
    expect(removeVowels('HELLO')).toBe('HLL');
  });
  it('handles no vowels', () => {
    expect(removeVowels('xyz')).toBe('xyz');
  });
});

describe('isValidEmail', () => {
  it('validates correct email', () => {
    expect(isValidEmail('test@example.com')).toBe(true);
  });
  it('rejects email without @', () => {
    expect(isValidEmail('testexample.com')).toBe(false);
  });
  it('rejects email without domain', () => {
    expect(isValidEmail('test@')).toBe(false);
  });
  it('rejects email with spaces', () => {
    expect(isValidEmail('te st@example.com')).toBe(false);
  });
});
