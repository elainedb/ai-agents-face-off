import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio();
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
    return dio;
  }

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  @preResolve
  @singleton
  Future<Database> get database async {
    return openDatabase(
      join(await getDatabasesPath(), 'videos.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE videos(id TEXT PRIMARY KEY, video TEXT, timestamp INTEGER)',
        );
      },
      version: 1,
    );
  }
}
