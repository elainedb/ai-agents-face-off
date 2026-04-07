import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.server(String message) = _Server;
  const factory Failure.cache(String message) = _Cache;
  const factory Failure.network(String message) = _Network;
  const factory Failure.auth(String message) = _Auth;
  const factory Failure.validation(String message) = _Validation;
  const factory Failure.unexpected(String message) = _Unexpected;
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