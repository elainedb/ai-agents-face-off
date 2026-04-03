import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  final String? error;

  const LoginPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login with Google',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEvent.signInWithGoogle());
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
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
      ),
    );
  }
}
