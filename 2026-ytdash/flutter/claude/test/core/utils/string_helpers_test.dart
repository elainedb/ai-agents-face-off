import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_claude/core/utils/string_helpers.dart';

void main() {
  group('isPalindrome', () {
    test('returns true for palindrome', () {
      expect(isPalindrome('racecar'), true);
    });

    test('returns true for palindrome ignoring case', () {
      expect(isPalindrome('RaceCar'), true);
    });

    test('returns true for palindrome ignoring non-alphanumeric', () {
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

    test('returns 0 for empty string', () {
      expect(countWords(''), 0);
    });

    test('returns 0 for whitespace only', () {
      expect(countWords('   '), 0);
    });

    test('handles multiple spaces between words', () {
      expect(countWords('hello   world   test'), 3);
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

    test('handles already capitalized', () {
      expect(capitalizeWords('Hello World'), 'Hello World');
    });

    test('handles all uppercase', () {
      expect(capitalizeWords('HELLO WORLD'), 'Hello World');
    });

    test('handles single word', () {
      expect(capitalizeWords('hello'), 'Hello');
    });
  });

  group('removeVowels', () {
    test('removes vowels', () {
      expect(removeVowels('hello'), 'hll');
    });

    test('removes uppercase vowels', () {
      expect(removeVowels('HELLO'), 'HLL');
    });

    test('handles string with no vowels', () {
      expect(removeVowels('rhythm'), 'rhythm');
    });

    test('handles empty string', () {
      expect(removeVowels(''), '');
    });
  });

  group('isValidEmail', () {
    test('returns true for valid email', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('returns false for invalid email missing @', () {
      expect(isValidEmail('testexample.com'), false);
    });

    test('returns false for invalid email missing domain', () {
      expect(isValidEmail('test@'), false);
    });

    test('returns false for empty string', () {
      expect(isValidEmail(''), false);
    });

    test('returns true for email with dots', () {
      expect(isValidEmail('user.name@example.co.uk'), true);
    });

    test('returns true for email with plus', () {
      expect(isValidEmail('user+tag@example.com'), true);
    });
  });
}
