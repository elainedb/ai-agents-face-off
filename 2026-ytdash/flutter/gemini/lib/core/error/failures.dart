import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.server(String message) = _ServerFailure;
  const factory Failure.cache(String message) = _CacheFailure;
  const factory Failure.network(String message) = _NetworkFailure;
  const factory Failure.auth(String message) = _AuthFailure;
  const factory Failure.validation(String message) = _ValidationFailure;
  const factory Failure.unexpected(String message) = _UnexpectedFailure;
}

extension FailureX on Failure {
  String get message => map(
        server: (f) => f.message,
        cache: (f) => f.message,
        network: (f) => f.message,
        auth: (f) => f.message,
        validation: (f) => f.message,
        unexpected: (f) => f.message,
      );
}
