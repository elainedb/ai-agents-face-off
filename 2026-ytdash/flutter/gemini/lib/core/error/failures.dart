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
  String get message => map(
        server: (f) => f.message,
        cache: (f) => f.message,
        network: (f) => f.message,
        auth: (f) => f.message,
        validation: (f) => f.message,
        unexpected: (f) => f.message,
      );
}