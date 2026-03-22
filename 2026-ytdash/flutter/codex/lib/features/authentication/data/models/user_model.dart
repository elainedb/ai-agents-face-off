import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirebaseUser(fb.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email ?? 'Unknown User',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  User toEntity() => User(id: id, name: name, email: email, photoUrl: photoUrl);
}
