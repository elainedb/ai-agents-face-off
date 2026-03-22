import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firebaseAuth, this._googleSignIn);

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Unable to retrieve the signed-in user.');
      }

      return UserModel.fromFirebaseUser(user);
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Authentication failed.');
    } catch (error) {
      throw AuthException('Authentication failed: $error');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on fb.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Sign out failed.');
    } catch (error) {
      throw AuthException('Sign out failed: $error');
    }
  }
}
