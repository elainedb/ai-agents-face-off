import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/auth/whitelist.dart';

void main() {
  group('isAuthorized', () {
    test('returns true for an email on the whitelist', () {
      expect(isAuthorized('allow@example.com', ['allow@example.com', 'other@example.com']), isTrue);
    });

    test('returns false for an email not on the whitelist', () {
      expect(isAuthorized('deny@example.com', ['allow@example.com']), isFalse);
    });

    test('is case-insensitive', () {
      expect(isAuthorized('Allow@Example.com', ['allow@example.com']), isTrue);
    });

    test('trims whitespace', () {
      expect(isAuthorized('  allow@example.com  ', ['allow@example.com']), isTrue);
    });

    test('returns false for an empty email', () {
      expect(isAuthorized('', ['allow@example.com']), isFalse);
    });

    test('returns false when the whitelist is empty', () {
      expect(isAuthorized('allow@example.com', []), isFalse);
    });
  });

  group('parseAuthorizedEmails', () {
    test('splits a comma-separated list and trims entries', () {
      expect(
        parseAuthorizedEmails('a@example.com, b@example.com ,c@example.com'),
        ['a@example.com', 'b@example.com', 'c@example.com'],
      );
    });

    test('drops empty entries', () {
      expect(parseAuthorizedEmails('a@example.com,,'), ['a@example.com']);
    });
  });
}
