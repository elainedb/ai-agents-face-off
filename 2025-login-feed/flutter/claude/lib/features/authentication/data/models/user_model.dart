import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  const UserModel._();

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );

  static UserModel fromEntity(User entity) => UserModel(
        id: entity.id,
        name: entity.name,
        email: entity.email,
        photoUrl: entity.photoUrl,
      );
}