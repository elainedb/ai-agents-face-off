
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Google'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<LoginBloc>().add(const LoginEvent.signInWithGoogle());
              },
              child: const Text('Sign in with Google'),
            ),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return state.maybeWhen(
                  error: (message) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
