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
      builder: (context, state) {
        return switch (state) {
          Authenticated(:final user) => LoggedPage(user: user),
          AuthError(:final message) => LoginPage(errorMessage: message),
          AuthLoading() || AuthInitial() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          _ => const LoginPage(),
        };
      },
    );
  }
}
