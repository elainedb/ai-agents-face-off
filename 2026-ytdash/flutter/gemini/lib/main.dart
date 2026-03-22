import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ytdash_flutter_gemini/firebase_options.dart';
import 'package:ytdash_flutter_gemini/di.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_event.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const AuthEvent.checkAuthStatus()),
      child: MaterialApp(
        title: 'YouTube Videos App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
