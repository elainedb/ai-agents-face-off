import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import 'di.config.dart';

final GetIt sl = GetIt.instance;

@InjectableInit(initializerName: r'$initGetIt')
Future<void> configureDependencies() async => sl.$initGetIt();

@module
abstract class RegisterModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(scopes: <String>['email']);

  @lazySingleton
  http.Client get httpClient => http.Client();
}
