import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final google_sign_in.GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final google_sign_in.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Sign in aborted by user');
      }

      final google_sign_in.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user != null) {
        return UserModel.fromFirebaseUser(user);
      } else {
        throw const AuthException('User is null after sign in');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }
}
