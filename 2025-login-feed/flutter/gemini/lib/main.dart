
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/di.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/pages/logged_screen.dart';
import 'package:flutter_gemini/features/login/presentation/pages/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: MaterialApp(
        title: 'Flutter Gemini',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return state.maybeWhen(
              success: () => const LoggedScreen(),
              orElse: () => const LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}
