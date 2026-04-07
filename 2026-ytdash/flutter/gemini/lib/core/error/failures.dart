import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.server({required String message}) = _ServerFailure;
  const factory Failure.cache({required String message}) = _CacheFailure;
  const factory Failure.network({required String message}) = _NetworkFailure;
  const factory Failure.auth({required String message}) = _AuthFailure;
  const factory Failure.validation({required String message}) = _ValidationFailure;
  const factory Failure.unexpected({required String message}) = _UnexpectedFailure;
}
