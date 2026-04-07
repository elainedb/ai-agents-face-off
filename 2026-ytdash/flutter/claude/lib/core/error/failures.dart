import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.auth(String message) = AuthFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}

extension FailureX on Failure {
  String get message => switch (this) {
        ServerFailure(:final message) => message,
        CacheFailure(:final message) => message,
        NetworkFailure(:final message) => message,
        AuthFailure(:final message) => message,
        ValidationFailure(:final message) => message,
        UnexpectedFailure(:final message) => message,
      };
}
