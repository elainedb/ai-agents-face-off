import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('FailureX.message returns correct message for each variant', () {
      const serverFailure = Failure.server('server error');
      const cacheFailure = Failure.cache('cache error');
      const networkFailure = Failure.network('network error');
      const authFailure = Failure.auth('auth error');
      const validationFailure = Failure.validation('validation error');
      const unexpectedFailure = Failure.unexpected('unexpected error');

      expect(serverFailure.message, 'server error');
      expect(cacheFailure.message, 'cache error');
      expect(networkFailure.message, 'network error');
      expect(authFailure.message, 'auth error');
      expect(validationFailure.message, 'validation error');
      expect(unexpectedFailure.message, 'unexpected error');
    });
  });
}
