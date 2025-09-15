import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) = _User;

  const User._();

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}