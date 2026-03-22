import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:ytdash_flutter_gemini/features/authentication/presentation/bloc/auth_event.dart';

class LoginPage extends StatelessWidget {
  final String? error;

  const LoginPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login with Google',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEvent.signInWithGoogle());
              },
              child: const Text('Sign in with Google'),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
