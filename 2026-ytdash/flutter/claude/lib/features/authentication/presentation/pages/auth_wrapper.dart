import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/pages/login_page.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/pages/logged_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          authenticated: (user) => LoggedPage(user: user),
          unauthenticated: () => const LoginPage(),
          error: (message) => LoginPage(errorMessage: message),
        );
      },
    );
  }
}
