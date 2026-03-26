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
    final user = firebaseAuth.currentUser;
    return user == null ? null : UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final authResult = await firebaseAuth.signInWithCredential(credential);
      final user = authResult.user;

      if (user == null) {
        throw const AuthException('Google sign-in did not return a user.');
      }

      return UserModel.fromFirebaseUser(user);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Failed to sign in with Google.');
    } catch (error) {
      throw AuthException('Failed to sign in with Google: $error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Failed to sign out.');
    } catch (error) {
      throw AuthException('Failed to sign out: $error');
    }
  }
}
