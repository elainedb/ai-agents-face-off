import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth/auth_state.dart';
import 'auth_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final inProgress = auth is AuthInProgress;

    String? errorMessage;
    if (auth is AuthDenied) {
      errorMessage = '${auth.email} is not authorized to use this app.';
    } else if (auth is AuthError) {
      errorMessage = 'Sign-in failed: ${auth.message}';
    }

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
                const Icon(Icons.ondemand_video, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'ytdash',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                Semantics(
                  identifier: 'login_google_button',
                  button: true,
                  container: true,
                  child: ElevatedButton.icon(
                    onPressed: inProgress
                        ? null
                        : () =>
                              ref.read(authNotifierProvider.notifier).signIn(),
                    icon: inProgress
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Semantics(
                    identifier: 'login_error_message',
                    container: true,
                    child: Text(
                      errorMessage,
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
