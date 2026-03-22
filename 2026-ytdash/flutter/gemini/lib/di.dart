import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:http/http.dart' as http;

import 'di.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getIt.init();

@module
abstract class RegisterModule {
  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  google_sign_in.GoogleSignIn get googleSignIn => google_sign_in.GoogleSignIn(scopes: const []);

  @singleton
  http.Client get httpClient => http.Client();
}
