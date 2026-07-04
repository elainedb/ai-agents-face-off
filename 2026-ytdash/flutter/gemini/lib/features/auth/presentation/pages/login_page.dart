import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_login',
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    identifier: 'login_google_button',
                    button: true,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () =>
                                context.read<AuthBloc>().add(SignInRequested()),
                      child: const Text('Sign in with Google'),
                    ),
                  ),
                  if (state is AuthLoading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                  if (state is AuthError) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      identifier: 'login_error_message',
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
