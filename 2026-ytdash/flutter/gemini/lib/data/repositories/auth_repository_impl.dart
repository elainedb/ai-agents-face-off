import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../core/config/test_config.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  firebase.FirebaseAuth get _firebaseAuth => firebase.FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  AuthRepositoryImpl();

  List<String> get _authorizedEmails {
    final override = TestConfig.instance.authorizedEmails;
    if (override != null && override.isNotEmpty) {
      return override.split(',').map((e) => e.trim()).toList();
    }
    return ['user1@example.com', 'user2@example.com'];
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      String? email;
      String? id;

      if (TestConfig.instance.uiTestMode && TestConfig.instance.mockAuthEmail != null) {
        email = TestConfig.instance.mockAuthEmail;
        id = 'mock_id_123';
      } else {
        await _googleSignIn.initialize();
        final googleUser = await _googleSignIn.authenticate(scopeHint: ['email']);
        if (googleUser == null) {
          return const Left(AuthFailure('Sign in aborted.'));
        }
        email = googleUser.email;
        id = googleUser.id;
        
        final googleAuth = await googleUser.authentication;
        final authz = await googleUser.authorizationClient.authorizeScopes(['email']);
        final credential = firebase.GoogleAuthProvider.credential(
          accessToken: authz.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
      }

      if (email == null) {
         return const Left(AuthFailure('Sign in failed.'));
      }

      if (!_authorizedEmails.contains(email)) {
        await signOut();
        return const Left(AuthFailure('Email not authorized.'));
      }

      return Right(User(id: id, email: email));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      if (!(TestConfig.instance.uiTestMode && TestConfig.instance.mockAuthEmail != null)) {
        await _googleSignIn.signOut();
        await _firebaseAuth.signOut();
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getSignedInUser() async {
    try {
      if (TestConfig.instance.uiTestMode && TestConfig.instance.mockAuthEmail != null) {
        // Mock doesn't persist session in this simplified mock mode.
        return const Right(null);
      }
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        if (_authorizedEmails.contains(currentUser.email)) {
          return Right(User(id: currentUser.uid, email: currentUser.email!));
        } else {
          await signOut();
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
