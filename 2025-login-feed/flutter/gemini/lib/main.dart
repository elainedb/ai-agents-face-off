import 'package:flutter/material.dart';
import 'package:flutter_gemini/app.dart';
import 'package:flutter_gemini/di.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(const App());
}