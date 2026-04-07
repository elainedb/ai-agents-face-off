import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_state.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/pages/logged_page.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => const Scaffold(body: Center(child: CircularProgressIndicator())),
          loading: (_) => const Scaffold(body: Center(child: CircularProgressIndicator())),
          authenticated: (state) => LoggedPage(user: state.user),
          unauthenticated: (_) => const LoginPage(),
          error: (state) => LoginPage(errorMessage: state.message),
        );
      },
    );
  }
}
