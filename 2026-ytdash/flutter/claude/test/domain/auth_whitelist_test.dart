import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter/domain/auth/auth_whitelist.dart';

void main() {
  const whitelist = ['user1@example.com', 'user2@example.com'];

  test('authorized email on the whitelist is allowed', () {
    expect(isAuthorized('user2@example.com', whitelist), isTrue);
  });

  test('email not on the whitelist is denied', () {
    expect(isAuthorized('someone.else@gmail.com', whitelist), isFalse);
  });

  test('whitelist match is case-insensitive and trims whitespace', () {
    expect(isAuthorized('  User2@example.com  ', whitelist), isTrue);
  });

  test('empty whitelist denies everyone', () {
    expect(isAuthorized('user2@example.com', const []), isFalse);
  });
}
