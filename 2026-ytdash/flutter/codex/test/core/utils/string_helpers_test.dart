import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_codex/core/utils/string_helpers.dart';

void main() {
  group('string helpers', () {
    test('isPalindrome ignores punctuation and case', () {
      expect(isPalindrome('A man, a plan, a canal: Panama!'), isTrue);
      expect(isPalindrome('Codex'), isFalse);
    });

    test('countWords splits on whitespace', () {
      expect(countWords('one   two\nthree'), 3);
      expect(countWords('   '), 0);
    });

    test('reverseWords reverses word order', () {
      expect(reverseWords('one two three'), 'three two one');
    });

    test('capitalizeWords title-cases words', () {
      expect(capitalizeWords('hello woRLD'), 'Hello World');
    });

    test('removeVowels strips vowels', () {
      expect(removeVowels('Beautiful Day'), 'Btfl Dy');
    });

    test('isValidEmail validates basic email format', () {
      expect(isValidEmail('dev@example.com'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
    });
  });
}
