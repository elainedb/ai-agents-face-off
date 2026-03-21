import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) = _User;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}
