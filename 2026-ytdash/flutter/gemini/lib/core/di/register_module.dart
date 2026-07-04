import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      return await SharedPreferences.getInstance();
    }
  }



  @lazySingleton
  http.Client get httpClient => http.Client();
}
