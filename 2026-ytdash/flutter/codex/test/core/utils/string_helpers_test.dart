import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_codex/core/utils/string_helpers.dart';

void main() {
  group('string helpers', () {
    test('isPalindrome ignores punctuation and case', () {
      expect(isPalindrome('A man, a plan, a canal: Panama!'), isTrue);
    });

    test('countWords handles whitespace', () {
      expect(countWords(' one   two\nthree '), 3);
    });

    test('reverseWords reverses word order', () {
      expect(reverseWords('hello brave world'), 'world brave hello');
    });

    test('capitalizeWords title-cases words', () {
      expect(capitalizeWords('hELLo woRLD'), 'Hello World');
    });

    test('removeVowels strips uppercase and lowercase vowels', () {
      expect(removeVowels('Beautiful DAY'), 'Btfl DY');
    });

    test('isValidEmail validates a standard email', () {
      expect(isValidEmail('person@example.com'), isTrue);
      expect(isValidEmail('bad@@example'), isFalse);
    });
  });
}
