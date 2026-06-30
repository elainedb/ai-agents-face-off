import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/src/domain/auth_policy.dart';

void main() {
  group('AuthPolicy', () {
    const policy = AuthPolicy(['allow@example.com', 'Second@Example.com']);

    test('authorizes a whitelisted email (case-insensitive, trimmed)', () {
      expect(policy.isAuthorized('allow@example.com'), isTrue);
      expect(policy.isAuthorized('  ALLOW@EXAMPLE.COM  '), isTrue);
      expect(policy.isAuthorized('second@example.com'), isTrue);
    });

    test('rejects a non-whitelisted email', () {
      expect(policy.isAuthorized('deny@example.com'), isFalse);
    });

    test('rejects null/empty', () {
      expect(policy.isAuthorized(null), isFalse);
      expect(policy.isAuthorized(''), isFalse);
      expect(policy.isAuthorized('   '), isFalse);
    });

    test('empty whitelist rejects everything', () {
      const empty = AuthPolicy([]);
      expect(empty.isAuthorized('anyone@example.com'), isFalse);
    });
  });
}
