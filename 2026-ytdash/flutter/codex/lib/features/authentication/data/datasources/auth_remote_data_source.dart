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
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }

    return UserModel.fromFirebaseUser(currentUser);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final authentication = await account.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('No user returned from Google sign-in.');
      }

      return UserModel.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Authentication failed.');
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }
      throw AuthException('Authentication failed. $error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Sign-out failed.');
    } catch (error) {
      throw AuthException('Sign-out failed. $error');
    }
  }
}
