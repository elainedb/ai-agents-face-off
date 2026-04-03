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
        return state.map(
          initial: (_) => const Scaffold(body: Center(child: CircularProgressIndicator())),
          loading: (_) => const Scaffold(body: Center(child: CircularProgressIndicator())),
          authenticated: (state) => LoggedPage(user: state.user),
          unauthenticated: (_) => const LoginPage(),
          error: (state) => LoginPage(error: state.message),
        );
      },
    );
  }
}
