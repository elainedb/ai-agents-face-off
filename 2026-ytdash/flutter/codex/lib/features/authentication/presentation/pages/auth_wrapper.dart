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
        return state.when(
          initial: _loading,
          loading: _loading,
          authenticated: (user) => LoggedPage(user: user),
          unauthenticated: () => const LoginPage(),
          error: (message) => LoginPage(errorMessage: message),
        );
      },
    );
  }

  Widget _loading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
