import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final deniedEmail = authState is AuthLoggedOut
        ? authState.deniedEmail
        : null;

    return Semantics(
      container: true,
      identifier: 'screen_login',
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_outline, size: 72),
                  const SizedBox(height: 16),
                  const Text(
                    'ytdash',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    container: true,
                    identifier: 'login_google_button',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signIn(),
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                    ),
                  ),
                  if (deniedEmail != null) ...[
                    const SizedBox(height: 24),
                    Semantics(
                      container: true,
                      identifier: 'login_error_message',
                      child: Text(
                        '$deniedEmail is not authorized to use this app.',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
