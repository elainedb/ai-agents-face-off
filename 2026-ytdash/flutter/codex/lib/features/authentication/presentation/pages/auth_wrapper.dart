import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import 'logged_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState state) {
        return switch (state) {
          AuthAuthenticated() => LoggedPage(user: state.user),
          AuthUnauthenticated() => LoginPage(
            errorMessage: null,
            onSignIn: () {
              context.read<AuthBloc>().add(const SignInWithGoogleRequested());
            },
          ),
          AuthError() => LoginPage(
            errorMessage: state.message,
            onSignIn: () {
              context.read<AuthBloc>().add(const SignInWithGoogleRequested());
            },
          ),
          _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
        };
      },
    );
  }
}
