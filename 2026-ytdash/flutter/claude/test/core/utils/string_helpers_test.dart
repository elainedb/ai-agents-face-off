import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_claude/core/utils/string_helpers.dart';

void main() {
  group('isPalindrome', () {
    test('returns true for a palindrome', () {
      expect(isPalindrome('racecar'), true);
    });

    test('returns true for a palindrome with mixed case', () {
      expect(isPalindrome('RaceCar'), true);
    });

    test('returns true for a palindrome with spaces and punctuation', () {
      expect(isPalindrome('A man, a plan, a canal: Panama'), true);
    });

    test('returns false for non-palindrome', () {
      expect(isPalindrome('hello'), false);
    });

    test('returns true for empty string', () {
      expect(isPalindrome(''), true);
    });

    test('returns true for single character', () {
      expect(isPalindrome('a'), true);
    });
  });

  group('countWords', () {
    test('counts words correctly', () {
      expect(countWords('hello world'), 2);
    });

    test('handles multiple spaces', () {
      expect(countWords('hello   world   foo'), 3);
    });

    test('returns 0 for empty string', () {
      expect(countWords(''), 0);
    });

    test('returns 0 for whitespace only', () {
      expect(countWords('   '), 0);
    });

    test('counts single word', () {
      expect(countWords('hello'), 1);
    });
  });

  group('reverseWords', () {
    test('reverses word order', () {
      expect(reverseWords('hello world'), 'world hello');
    });

    test('handles single word', () {
      expect(reverseWords('hello'), 'hello');
    });

    test('handles multiple words', () {
      expect(reverseWords('one two three'), 'three two one');
    });
  });

  group('capitalizeWords', () {
    test('capitalizes each word', () {
      expect(capitalizeWords('hello world'), 'Hello World');
    });

    test('handles mixed case', () {
      expect(capitalizeWords('hELLO wORLD'), 'Hello World');
    });

    test('handles single word', () {
      expect(capitalizeWords('hello'), 'Hello');
    });
  });

  group('removeVowels', () {
    test('removes vowels from string', () {
      expect(removeVowels('hello'), 'hll');
    });

    test('removes uppercase vowels too', () {
      expect(removeVowels('HELLO'), 'HLL');
    });

    test('handles string with no vowels', () {
      expect(removeVowels('bcdfg'), 'bcdfg');
    });

    test('handles empty string', () {
      expect(removeVowels(''), '');
    });
  });

  group('isValidEmail', () {
    test('returns true for valid email', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('returns true for email with dots', () {
      expect(isValidEmail('test.user@example.co.uk'), true);
    });

    test('returns false for invalid email - no @', () {
      expect(isValidEmail('testexample.com'), false);
    });

    test('returns false for invalid email - no domain', () {
      expect(isValidEmail('test@'), false);
    });

    test('returns false for empty string', () {
      expect(isValidEmail(''), false);
    });
  });
}
