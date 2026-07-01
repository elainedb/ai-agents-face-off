import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../state/providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Semantics(
      identifier: 'screen_login',
      container: true,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_fill, size: 72, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'ytdash',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                if (auth.status == AuthStatus.authenticating)
                  Semantics(
                    identifier: 'loading_indicator',
                    container: true,
                    child: const CircularProgressIndicator(),
                  )
                else
                  Semantics(
                    identifier: 'login_google_button',
                    container: true,
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signIn(),
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                    ),
                  ),
                if (auth.status == AuthStatus.unauthorized) ...[
                  const SizedBox(height: 24),
                  Semantics(
                    identifier: 'login_error_message',
                    container: true,
                    child: Text(
                      auth.errorMessage ??
                          'This account is not authorized to use this app.',
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
    );
  }
}
