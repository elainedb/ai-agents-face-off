import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email ?? 'Unknown user',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  User toEntity() {
    return User(id: id, name: name, email: email, photoUrl: photoUrl);
  }
}
