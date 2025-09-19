import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_event.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<LoginBloc>().add(const LoginEvent.loginWithGoogle());
      },
      child: const Text('Sign in with Google'),
    );
  }
}
