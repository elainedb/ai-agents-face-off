import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebase_auth.User? user = firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }

    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      final firebase_auth.UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user == null) {
        throw const AuthException('Unable to load the authenticated user.');
      }

      return UserModel.fromFirebaseUser(user);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Authentication failed.');
    } catch (error) {
      throw AuthException('Authentication failed: $error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait(<Future<void>>[
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (error) {
      throw AuthException('Unable to sign out: $error');
    }
  }
}
