import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_claude/core/utils/string_helpers.dart';

void main() {
  group('isPalindrome', () {
    test('returns true for a palindrome', () {
      expect(isPalindrome('racecar'), isTrue);
    });

    test('returns true ignoring case', () {
      expect(isPalindrome('RaceCar'), isTrue);
    });

    test('returns true ignoring non-alphanumeric characters', () {
      expect(isPalindrome('A man, a plan, a canal: Panama'), isTrue);
    });

    test('returns false for non-palindrome', () {
      expect(isPalindrome('hello'), isFalse);
    });

    test('returns true for empty string', () {
      expect(isPalindrome(''), isTrue);
    });

    test('returns true for single character', () {
      expect(isPalindrome('a'), isTrue);
    });
  });

  group('countWords', () {
    test('counts words in a sentence', () {
      expect(countWords('hello world foo'), equals(3));
    });

    test('returns 0 for empty string', () {
      expect(countWords(''), equals(0));
    });

    test('returns 0 for whitespace only', () {
      expect(countWords('   '), equals(0));
    });

    test('handles multiple spaces between words', () {
      expect(countWords('hello   world'), equals(2));
    });

    test('returns 1 for single word', () {
      expect(countWords('hello'), equals(1));
    });
  });

  group('reverseWords', () {
    test('reverses word order', () {
      expect(reverseWords('hello world'), equals('world hello'));
    });

    test('handles single word', () {
      expect(reverseWords('hello'), equals('hello'));
    });

    test('handles empty string', () {
      expect(reverseWords(''), equals(''));
    });
  });

  group('capitalizeWords', () {
    test('capitalizes each word', () {
      expect(capitalizeWords('hello world'), equals('Hello World'));
    });

    test('handles already capitalized', () {
      expect(capitalizeWords('HELLO WORLD'), equals('Hello World'));
    });

    test('handles single word', () {
      expect(capitalizeWords('hello'), equals('Hello'));
    });

    test('handles empty string', () {
      expect(capitalizeWords(''), equals(''));
    });
  });

  group('removeVowels', () {
    test('removes vowels', () {
      expect(removeVowels('hello'), equals('hll'));
    });

    test('removes uppercase vowels', () {
      expect(removeVowels('HELLO'), equals('HLL'));
    });

    test('handles no vowels', () {
      expect(removeVowels('xyz'), equals('xyz'));
    });

    test('handles all vowels', () {
      expect(removeVowels('aeiou'), equals(''));
    });

    test('handles empty string', () {
      expect(removeVowels(''), equals(''));
    });
  });

  group('isValidEmail', () {
    test('returns true for valid email', () {
      expect(isValidEmail('test@example.com'), isTrue);
    });

    test('returns true for email with dots', () {
      expect(isValidEmail('first.last@example.co.uk'), isTrue);
    });

    test('returns false for missing @', () {
      expect(isValidEmail('testexample.com'), isFalse);
    });

    test('returns false for missing domain', () {
      expect(isValidEmail('test@'), isFalse);
    });

    test('returns false for empty string', () {
      expect(isValidEmail(''), isFalse);
    });
  });
}
