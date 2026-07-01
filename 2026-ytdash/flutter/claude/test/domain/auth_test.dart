import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/auth/auth_service.dart';

void main() {
  group('isAuthorizedEmail', () {
    const whitelist = ['allow@example.com', 'Second.User@Example.com'];

    test('accepts an exact match', () {
      expect(isAuthorizedEmail('allow@example.com', whitelist), isTrue);
    });

    test('is case-insensitive', () {
      expect(isAuthorizedEmail('ALLOW@EXAMPLE.COM', whitelist), isTrue);
      expect(isAuthorizedEmail('second.user@example.com', whitelist), isTrue);
    });

    test('rejects an email not on the whitelist', () {
      expect(isAuthorizedEmail('deny@example.com', whitelist), isFalse);
    });

    test('rejects everything against an empty whitelist', () {
      expect(isAuthorizedEmail('allow@example.com', const []), isFalse);
    });

    test('ignores surrounding whitespace', () {
      expect(isAuthorizedEmail('  allow@example.com  ', whitelist), isTrue);
    });
  });
}
