import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.auth(String message) = AuthFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}

extension FailureX on Failure {
  String get message => when(
        server: (message) => message,
        cache: (message) => message,
        network: (message) => message,
        auth: (message) => message,
        validation: (message) => message,
        unexpected: (message) => message,
      );
}