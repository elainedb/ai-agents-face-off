import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login with Google',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  state.whenOrNull(
                    authenticated: (user) {
                      debugPrint('Access granted to ${user.email}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Welcome, ${user.name}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: state.maybeWhen(
                          loading: () => null,
                          orElse: () => () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEvent.signInWithGoogle());
                          },
                        ),
                        child: state.maybeWhen(
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          orElse: () => const Text('Sign in with Google'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      state.whenOrNull(
                        error: (message) => Text(
                          message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ) ??
                          const SizedBox.shrink(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}