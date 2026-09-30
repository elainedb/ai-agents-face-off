import 'package:flutter_gemini/di.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> setupTestDependencies() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await GetIt.I.reset();
  await configureDependencies();
}
