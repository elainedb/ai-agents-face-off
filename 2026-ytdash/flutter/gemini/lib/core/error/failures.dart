import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.server([@Default('A server error occurred') String message]) = _ServerFailure;
  const factory Failure.cache([@Default('A cache error occurred') String message]) = _CacheFailure;
  const factory Failure.network([@Default('A network error occurred') String message]) = _NetworkFailure;
  const factory Failure.auth([@Default('An authentication error occurred') String message]) = _AuthFailure;
  const factory Failure.validation([@Default('A validation error occurred') String message]) = _ValidationFailure;
  const factory Failure.unexpected([@Default('An unexpected error occurred') String message]) = _UnexpectedFailure;
}

extension FailureX on Failure {
  String get message => when(
        server: (m) => m,
        cache: (m) => m,
        network: (m) => m,
        auth: (m) => m,
        validation: (m) => m,
        unexpected: (m) => m,
      );
}
