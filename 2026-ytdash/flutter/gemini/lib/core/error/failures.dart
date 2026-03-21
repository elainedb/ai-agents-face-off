import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server(String message) = _Server;
  const factory Failure.cache(String message) = _Cache;
  const factory Failure.network(String message) = _Network;
  const factory Failure.auth(String message) = _Auth;
  const factory Failure.validation(String message) = _Validation;
  const factory Failure.unexpected(String message) = _Unexpected;
}
