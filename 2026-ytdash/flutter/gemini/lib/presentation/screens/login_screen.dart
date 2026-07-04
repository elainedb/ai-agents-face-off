import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('screen_login'),
      body: Semantics(
        identifier: 'screen_login',
        container: true,
        explicitChildNodes: true,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('YouTube Dashboard', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 32),
                  if (state is AuthLoading)
                    Semantics(
                      identifier: 'loading_indicator',
                      container: true,
                      child: const CircularProgressIndicator(),
                    )
                  else
                    Semantics(
                      identifier: 'login_google_button',
                      button: true,
                      container: true,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(SignInRequested());
                        },
                        child: const Text('Sign in with Google'),
                      ),
                    ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
