
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

abstract class LoginRemoteDataSource {
  Future<String> signInWithGoogle();
  Future<void> signOut();
}

@LazySingleton(as: LoginRemoteDataSource)
class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final GoogleSignIn _googleSignIn;

  LoginRemoteDataSourceImpl(this._googleSignIn);

  @override
  Future<String> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign in aborted by user.');
    }
    return googleUser.email;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
