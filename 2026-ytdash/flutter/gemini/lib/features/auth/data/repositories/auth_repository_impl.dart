import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../test_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({required this.googleSignIn});

  List<String> get _authorizedEmails {
    final override = TestConfig.instance.authorizedEmails;
    if (override != null && override.isNotEmpty) {
      return override.split(',').map((e) => e.trim()).toList();
    }
    return ['user1@example.com', 'user2@example.com'];
  }

  @override
  Future<Result<String>> signInWithGoogle() async {
    try {
      String email;

      if (TestConfig.instance.uiTestMode &&
          TestConfig.instance.mockAuthEmail != null) {
        email = TestConfig.instance.mockAuthEmail!;
      } else {
        final account = await googleSignIn.signIn();
        if (account == null) {
          return Error(AuthFailure('Sign in aborted by user'));
        }
        email = account.email;
      }

      if (_authorizedEmails.contains(email)) {
        return Success(email);
      } else {
        await signOut(); // Ensure they are signed out if unauthorized
        return Error(AuthFailure('Unauthorized email'));
      }
    } catch (e) {
      return Error(AuthFailure('Sign in failed: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      if (!TestConfig.instance.uiTestMode) {
        await googleSignIn.signOut();
      }
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Sign out failed: $e'));
    }
  }

  @override
  Future<Result<String?>> getSignedInUser() async {
    try {
      if (TestConfig.instance.uiTestMode &&
          TestConfig.instance.mockAuthEmail != null) {
        return Success(null); // Assuming fresh start for mock
      }
      if (await googleSignIn.isSignedIn()) {
        final account = googleSignIn.currentUser;
        if (account != null && _authorizedEmails.contains(account.email)) {
          return Success(account.email);
        }
      }
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Get signed in user failed: $e'));
    }
  }
}
