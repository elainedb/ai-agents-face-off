import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';

void main() {
  group('Failure', () {
    test('FailureX message getter returns correct message', () {
      const failure = Failure.server('test error');
      expect(failure.message, 'test error');
    });

    test('all failure types return correct messages', () {
      expect(const Failure.server('s').message, 's');
      expect(const Failure.cache('c').message, 'c');
      expect(const Failure.network('n').message, 'n');
      expect(const Failure.auth('a').message, 'a');
      expect(const Failure.validation('v').message, 'v');
      expect(const Failure.unexpected('u').message, 'u');
    });
  });
}
