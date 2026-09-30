import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

abstract class LoginRemoteDataSource {
  Future<GoogleSignInAccount?> loginWithGoogle();
}

@LazySingleton(as: LoginRemoteDataSource)
class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final GoogleSignIn _googleSignIn;

  LoginRemoteDataSourceImpl(this._googleSignIn);

  @override
  Future<GoogleSignInAccount?> loginWithGoogle() async {
    return await _googleSignIn.signIn();
  }
}